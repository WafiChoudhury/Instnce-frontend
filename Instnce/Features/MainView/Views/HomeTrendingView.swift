//
//  HomeTrendingView.swift
//  Instnce
//
//  Created by Wafi Choudhury on 10/17/25.
//

import SwiftUI

struct HomeTrendingView: View {
    @State private var trendingContent: [Content] = Content.mockData

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
        }
    }
}

#Preview {
    HomeTrendingView()
        .environmentObject(AuthModel())
}
