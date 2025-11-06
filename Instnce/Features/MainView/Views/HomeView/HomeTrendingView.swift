//
//  HomeTrendingView.swift
//  Instnce
//
//  Created by Wafi Choudhury on 10/17/25.
//

import SwiftUI
import Supabase



struct HomeTrendingView: View {
    @ObservedObject var viewModel: HomeTrendingViewModel
    @ObservedObject var authViewModel: AuthViewModel

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
                    if viewModel.isLoading && viewModel.trendingContent.isEmpty {
                        loadingState
                    } else {
                        LazyVStack(spacing: 20) {
                            ForEach(viewModel.trendingContent) { content in
                                ContentCard(content: content)
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.vertical, 20)
            }
            .background(Color(.systemBackground).ignoresSafeArea())
            .task { await viewModel.loadIfNeeded() }
            .refreshable { await viewModel.refresh() }
        }
    }
    
    private var loadingState: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(.blue)
            Text("Loading content...")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
    
    // Data fetch types remain for decoding records
}

//#Preview {
//    HomeTrendingView(viewModel: HomeTrendingViewModel(), authViewModel: AuthViewModel())
//        .environmentObject(AuthModel())
//}
