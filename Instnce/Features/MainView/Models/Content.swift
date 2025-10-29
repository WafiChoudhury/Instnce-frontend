//
//  Content.swift
//  Instnce
//
//  Created by Wafi Choudhury on 10/21/25.
//

import Foundation

// MARK: - Content Model (matches Supabase schema)
struct Content: Identifiable, Codable {
    let id: String
    let url: String
    let title: String
    let description: String
    let thumbnailUrl: String?
    let platform: Platform
    let creatorName: String
    let creatorHandle: String?
    let tokenAddress: String
    let currentPrice: Double
    let priceChange24h: Double
    let marketCap: Double
    let volume24h: Double
    let totalSupply: Int
    let holderCount: Int
    let viewCount: Int
    let engagementScore: Double
    let isTrending: Bool
    let priceHistory: [PricePoint]
    let createdAt: Date
    let updatedAt: Date

    // NEW: optional video file name (e.g. "mockPreview" -> mockPreview.mp4 in bundle)
    let videoName: String?

    enum Platform: String, Codable {
        case youtube = "youtube"
        case tiktok = "tiktok"
        case instagram = "instagram"
        case twitter = "twitter"
        case other = "other"

        var displayName: String {
            switch self {
            case .youtube: return "YouTube"
            case .tiktok: return "TikTok"
            case .instagram: return "Instagram"
            case .twitter: return "Twitter"
            case .other: return "Other"
            }
        }

        var icon: String {
            switch self {
            case .youtube: return "play.rectangle.fill"
            case .tiktok: return "music.note"
            case .instagram: return "camera.fill"
            case .twitter: return "bird.fill"
            case .other: return "link"
            }
        }
    }

    // Computed properties for UI
    var formattedPrice: String {
        "$\(String(format: "%.4f", currentPrice))"
    }

    var formattedPriceChange: String {
        let sign = priceChange24h >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.1f", priceChange24h))%"
    }

    var isPositiveChange: Bool {
        priceChange24h >= 0
    }

    var formattedMarketCap: String {
        formatLargeNumber(marketCap)
    }

    var formattedVolume: String {
        formatLargeNumber(volume24h)
    }

    var formattedHolders: String {
        if holderCount >= 1000 {
            return String(format: "%.1fK", Double(holderCount) / 1000)
        }
        return "\(holderCount)"
    }

    var formattedViews: String {
        formatLargeNumber(Double(viewCount))
    }

    private func formatLargeNumber(_ number: Double) -> String {
        switch number {
        case 1_000_000...:
            return String(format: "$%.1fM", number / 1_000_000)
        case 1_000...:
            return String(format: "$%.1fK", number / 1_000)
        default:
            return String(format: "$%.0f", number)
        }
    }

    // Calculate tokens received for investment amount
    func tokensForAmount(_ amount: Double) -> Int {
        guard currentPrice > 0 else { return 0 }
        return Int(amount / currentPrice)
    }
}

// MARK: - Price Point for Charts
struct PricePoint: Identifiable, Codable {
    let id: String
    let timestamp: Date
    let price: Double
    let volume: Double?

    init(id: String = UUID().uuidString, timestamp: Date, price: Double, volume: Double? = nil) {
        self.id = id
        self.timestamp = timestamp
        self.price = price
        self.volume = volume
    }
}




// MARK: - Investment Model
struct Investment: Identifiable, Codable {
    let id: String
    let userId: String
    let contentId: String
    let tokenAddress: String
    let amountInvested: Double
    let tokensReceived: Double
    let purchasePrice: Double
    let transactionSignature: String
    let status: TransactionStatus
    let createdAt: Date

    enum TransactionStatus: String, Codable {
        case pending = "pending"
        case confirmed = "confirmed"
        case failed = "failed"
    }
}
