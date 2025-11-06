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
    @State private var selectedIndex: Int? = nil
    // Cached filtered history
    @State private var displayedHistory: [PricePoint] = []

    // MARK: - Series wrapper
    struct PriceData: Identifiable { let id = UUID(); let time: Int; let price: Double }
    private var priceSeriesData: [(type: String, priceData: [PriceData])] {
        let seriesPoints: [PriceData] = displayedHistory.enumerated().map { idx, p in
            PriceData(time: idx, price: p.price)
        }
        return [(type: "price", priceData: seriesPoints)]
    }
    
    var tokensToReceive: Int {
        guard let amount = Double(investmentAmount) else { return 0 }
        return content.tokensForAmount(amount)
    }
    
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Top controls
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.primary)
                                .padding(10)
                                .background(Circle().fill(Color(.systemGray6)))
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                        
                        Button(action: {
                            // share
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.primary)
                                .padding(10)
                                .background(Circle().fill(Color(.systemGray6)))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 20)
                    
                    // Media (video/content) - moved above price
                    ContentMediaView(
                        urlString: content.url,
                        thumbnailUrl: content.thumbnailUrl,
                        videoName: content.videoName,
                        height: 200,
                        showPadding: true
                    )
                    .padding(.bottom, 20)
                    
                    // ROBINHOOD STYLE: Price section
                    VStack(alignment: .leading, spacing: 8) {
                        // Price + change
                        HStack(alignment: .firstTextBaseline, spacing: 10) {
                            Text(currentDisplayedPrice)
                                .font(.system(size: 36, weight: .medium))
                                .foregroundStyle(.primary)
                            ChangePill(
                                text: content.formattedPriceChange,
                                positive: content.isPositiveChange
                            )
                        }
                        
                        // Title below price (Robinhood style)
                        Text(content.title)
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                        
                        // Meta (platform · creator)
                        HStack(spacing: 6) {
                            Image(systemName: content.platform.icon)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(.tertiary)
                            Text("\(content.platform.displayName) · \(content.creatorName)")
                                .font(.system(size: 13))
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.top, 2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                    
                    // Chart (much larger, Robinhood style)
                    chartView
                        .frame(height: 280)
                        .padding(.horizontal, 8)
                        .padding(.bottom, 16)
                    
                    // Timeframe selector (below chart, Robinhood style)
                    RobinhoodTimeFrameSelector(selectedTimeframe: $selectedTimeframe)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                    
                    // Stats grid (Robinhood style)
                    VStack(spacing: 12) {
                        StatRow(
                            label: "Market Cap",
                            value: content.formattedMarketCap
                        )
                        Divider().padding(.horizontal, 20)
                        StatRow(
                            label: "24h Volume",
                            value: content.formattedVolume
                        )
                        Divider().padding(.horizontal, 20)
                        StatRow(
                            label: "Token",
                            value: content.tokenAddress,
                            showCopy: true
                        )
                    }
                    .padding(.bottom, 24)
                    
                    Spacer(minLength: 120)
                }
                .padding(.top, 8)
            }
            
            // Bottom buy panel (Robinhood green button style)
            VStack {
                Spacer()
                if isBuyExpanded {
                    VStack(spacing: 16) {
                        HStack {
                            Text("Buy \(content.title)")
                                .font(.system(size: 17, weight: .semibold))
                            Spacer()
                            Button(action: { withAnimation(.spring(response: 0.3)) { isBuyExpanded = false } }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                        
                        // Amount input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Amount in USD")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(.secondary)
                            TextField("0", text: $investmentAmount)
                                .keyboardType(.decimalPad)
                                .font(.system(size: 24, weight: .medium))
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .strokeBorder(Color(.systemGray4), lineWidth: 1)
                                )
                        }
                        
                        // Estimated tokens
                        HStack {
                            Text("Estimated tokens")
                                .font(.system(size: 13))
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("~\(tokensToReceive)")
                                .font(.system(size: 15, weight: .medium))
                        }
                        
                        // Robinhood green buy button
                        Button(action: { showInvestmentSheet = true }) {
                            Text("Review Order")
                                .font(.system(size: 17, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 24)
                                        .fill(Color(red: 0.0, green: 0.78, blue: 0.33))
                                )
                                .foregroundStyle(.white)
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.1), radius: 20, y: -5)
                    )
                    .padding(.horizontal, 12)
                    .padding(.bottom, 12)
                } else {
                    Button(action: { withAnimation(.spring(response: 0.3)) { isBuyExpanded = true } }) {
                        Text("Buy")
                            .font(.system(size: 17, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(Color(red: 0.0, green: 0.78, blue: 0.33))
                            )
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 20)
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
    
    // MARK: - Chart View (Robinhood style - subtle gradient)
    @ViewBuilder
    private var chartView: some View {
        let baseColor = content.isPositiveChange ? Color(red: 0.0, green: 0.78, blue: 0.33) : Color(red: 1.0, green: 0.33, blue: 0.33)
        let areaGradient = LinearGradient(
            gradient: Gradient(colors: [baseColor.opacity(0.1), baseColor.opacity(0.0)]),
            startPoint: .top,
            endPoint: .bottom
        )
        
        Chart(priceSeriesData, id: \.type) { dataSeries in
            // Very subtle gradient area
            ForEach(dataSeries.priceData) { data in
                AreaMark(
                    x: .value("Time", data.time),
                    y: .value("Price", data.price)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(areaGradient)
            }

            // Line on top (thicker for Robinhood style)
            ForEach(dataSeries.priceData) { data in
                LineMark(
                    x: .value("Time", data.time),
                    y: .value("Price", data.price)
                )
                .interpolationMethod(.catmullRom)
                .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                .foregroundStyle(baseColor)

                // Selection dot
                if let sel = selectedIndex, sel == data.time {
                    PointMark(
                        x: .value("Time", data.time),
                        y: .value("Price", data.price)
                    )
                    .symbolSize(80)
                    .foregroundStyle(baseColor)
                    
                    PointMark(
                        x: .value("Time", data.time),
                        y: .value("Price", data.price)
                    )
                    .symbolSize(40)
                    .foregroundStyle(Color(.systemBackground))
                }
            }
        }
        .chartXScale(domain: 0...(max(1, priceSeriesData.first?.priceData.count ?? 1)))
        .chartLegend(.hidden)
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartOverlay { proxy in
            GeometryReader { geo in
                Rectangle().fill(.clear).contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let x = value.location.x - geo[proxy.plotAreaFrame].origin.x
                                if let val: Double = proxy.value(atX: x) {
                                    let idx = Int(val.rounded())
                                    let count = priceSeriesData.first?.priceData.count ?? 0
                                    selectedIndex = max(0, min(max(0, count - 1), idx))
                                }
                            }
                            .onEnded { _ in selectedIndex = nil }
                    )
            }
        }
    }
    
    // MARK: - Chart helpers
    var currentDisplayedPrice: String {
        if let idx = selectedIndex, idx >= 0, idx < displayedHistory.count {
            return "$\(String(format: "%.4f", displayedHistory[idx].price))"
        }
        return content.formattedPrice
    }
    
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
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(positive ? Color(red: 0.0, green: 0.78, blue: 0.33) : Color(red: 1.0, green: 0.33, blue: 0.33))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill((positive ? Color(red: 0.0, green: 0.78, blue: 0.33) : Color(red: 1.0, green: 0.33, blue: 0.33)).opacity(0.12))
            )
    }
}

// Robinhood-style timeframe selector
struct RobinhoodTimeFrameSelector: View {
    @Binding var selectedTimeframe: Timeframe
    
    let timeframes: [Timeframe] = [.d1, .w1, .m1, .m3, .y1, .y5]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(timeframes, id: \.self) { tf in
                Button(action: { selectedTimeframe = tf }) {
                    Text(tf.rawValue)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(selectedTimeframe == tf ? .primary : .secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(selectedTimeframe == tf ? Color(.systemGray5) : Color.clear)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6).opacity(0.5))
        )
    }
}

// Robinhood-style stat row
struct StatRow: View {
    let label: String
    let value: String
    var showCopy: Bool = false
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
            Spacer()
            HStack(spacing: 8) {
                Text(value)
                    .font(.system(size: 15, weight: .medium))
                    .lineLimit(1)
                    .truncationMode(.middle)
                if showCopy {
                    Button(action: { UIPasteboard.general.string = value }) {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.blue)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

struct BlurView: UIViewRepresentable {
    let style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}
