//
//  Supabase.swift (Optimized)
//  Instnce
//
//  Optimizations:
//  1. Use .single() instead of arrays when expecting one result
//  2. Batch operations where possible
//  3. Use .upsert() instead of check-then-create
//  4. Cache frequently accessed data
//  5. Reduce roundtrips with combined queries

import Foundation
import Supabase
import PrivySDK

// MARK: - Supabase Client

let supabase = SupabaseClient(
  supabaseURL: URL(string: "https://hbuctvafykfazgfahseo.supabase.co")!,
  supabaseKey: "sb_publishable_tbQ5k7DHDZ1pyBQSJn_Imw_i9McTAYw"
)

// MARK: - User Operations

/// Syncs a user to Supabase database after Privy authentication
/// Returns the Supabase user ID if successful
/// OPTIMIZED: Single upsert call instead of check-then-create
@MainActor
func syncUserToSupabase(privyUser: PrivyUser, phoneNumber: String?) async throws -> String? {
    let phoneHash = phoneNumber?.hash.description
    let isoFormatter = ISO8601DateFormatter()
    let now = isoFormatter.string(from: Date())
    
    // OPTIMIZATION: Use upsert with onConflict to handle create OR update in ONE call
    let userData = UserRequest(
        privyUserId: privyUser.id,
        phoneNumberHash: phoneHash,
        createdAt: now,
        updatedAt: now
    )
    
    // This will insert if new, update if exists - single database roundtrip
    let response = try await supabase
        .from("users")
        .upsert(userData, onConflict: "privy_user_id")
        .select("id")
        .single()
        .execute()
    
    let user = try JSONDecoder().decode(PartialUser.self, from: response.data)
    print("✅ User synced to Supabase")
    return user.id
}

// MARK: - Wallet Operations

/// Syncs a wallet to Supabase database
/// OPTIMIZED: Single upsert call instead of check-then-create
@MainActor
func syncWalletToSupabase(userId: String, walletAddress: String, chain: String = "solana") async throws {
    let isoFormatter = ISO8601DateFormatter()
    let now = isoFormatter.string(from: Date())
    
    let walletData = WalletRequest(
        userId: userId,
        walletAddress: walletAddress,
        chain: chain,
        balanceSol: 0.0,
        createdAt: now,
        updatedAt: now
    )
    
    // OPTIMIZATION: Use upsert with composite key to handle create OR update in ONE call
    try await supabase
        .from("wallets")
        .upsert(walletData, onConflict: "user_id,wallet_address")
        .execute()
    
    print("✅ Wallet synced to Supabase: \(walletAddress)")
}

// MARK: - Complete Sync Function

/// Syncs both user and wallet to Supabase in one call
/// OPTIMIZED: Sequential async calls, better error handling
@MainActor
func syncUserAndWallet(privyUser: PrivyUser, walletAddress: String, phoneNumber: String? = nil) async {
    do {
        // These run sequentially but are already optimized
        let userId = try await syncUserToSupabase(privyUser: privyUser, phoneNumber: phoneNumber)
        if let userId = userId {
            try await syncWalletToSupabase(userId: userId, walletAddress: walletAddress, chain: "solana")
            print("✅ User and wallet synced to Supabase successfully")
        }
    } catch {
        print("⚠️ Failed to sync to Supabase: \(error.localizedDescription)")
    }
}

// MARK: - Profile Operations

/// Fetches user profile from Supabase
/// OPTIMIZED: Use .single() instead of limit(1) + array decode
@MainActor
func fetchUserProfile(privyUserId: String) async throws -> UserProfile {
    // OPTIMIZATION: Use .single() instead of limit(1) + array decode
    let response = try await supabase
        .from("users")
        .select()
        .eq("privy_user_id", value: privyUserId)
        .single()
        .execute()
    
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    
    let user = try decoder.decode(UserProfile.self, from: response.data)
    return user
}

// MARK: - Supabase Auth Profile Operations

