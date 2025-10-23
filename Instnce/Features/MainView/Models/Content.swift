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

// MARK: - Mock Data for Development
extension Content {
    static let mockData: [Content] = [
        Content(
            id: "1",
            url: "https://youtube.com/watch?v=example1",
            title: "Make Your First Investment",
            description: "This video is going viral. Get in early! A comprehensive guide to getting started with crypto investments and understanding market dynamics.",
            thumbnailUrl: "https://example.com/thumb1.jpg",
            platform: .youtube,
            creatorName: "Tech Insider",
            creatorHandle: "@techinsider",
            tokenAddress: "TokenAddr123...",
            currentPrice: 0.0234,
            priceChange24h: 127.3,
            marketCap: 45230,
            volume24h: 8940,
            totalSupply: 1_000_000,
            holderCount: 234,
            viewCount: 1_245_000,
            engagementScore: 8.7,
            isTrending: true,
            priceHistory: generateMockPriceHistory(basePrice: 0.0234, points: 24),
            createdAt: Date().addingTimeInterval(-86400 * 7),
            updatedAt: Date(),
            videoName: "video1"
        ),
        Content(
            id: "2",
            url: "https://youtube.com/watch?v=example2",
            title: "Tech Review: iPhone 16 Pro",
            description: "Comprehensive review gaining traction across all platforms. Deep dive into specs, performance, and real-world usage.",
            thumbnailUrl: "https://example.com/thumb2.jpg",
            platform: .youtube,
            creatorName: "Marques Brownlee",
            creatorHandle: "@mkbhd",
            tokenAddress: "TokenAddr456...",
            currentPrice: 0.0156,
            priceChange24h: 89.2,
            marketCap: 32100,
            volume24h: 5670,
            totalSupply: 1_000_000,
            holderCount: 189,
            viewCount: 876_000,
            engagementScore: 9.1,
            isTrending: true,
            priceHistory: generateMockPriceHistory(basePrice: 0.0156, points: 24),
            createdAt: Date().addingTimeInterval(-86400 * 5),
            updatedAt: Date(),
            videoName: "mockPreview"
        ),
        Content(
            id: "3",
            url: "https://tiktok.com/@chef/video/123",
            title: "Cooking Viral Pasta Recipe",
            description: "500K views in 24 hours. This simple pasta recipe has taken TikTok by storm with its unique twist on a classic dish.",
            thumbnailUrl: "https://example.com/thumb3.jpg",
            platform: .tiktok,
            creatorName: "Chef Maria",
            creatorHandle: "@chefmaria",
            tokenAddress: "TokenAddr789...",
            currentPrice: 0.0421,
            priceChange24h: 203.5,
            marketCap: 67890,
            volume24h: 12340,
            totalSupply: 1_000_000,
            holderCount: 456,
            viewCount: 523_000,
            engagementScore: 9.4,
            isTrending: true,
            priceHistory: generateMockPriceHistory(basePrice: 0.0421, points: 24),
            createdAt: Date().addingTimeInterval(-86400 * 2),
            updatedAt: Date(),
            videoName: "mockPreview"
        ),
        Content(
            id: "4",
            url: "https://youtube.com/watch?v=example4",
            title: "AI Future Predictions 2025",
            description: "Expert analysis on where AI is heading. Insights from industry leaders and researchers about the next wave of innovation.",
            thumbnailUrl: "https://example.com/thumb4.jpg",
            platform: .youtube,
            creatorName: "AI Explained",
            creatorHandle: "@aiexplained",
            tokenAddress: "TokenAddr101...",
            currentPrice: 0.0189,
            priceChange24h: 45.8,
            marketCap: 28450,
            volume24h: 4120,
            totalSupply: 1_000_000,
            holderCount: 167,
            viewCount: 342_000,
            engagementScore: 7.9,
            isTrending: true,
            priceHistory: generateMockPriceHistory(basePrice: 0.0189, points: 24),
            createdAt: Date().addingTimeInterval(-86400 * 4),
            updatedAt: Date(),
            videoName: nil
        )
    ]

    private static func generateMockPriceHistory(basePrice: Double, points: Int) -> [PricePoint] {
        var history: [PricePoint] = []
        let now = Date()

        for i in 0..<points {
            let timestamp = now.addingTimeInterval(Double(-i * 3600)) // Hourly data
            // Create realistic price movement (random walk)
            let randomChange = Double.random(in: 0.85...1.15)
            let price = basePrice * randomChange * (Double(i + 1) / Double(points))
            let volume = Double.random(in: 1000...5000)

            history.append(PricePoint(
                timestamp: timestamp,
                price: price,
                volume: volume
            ))
        }

        return history.reversed() // Oldest to newest
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
