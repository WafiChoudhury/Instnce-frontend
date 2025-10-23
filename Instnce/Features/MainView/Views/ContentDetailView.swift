//
//  ContentDetailView.swift
//  Instnce
//
//  Created by Wafi Choudhury on 10/21/25.
//

import SwiftUI
import AVKit
import Charts

struct ContentDetailView: View {
    let content: Content
    @Environment(\.dismiss) var dismiss
    @State private var investmentAmount: String = "10"
    @State private var showInvestmentSheet = false

    var tokensToReceive: Int {
        guard let amount = Double(investmentAmount) else { return 0 }
        return content.tokensForAmount(amount)
    }

    // Using content.priceHistory (existing PricePoint) for chart
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Top controls
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .padding(10)
                                .background(Circle().fill(Color(.systemGray6)))
                        }
                        .buttonStyle(.plain)

                        Spacer()

                        Button(action: {
                            // share
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .padding(10)
                                .background(Circle().fill(Color(.systemGray6)))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal)

                    // Video or thumbnail
                    if let videoName = content.videoName,
                       let url = Bundle.main.url(forResource: videoName, withExtension: "mp4") {
                        VideoPlayer(player: AVPlayer(url: url))
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .padding(.horizontal)
                    } else {
                        AsyncImage(url: URL(string: content.thumbnailUrl ?? "")) { img in
                            img.resizable()
                                .scaledToFill()
                                .frame(height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .padding(.horizontal)
                        } placeholder: {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(.systemGray5))
                                .frame(height: 200)
                                .padding(.horizontal)
                        }
                    }

                    // Title + price
                    VStack(alignment: .leading, spacing: 6) {
                        Text(content.title)
                            .font(.system(size: 20, weight: .semibold))
                        HStack(alignment: .firstTextBaseline, spacing: 12) {
                            Text(content.formattedPrice)
                                .font(.system(size: 28, weight: .bold))
                            Text(content.formattedPriceChange)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(content.isPositiveChange ? .green : .red)
                        }
                    }
                    .padding(.horizontal)

                    // Robinhood-style line chart (minimal)
                    Chart {
                        ForEach(content.priceHistory) { pt in
                            LineMark(
                                x: .value("Time", pt.timestamp),
                                y: .value("Price", pt.price)
                            )
                            .interpolationMethod(.catmullRom)
                            .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [content.isPositiveChange ? .green : .red, Color(.systemBackground)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        }

                        // Fill under the line
                        ForEach(content.priceHistory) { pt in
                            AreaMark(
                                x: .value("Time", pt.timestamp),
                                y: .value("Price", pt.price)
                            )
                            .interpolationMethod(.catmullRom)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [(content.isPositiveChange ? Color.green : Color.red).opacity(0.18), Color.clear],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        }
                    }
                    .chartYAxis(.hidden)
                    .chartXAxis(.hidden)
                    .frame(height: 150)
                    .padding(.horizontal)

                    // Compact stats row
                    HStack(spacing: 16) {
                        StatCardSmall(title: "Market Cap", value: content.formattedMarketCap, systemIcon: "chart.bar.fill")
                        StatCardSmall(title: "24h Vol", value: content.formattedVolume, systemIcon: "arrow.left.arrow.right")
                        StatCardSmall(title: "Holders", value: content.formattedHolders, systemIcon: "person.2.fill")
                    }
                    .padding(.horizontal)


                    Spacer(minLength: 120) // leave space for bottom buy panel
                }
                .padding(.top, 12)
            }

            // Bottom buy panel (compact)
            VStack {
                Spacer()
                VStack(spacing: 12) {
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Investment")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                            Text("$\(investmentAmount)")
                                .font(.system(size: 20, weight: .semibold))
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Estimated tokens")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                            Text("~\(tokensToReceive)")
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }

                    HStack(spacing: 8) {
                        TextField("10", text: $investmentAmount)
                            .keyboardType(.decimalPad)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 12)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
                            .frame(maxWidth: 120)

                        Button(action: { showInvestmentSheet = true }) {
                            Text("Buy")
                                .font(.system(size: 16, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color(.label)))
                                .foregroundStyle(Color(.systemBackground))
                        }
                    }
                }
                .padding(16)
                .background(BlurView(style: .systemThinMaterial))
                .cornerRadius(16)
                .padding(.horizontal)
                .padding(.bottom, 12)
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .navigationBarHidden(true)
    
    }
}

// Small stat card used in the trimmed view
struct StatCardSmall: View {
    let title: String
    let value: String
    let systemIcon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: systemIcon)
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 14, weight: .semibold))
            Text(title)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemBackground)))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(.separator).opacity(0.15)))
    }
}

// Convenience blur wrapper
struct BlurView: UIViewRepresentable {
    let style: UIBlurEffect.Style
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

#Preview {
    NavigationStack {
        ContentDetailView(content: Content.mockData[0])
    }
}
