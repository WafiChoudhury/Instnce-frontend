//
//  ContentCard.swift
//  Instnce
//
//  Created by Wafi Choudhury on 10/17/25.
//

import SwiftUI

struct ContentCard: View {
    let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Media (embedded video/player)
            ContentMediaView(
                urlString: content.url,
                thumbnailUrl: content.thumbnailUrl,
                videoName: content.videoName,
                height: 240
            )
            .frame(height: 240)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            // Price front-and-center
            HStack(spacing: 10) {
                Text(content.formattedPrice)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.primary)

                HStack(spacing: 5) {
                    Image(systemName: content.isPositiveChange ? "arrow.up.right" : "arrow.down.right")
                        .font(.system(size: 12, weight: .bold))
                    Text(content.formattedPriceChange)
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundStyle(content.isPositiveChange ? .green : .red)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill((content.isPositiveChange ? Color.green : Color.red).opacity(0.12))
                )
                Spacer()
            }

            // Video title styled more like descriptive text
            VStack(alignment: .leading, spacing: 6) {
                Text(content.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.primary)
                    .lineLimit(2)

            }

            // Divider
            Divider()
                .padding(.vertical, 4)

            // Stats Row
            HStack(spacing: 18) {
                StatItem(icon: "chart.line.uptrend.xyaxis", label: content.formattedMarketCap)
                StatItem(icon: "arrow.left.arrow.right", label: content.formattedVolume)
                StatItem(icon: "person.2.fill", label: content.formattedHolders)
            }

            // Buy Button
            NavigationLink(destination: ContentDetailView(content: content)) {
                HStack {
                    Text("Buy Now")
                        .font(.system(size: 15, weight: .semibold))
                    Spacer()
                    Image(systemName: "arrow.right")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundStyle(Color.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.label))
                )
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 4)
                .shadow(color: Color.black.opacity(0.04), radius: 1, x: 0, y: 1)
        )
    }
}

struct StatItem: View {
    let icon: String
    let label: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.secondary)
        }
    }
}
