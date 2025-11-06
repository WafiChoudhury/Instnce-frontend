//
//  HomeTrendingViewModel.swift
//  Instnce
//
//  Persists trending content across tab switches and controls fetching
//

import Foundation
import Supabase
import Combine
@MainActor
final class HomeTrendingViewModel: ObservableObject {
    @Published var trendingContent: [Content] = []
    @Published var isLoading: Bool = false
    @Published var lastLoadedAt: Date? = nil

    struct ContentRecord: Codable, Identifiable {
        let id: String
        let url: String
        let title: String
        let description: String
        let thumbnail_url: String?
        let platform: String
        let creator_name: String
        let creator_handle: String?
        let token_address: String
        let current_price_usd: Double
        let price_change_24h_percent: Double
        let market_cap_usd: Double
        let volume_24h_usd: Double
        let total_supply: Double
        let holder_count: Int
        let view_count: Int
        let engagement_score: Double
        let is_trending: Bool
        let video_name: String?
        let created_at: String
        let updated_at: String
    }

    struct TokenPriceRecord: Codable {
        let id: String
        let content_id: String
        let price_usd: Double
        let volume_usd: Double?
        let timestamp: String
        let timeframe: String
    }

    func loadIfNeeded() async {
        if !trendingContent.isEmpty { return }
        await load(force: false)
    }

    func refresh() async {
        await load(force: true)
    }

    private func load(force: Bool) async {
        if isLoading { return }
        if !force && !trendingContent.isEmpty { return }

        isLoading = true
        defer { isLoading = false }

        do {
            let contentRecords: [ContentRecord] = try await supabase
                .from("content")
                .select()
                .eq("is_trending", value: true)
                .order("engagement_score", ascending: false)
                .limit(10)
                .execute()
                .value

            // Fetch all price histories in parallel
            let contentWithHistories = try await withThrowingTaskGroup(of: (ContentRecord, [PricePoint]).self) { group in
                var results: [(ContentRecord, [PricePoint])] = []
                
                for record in contentRecords {
                    group.addTask {
                        let priceHistoryRecords: [TokenPriceRecord] = try await supabase
                            .from("token_prices")
                            .select()
                            .eq("content_id", value: record.id)
                            .order("timestamp", ascending: true)
                            .execute()
                            .value
                        
                        let priceHistory = priceHistoryRecords.map { priceRecord in
                            PricePoint(
                                id: priceRecord.id,
                                timestamp: ISO8601DateFormatter().date(from: priceRecord.timestamp) ?? Date(),
                                price: priceRecord.price_usd,
                                volume: priceRecord.volume_usd
                            )
                        }
                        
                        return (record, priceHistory)
                    }
                }
                
                for try await result in group {
                    results.append(result)
                }
                
                return results
            }
            
            // Map to Content model
            let contents = contentWithHistories.map { record, priceHistory in
                Content(
                    id: record.id,
                    url: record.url,
                    title: record.title,
                    description: record.description,
                    thumbnailUrl: record.thumbnail_url,
                    platform: Content.Platform(rawValue: record.platform) ?? .other,
                    creatorName: record.creator_name,
                    creatorHandle: record.creator_handle,
                    tokenAddress: record.token_address,
                    currentPrice: record.current_price_usd,
                    priceChange24h: record.price_change_24h_percent,
                    marketCap: record.market_cap_usd,
                    volume24h: record.volume_24h_usd,
                    totalSupply: Int(record.total_supply),
                    holderCount: record.holder_count,
                    viewCount: record.view_count,
                    engagementScore: record.engagement_score,
                    isTrending: record.is_trending,
                    priceHistory: priceHistory,
                    createdAt: ISO8601DateFormatter().date(from: record.created_at) ?? Date(),
                    updatedAt: ISO8601DateFormatter().date(from: record.updated_at) ?? Date(),
                    videoName: record.video_name
                )
            }

            trendingContent = contents
            lastLoadedAt = Date()
        } catch {
            // Simple print for now; could add dedicated error handling UI later
            print("⚠️ Failed to load trending content: \(error.localizedDescription)")
        }
    }
}