/// Fetches current user from Supabase Auth
/// OPTIMIZED: Cached session + efficient metadata parsing
@MainActor
func fetchAuthUserProfile() async throws -> AuthUserProfile {
    let session = try await supabase.auth.session
    let user = session.user
    let metadata = user.userMetadata ?? [:]

    func decodeString(_ anyJSON: AnyJSON?) -> String? {
        guard let anyJSON = anyJSON else { return nil }
        if case let .string(value) = anyJSON {
            return value
        }
        return String(describing: anyJSON)
    }

    let username = decodeString(metadata["full_name"])
    let avatarUrl = decodeString(metadata["avatar_url"])
    let email = user.email
    let createdAt = ISO8601DateFormatter().string(from: user.createdAt ?? Date())

    return AuthUserProfile(
        id: user.id.uuidString,
        email: email,
        username: username,
        avatarUrl: avatarUrl,
        createdAt: createdAt
    )
}

// MARK: - Caching Layer (Optional but HIGHLY recommended)

actor ProfileCache {
    private var cache: [String: (profile: UserProfile, timestamp: Date)] = [:]
    private let cacheValiditySeconds: TimeInterval = 60 // Cache for 1 minute
    
    func get(privyUserId: String) -> UserProfile? {
        guard let cached = cache[privyUserId] else { return nil }
        
        // Check if cache is still valid
        if Date().timeIntervalSince(cached.timestamp) < cacheValiditySeconds {
            return cached.profile
        }
        
        // Cache expired
        cache.removeValue(forKey: privyUserId)
        return nil
    }
    
    func set(privyUserId: String, profile: UserProfile) {
        cache[privyUserId] = (profile, Date())
    }
    
    func invalidate(privyUserId: String) {
        cache.removeValue(forKey: privyUserId)
    }
    
    func invalidateAll() {
        cache.removeAll()
    }
}

let profileCache = ProfileCache()

/// Fetches user profile with caching
@MainActor
func fetchUserProfileCached(privyUserId: String, forceRefresh: Bool = false) async throws -> UserProfile {
    // Check cache first
    if !forceRefresh, let cached = await profileCache.get(privyUserId: privyUserId) {
        print("✅ Profile loaded from cache")
        return cached
    }
    
    // Fetch from database
    let profile = try await fetchUserProfile(privyUserId: privyUserId)
    
    // Update cache
    await profileCache.set(privyUserId: privyUserId, profile: profile)
    
    return profile
}

// MARK: - Wallet Balance Operations (SOL)

/// Fetches SOL balance from blockchain
@MainActor
func fetchSolanaBalance(walletAddress: String) async throws -> Double {
    let url = URL(string: "https://api.mainnet-beta.solana.com")!
    
    let requestBody: [String: Any] = [
        "jsonrpc": "2.0",
        "id": 1,
        "method": "getBalance",
        "params": [walletAddress]
    ]
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
    
    let (data, _) = try await URLSession.shared.data(for: request)
    
    struct SolanaResponse: Codable {
        let jsonrpc: String
        let result: SolanaBalanceResult?
        let error: SolanaError?
        let id: Int
    }
    
    struct SolanaBalanceResult: Codable {
        let value: UInt64
    }
    
    struct SolanaError: Codable {
        let code: Int
        let message: String
    }
    
    let response = try JSONDecoder().decode(SolanaResponse.self, from: data)
    
    if let error = response.error {
        throw NSError(domain: "SolanaRPC", code: error.code, userInfo: [NSLocalizedDescriptionKey: error.message])
    }
    
    guard let result = response.result else {
        throw NSError(domain: "SolanaRPC", code: -1, userInfo: [NSLocalizedDescriptionKey: "No balance result"])
    }
    
    // Convert lamports to SOL (1 SOL = 1,000,000,000 lamports)
    return Double(result.value) / 1_000_000_000.0
}

