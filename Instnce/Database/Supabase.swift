//
//  Supabase.swift
//  Instnce
//
//  Created by Wafi Choudhury on 10/18/25.
//

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
@MainActor
func syncUserToSupabase(privyUser: PrivyUser, phoneNumber: String?) async throws {
    let phoneHash = phoneNumber?.hash.description
    
    // Check if user already exists
    let response = try await supabase
        .from("users")
        .select("id")
        .eq("privy_user_id", value: privyUser.id)
        .execute()
    
    let existingUsers = try? JSONDecoder().decode([PartialUser].self, from: response.data)
    
    if let users = existingUsers, !users.isEmpty {
        print("✅ User already exists in Supabase")
        try await updateUserTimestamp(privyUserId: privyUser.id)
    } else {
        print("ℹ️ Creating new user in Supabase...")
        try await createUserInSupabase(privyUser: privyUser, phoneHash: phoneHash)
    }
}

@MainActor
private func createUserInSupabase(privyUser: PrivyUser, phoneHash: String?) async throws {
    let isoFormatter = ISO8601DateFormatter()
    let now = isoFormatter.string(from: Date())
    
    let userData = UserRequest(
        privyUserId: privyUser.id,
        phoneNumberHash: phoneHash,
        createdAt: now,
        updatedAt: now
    )
    
    try await supabase
        .from("users")
        .insert(userData)
        .execute()
    
    print("✅ User created in Supabase")
}

@MainActor
private func updateUserTimestamp(privyUserId: String) async throws {
    let isoFormatter = ISO8601DateFormatter()
    let now = isoFormatter.string(from: Date())
    
    let userData = UserUpdateRequest(updatedAt: now)
    
    try await supabase
        .from("users")
        .update(userData)
        .eq("privy_user_id", value: privyUserId)
        .execute()
    
    print("✅ User timestamp updated")
}

/// Gets the Supabase user ID for a Privy user
@MainActor
func getSupabaseUserId(for privyUserId: String) async throws -> String {
    let response = try await supabase
        .from("users")
        .select("id")
        .eq("privy_user_id", value: privyUserId)
        .execute()
    
    let users = try JSONDecoder().decode([PartialUser].self, from: response.data)
    
    guard let firstUser = users.first else {
        throw NSError(domain: "SupabaseError", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])
    }
    
    return firstUser.id
}

// MARK: - Wallet Operations

/// Syncs a wallet to Supabase database
@MainActor
func syncWalletToSupabase(userId: String, walletAddress: String, chain: String = "solana") async throws {
    // Check if wallet already exists
    let response = try await supabase
        .from("wallets")
        .select("id, wallet_address")
        .eq("user_id", value: userId)
        .execute()
    
    let existingWallets = try? JSONDecoder().decode([WalletRecord].self, from: response.data)
    
    if let wallets = existingWallets, !wallets.isEmpty {
        print("✅ Wallet already synced")
    } else {
        print("ℹ️ Creating new wallet in Supabase...")
        try await createWalletInSupabase(userId: userId, walletAddress: walletAddress, chain: chain)
    }
}

@MainActor
private func createWalletInSupabase(userId: String, walletAddress: String, chain: String) async throws {
    let isoFormatter = ISO8601DateFormatter()
    let now = isoFormatter.string(from: Date())
    
    let walletData = WalletRequest(
        userId: userId,
        walletAddress: walletAddress,
        chain: chain,
        balanceUsd: 0,
        createdAt: now,
        updatedAt: now
    )
    
    try await supabase
        .from("wallets")
        .insert(walletData)
        .execute()
    
    print("✅ Wallet created in Supabase: \(walletAddress)")
}

// MARK: - Complete Sync Function

/// Syncs both user and wallet to Supabase in one call
@MainActor
func syncUserAndWallet(privyUser: PrivyUser, walletAddress: String, phoneNumber: String? = nil) async {
    do {
        try await syncUserToSupabase(privyUser: privyUser, phoneNumber: phoneNumber)
        let userId = try await getSupabaseUserId(for: privyUser.id)
        try await syncWalletToSupabase(userId: userId, walletAddress: walletAddress, chain: "solana")
        print("✅ User and wallet synced to Supabase successfully")
    } catch {
        print("⚠️ Failed to sync to Supabase: \(error.localizedDescription)")
    }
}
// MARK: - Profile Operations

/// Fetches user profile from Supabase
@MainActor
func fetchUserProfile(privyUserId: String) async throws -> UserProfile {
    let response = try await supabase
        .from("users")
        .select()
        .eq("privy_user_id", value: privyUserId)
        .limit(1)
        .execute()
    
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    
    let users = try decoder.decode([UserProfile].self, from: response.data)
    
    guard let user = users.first else {
        throw NSError(domain: "SupabaseError", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])
    }
    
    return user
}

// MARK: - Supabase Auth Profile Operations

/// Fetches current user from Supabase Auth
@MainActor
func fetchAuthUserProfile() async throws -> AuthUserProfile {
    let session = try await supabase.auth.session
    let user = session.user
    let metadata = user.userMetadata ?? [:]

    func decodeString(_ anyJSON: AnyJSON?) -> String? {
        guard let anyJSON = anyJSON else { return nil }
        // Safely extract the underlying value
        if case let .string(value) = anyJSON {
            return value
        }
        // Try converting other JSON types to string if needed
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
