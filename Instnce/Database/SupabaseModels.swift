//
//  SupabaseModels.swift
//  Instnce
//
//  Data models for Supabase database operations
//

import Foundation


// MARK: - Auth User Profile Model

struct AuthUserProfile: Codable {
    let id: String
    let email: String?
    let username: String?
    let avatarUrl: String?
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case username
        case avatarUrl = "avatar_url"
        case createdAt = "created_at"
    }
}

// MARK: - User Models

struct UserProfile: Codable {
    let id: String
    let privyUserId: String
    let phoneNumberHash: String?
    let username: String?
    let avatarUrl: String?
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case privyUserId = "privy_user_id"
        case phoneNumberHash = "phone_number_hash"
        case username
        case avatarUrl = "avatar_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct UserRequest: Codable {
    let privyUserId: String
    let phoneNumberHash: String?
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case privyUserId = "privy_user_id"
        case phoneNumberHash = "phone_number_hash"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct UserUpdateRequest: Codable {
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case updatedAt = "updated_at"
    }
}

struct PartialUser: Codable {
    let id: String
}

// MARK: - Wallet Models

struct WalletRequest: Codable {
    let userId: String
    let walletAddress: String
    let chain: String
    let balanceSol: Double
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case walletAddress = "wallet_address"
        case chain
        case balanceSol = "balance_sol"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct WalletRecord: Codable {
    let id: String
    let walletAddress: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case walletAddress = "wallet_address"
    }
}

// MARK: - Token Models

struct TokenRecord: Codable {
    let id: String
    let tokenAddress: String
    let symbol: String
    let name: String
    let currentPrice: Double
    let priceChange24h: Double
    let marketCap: Double
    let volume24h: Double
    let totalSupply: Int
    let holderCount: Int
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case tokenAddress = "token_address"
        case symbol
        case name
        case currentPrice = "current_price"
        case priceChange24h = "price_change_24h"
        case marketCap = "market_cap"
        case volume24h = "volume_24h"
        case totalSupply = "total_supply"
        case holderCount = "holder_count"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct TokenRequest: Codable {
    let tokenAddress: String
    let symbol: String
    let name: String
    let currentPrice: Double
    let priceChange24h: Double
    let marketCap: Double
    let volume24h: Double
    let totalSupply: Int
    let holderCount: Int
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case tokenAddress = "token_address"
        case symbol
        case name
        case currentPrice = "current_price"
        case priceChange24h = "price_change_24h"
        case marketCap = "market_cap"
        case volume24h = "volume_24h"
        case totalSupply = "total_supply"
        case holderCount = "holder_count"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct PriceHistoryPoint: Codable {
    let id: String
    let tokenId: String
    let timestamp: String
    let price: Double
    let volume: Double?
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case tokenId = "token_id"
        case timestamp
        case price
        case volume
        case createdAt = "created_at"
    }
}