/// Fetches SOL price in USD from CoinGecko
@MainActor
func fetchSolPrice() async throws -> Double {
    guard let url = URL(string: "https://api.coingecko.com/api/v3/simple/price?ids=solana&vs_currencies=usd") else {
        throw NSError(domain: "CoinGecko", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
    }
    
    let (data, _) = try await URLSession.shared.data(from: url)
    let json = try JSONSerialization.jsonObject(with: data) as? [String: [String: Double]]
    
    guard let price = json?["solana"]?["usd"] else {
        throw NSError(domain: "CoinGecko", code: -1, userInfo: [NSLocalizedDescriptionKey: "Price not found"])
    }
    
    return price
}

/// Fetches SOL balance from Supabase
@MainActor
func fetchWalletBalanceSol(walletAddress: String) async throws -> Double {
    let response = try await supabase
        .from("wallets")
        .select("balance_sol")
        .eq("wallet_address", value: walletAddress)
        .single()
        .execute()
    
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    
    struct WalletBalanceResponse: Codable {
        let balanceSol: Double
    }
    
    let wallet = try decoder.decode(WalletBalanceResponse.self, from: response.data)
    return wallet.balanceSol
}

/// Updates SOL balance in Supabase
@MainActor
func updateWalletBalanceSol(walletAddress: String, balanceSol: Double) async throws {
    let isoFormatter = ISO8601DateFormatter()
    let now = isoFormatter.string(from: Date())
    
    // Use explicit dictionary type to handle mixed types
    let updateData: [String: AnyJSON] = [
        "balance_sol": .double(balanceSol),
        "updated_at": .string(now)
    ]
    
    try await supabase
        .from("wallets")
        .update(updateData)
        .eq("wallet_address", value: walletAddress)
        .execute()
}

// MARK: - Portfolio Value History Operations

/// Inserts a portfolio value snapshot
@MainActor
func insertPortfolioValueSnapshot(
    userId: String,
    walletAddress: String,
    walletBalanceSol: Double,
    solPriceUsd: Double
) async throws {
    // Calculate portfolio value in USD (wallet balance * SOL price)
    let portfolioValueUsd = walletBalanceSol * solPriceUsd
    
    let snapshotData: [String: AnyJSON] = [
        "user_id": .string(userId),
        "wallet_address": .string(walletAddress),
        "wallet_balance_sol": .double(walletBalanceSol),
        "sol_price_usd": .double(solPriceUsd),
        "portfolio_value_usd": .double(portfolioValueUsd)
    ]
    
    try await supabase
        .from("portfolio_value")
        .insert(snapshotData)
        .execute()
    
    print("✅ Portfolio snapshot inserted: \(walletBalanceSol) SOL = $\(portfolioValueUsd)")
}

/// Fetches user_id from wallet_address (helper function)
@MainActor
func getUserIdFromWalletAddress(walletAddress: String) async throws -> String? {
    let response = try await supabase
        .from("wallets")
        .select("user_id")
        .eq("wallet_address", value: walletAddress)
        .single()
        .execute()
    
    struct WalletUserIdResponse: Codable {
        let userId: String
        
        enum CodingKeys: String, CodingKey {
            case userId = "user_id"
        }
    }
    
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    let wallet = try decoder.decode(WalletUserIdResponse.self, from: response.data)
    return wallet.userId
}

/// Fetches portfolio value history for chart
@MainActor
func fetchPortfolioValueHistory(
    userId: String,
    hours: Int = 24,
    limit: Int = 100
) async throws -> [PortfolioValueSnapshot] {
    let response = try await supabase
        .from("portfolio_value")
        .select()
        .eq("user_id", value: userId)
        .gte("timestamp", value: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-Double(hours) * 3600)))
        .order("timestamp", ascending: true)
        .limit(limit)
        .execute()
    
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    let snapshots = try decoder.decode([PortfolioValueSnapshot].self, from: response.data)
    return snapshots
}

/// Portfolio value snapshot model
struct PortfolioValueSnapshot: Codable {
    let id: String
    let userId: String
    let walletAddress: String
    let walletBalanceSol: Double
    let solPriceUsd: Double
    let portfolioValueUsd: Double
    let timestamp: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case walletAddress = "wallet_address"
        case walletBalanceSol = "wallet_balance_sol"
        case solPriceUsd = "sol_price_usd"
        case portfolioValueUsd = "portfolio_value_usd"
        case timestamp
    }
}