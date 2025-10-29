//
//  ContentDetailView.swift
//  Instnce
//
//  Created by Wafi Choudhury on 10/21/25.
//

import SwiftUI
import AVKit
import WebKit
import Charts

struct ContentDetailView: View {
    let content: Content
    @Environment(\.dismiss) var dismiss
    @State private var investmentAmount: String = "10"
    @State private var showInvestmentSheet = false
    @State private var isBuyExpanded = false
    
    // Chart state
    @State private var selectedTimeframe: Timeframe = .d1
    @State private var selectedPoint: PricePoint?
    
    // Cached filtered history
    @State private var displayedHistory: [PricePoint] = []

    // MARK: - Series wrapper matching tutorial shape
    struct PetData: Identifiable { let id = UUID(); let year: Int; let population: Double }
    private var priceSeriesData: [(type: String, petData: [PetData])] {
        let seriesPoints: [PetData] = displayedHistory.enumerated().map { idx, p in
            PetData(year: idx, population: p.price)
        }
        return [(type: "price", petData: seriesPoints)]
    }
    
    var tokensToReceive: Int {
        guard let amount = Double(investmentAmount) else { return 0 }
        return content.tokensForAmount(amount)
    }
    
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
                    
                    // Title + price (minimal)
                    VStack(alignment: .leading, spacing: 10) {
                        // Title
                        Text(content.title)
                            .font(.system(size: 18, weight: .semibold))
                            .lineLimit(2)
                        
                        // Price + change pill
                        HStack(spacing: 10) {
                            Text(currentDisplayedPrice)
                                .font(.system(size: 30, weight: .bold))
                            ChangePill(
                                text: content.formattedPriceChange,
                                positive: content.isPositiveChange
                            )
                        }
                        
                        // Meta (platform · creator)
                        HStack(spacing: 6) {
                            Image(systemName: content.platform.icon)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(.secondary)
                            Text("\(content.platform.displayName) · \(content.creatorName)")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                        }
                        
                        // Token (footnote)
                        HStack(spacing: 6) {
                            Text("Token")
                                .font(.system(size: 11))
                                .foregroundStyle(.tertiary)
                            Text(content.tokenAddress)
                                .font(.system(size: 11))
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                                .truncationMode(.middle)
                            Spacer()
                            Button("Copy") { UIPasteboard.general.string = content.tokenAddress }
                                .font(.system(size: 12, weight: .medium))
                        }
                    }
                    .padding(.horizontal)
                    
                    // Timeframe selector
                    TimeFrameSelector(selectedTimeframe: $selectedTimeframe)
                        .padding(.horizontal)
                    
                    // Chart (background-free, draggable) - Using cached @State data
                    chartView
                        .frame(height: 300)
                        .padding(.horizontal)
                    
                    // Media (video/web) renderer - now smaller emphasis
                    ContentMediaView(
                        urlString: content.url,
                        thumbnailUrl: content.thumbnailUrl,
                        videoName: content.videoName,
                        height: 170
                    )
                    
                    // Stats chips (minimal)
                    HStack(spacing: 8) {
                        StatChip(title: "Market Cap", value: content.formattedMarketCap)
                        StatChip(title: "24h Vol", value: content.formattedVolume)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 120) // leave space for bottom buy panel
                }
                .padding(.top, 12)
            }
            
            // Bottom buy panel (collapsible)
            VStack {
                Spacer()
                if isBuyExpanded {
                    VStack(spacing: 12) {
                        HStack {
                            Text("Buy")
                                .font(.system(size: 14, weight: .semibold))
                            Spacer()
                            Button(action: { withAnimation { isBuyExpanded = false } }) {
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .buttonStyle(.plain)
                        }
                        .foregroundStyle(.secondary)
                        
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
                } else {
                    HStack {
                        Spacer()
                        Button(action: { withAnimation { isBuyExpanded = true } }) {
                            Text("Buy")
                                .font(.system(size: 15, weight: .semibold))
                                .padding(.horizontal, 18)
                                .padding(.vertical, 10)
                                .background(Capsule().fill(Color(.label)))
                                .foregroundStyle(Color(.systemBackground))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                }
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .navigationBarHidden(true)
        .onAppear {
            updateDisplayedHistory()
        }
        .onChange(of: selectedTimeframe) { _, _ in
            updateDisplayedHistory()
        }
    }
    
    // MARK: - Chart View (tutorial pattern with our data)
    @ViewBuilder
    private var chartView: some View {
        Chart(priceSeriesData, id: \.type) { dataSeries in
            ForEach(dataSeries.petData) { data in
                LineMark(
                    x: .value("Index", data.year),
                    y: .value("Price", data.population)
                )
            }
            .foregroundStyle(by: .value("Series", dataSeries.type))
            .symbol(by: .value("Series", dataSeries.type))
        }
        .chartXScale(domain: 0...(max(1, priceSeriesData.first?.petData.count ?? 1)))
        .aspectRatio(1, contentMode: .fit)
    }
    
    // MARK: - Chart helpers
    var currentDisplayedPrice: String {
        if let sel = selectedPoint { return "$\(String(format: "%.4f", sel.price))" }
        return content.formattedPrice
    }
    
    // Update the cached history - called once on appear and when timeframe changes
    private func updateDisplayedHistory() {
        let points = content.priceHistory
        guard let maxDate = points.map({ $0.timestamp }).max() else {
            displayedHistory = points
            return
        }
        let cutoff: TimeInterval
        switch selectedTimeframe {
        case .d1: cutoff = -24 * 3600
        case .w1: cutoff = -7 * 24 * 3600
        case .m1: cutoff = -30 * 24 * 3600
        case .m3: cutoff = -90 * 24 * 3600
        case .y1: cutoff = -365 * 24 * 3600
        case .y5: cutoff = -5 * 365 * 24 * 3600
        }
        let start = maxDate.addingTimeInterval(cutoff)
        displayedHistory = points
            .filter { $0.timestamp >= start }
            .sorted { $0.timestamp < $1.timestamp }
    }
}

// MARK: - Supporting Views

struct ChangePill: View {
    let text: String
    let positive: Bool
    
    var body: some View {
        Text(text)
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(positive ? .green : .red)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill((positive ? Color.green : Color.red).opacity(0.1))
            )
    }
}

struct BlurView: UIViewRepresentable {
    let style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}
