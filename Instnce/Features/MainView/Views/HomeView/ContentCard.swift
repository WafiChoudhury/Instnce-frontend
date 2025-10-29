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
            // Thumbnail
            AsyncImage(url: URL(string: content.thumbnailUrl ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            } placeholder: {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray5).opacity(0.4))
                    .frame(height: 180)
            }

            // Title & Description
            VStack(alignment: .leading, spacing: 6) {
                Text(content.title)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                Text(content.description)
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            // Price & Change
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current Price")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)

                    Text(content.formattedPrice)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.primary)
                }

                Spacer()

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
            Button {
                // Future investment action
            } label: {
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
