//
//  HomeTrendingView.swift
//  Instnce
//
//  Created by Wafi Choudhury on 10/17/25.
//

import SwiftUI
import Supabase



struct HomeTrendingView: View {
    @State private var trendingContent: [Content] = []
    @State private var isLoading = false

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

    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Discover")
                            .font(.system(size: 34, weight: .bold))
                        Text("Trending content right now")
                            .font(.system(size: 16))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)

                    // Trending Cards
                    LazyVStack(spacing: 20) {
                        ForEach(trendingContent) { content in
                            NavigationLink(destination: ContentDetailView(content: content)) {
                                ContentCard(content: content)
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical, 20)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .onAppear {
                fetchTrendingContent()
            }
        }
    }
    
    // MARK: - Data Fetching
    private func fetchTrendingContent() {
        
        Task{
            
            isLoading = true
            let contentRecords: [ContentRecord] = try await supabase
                .from("content")
                .select()
                .eq("is_trending", value: true)
                .order("engagement_score", ascending: false)
                .limit(10)
                .execute()
                .value
            
            print(contentRecords)
            var contents: [Content] = []
          
            for record in contentRecords {
                // Fetch price history for this content
                let priceHistoryRecords: [TokenPriceRecord] = try await supabase
                    .from("token_prices")
                    .select()
                    .eq("content_id", value: record.id)
                    .order("timestamp", ascending: true)
                    .execute()
                    .value
                
                // Convert TokenPriceRecords to PricePoints
                let priceHistory = priceHistoryRecords.map { priceRecord in
                    PricePoint(
                        id: priceRecord.id,
                        timestamp: ISO8601DateFormatter().date(from: priceRecord.timestamp) ?? Date(),
                        price: priceRecord.price_usd,
                        volume: priceRecord.volume_usd
                    )
                }
                
                // Map database record to Content model
                let content = Content(
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
                
                contents.append(content)
            }
            
            // Update state on main thread
            await MainActor.run {
                trendingContent = contents
                isLoading = false
            }
            
        }
    
    }
}

#Preview {
    HomeTrendingView()
        .environmentObject(AuthModel())
}
