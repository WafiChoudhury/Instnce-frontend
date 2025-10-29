//
//  FinancesView.swift
//  Instnce
//
//  Robinhood-style clean interface
//

import SwiftUI
import PrivySDK
import Charts

struct FinancesView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var showAddMoney = false
    @State private var balance: Double = 50.0
    @State private var portfolioValue: Double = 50.0
    @State private var selectedTimeframe: Timeframe = .day
    
    enum Timeframe: String, CaseIterable {
        case day = "1D"
        case week = "1W"
        case month = "1M"
        case threeMonth = "3M"
        case year = "1Y"
        case all = "ALL"
    }
    
    private var todayPnL: Double {
        portfolioValue - balance
    }
    
    private var todayPnLPercentage: Double {
        balance > 0 ? (todayPnL / balance) * 100 : 0
    }
    
    private var isPositive: Bool {
        todayPnL >= 0
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Top Section with Chart
            VStack(spacing: 0) {
                // Portfolio value - FIXED above chart
                VStack(alignment: .leading, spacing: 4) {
                    Text("$\(portfolioValue, specifier: "%.2f")")
                        .font(.system(size: 36, weight: .regular))
                    
                    HStack(spacing: 6) {
                        Text("\(isPositive ? "+" : "")$\(abs(todayPnL), specifier: "%.2f") (\(isPositive ? "+" : "")\(todayPnLPercentage, specifier: "%.2f")%)")
                            .font(.system(size: 15))
                            .foregroundStyle(isPositive ? .green : .red)
                        
                        Text("Today")
                            .font(.system(size: 15))
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 24)
                .background(Color(.systemBackground))
                .zIndex(1)
                
                // Chart - draggable
                PortfolioChart(
                    portfolioValue: portfolioValue,
                    balance: balance,
                    isPositive: isPositive
                )
                .frame(height: 300)
            }
            
            // MARK: - Timeframe Buttons
            HStack(spacing: 0) {
                ForEach(Timeframe.allCases, id: \.self) { timeframe in
                    Button {
                        selectedTimeframe = timeframe
                    } label: {
                        Text(timeframe.rawValue)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(selectedTimeframe == timeframe ? .blue : .secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                }
            }
            .background(Color(.systemBackground))
            
            Spacer().frame(height: 24)
            
            // MARK: - Buying Power
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Buying Power")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                    Text("$\(balance, specifier: "%.2f")")
                        .font(.system(size: 17))
                }
                
                Spacer()
                
                Button {
                    showAddMoney = true
                } label: {
                    Text("Add Money")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.green)
                        .cornerRadius(20)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
            
            Divider()
                .padding(.horizontal, 16)
            
            Spacer()
            
            // MARK: - Wallet Section
            if let wallet = authViewModel.embeddedWallet {
                VStack(spacing: 8) {
                    Text("Wallet Address")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        Text(wallet.address)
                            .font(.system(size: 12, design: .monospaced))
                            .lineLimit(1)
                            .truncationMode(.middle)
                        
                        Button {
                            UIPasteboard.general.string = wallet.address
                        } label: {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 14))
                                .foregroundStyle(.blue)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            } else {
                VStack(spacing: 12) {
                    Text("No wallet connected")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                    
                    Button {
                        Task { await authViewModel.createWallet() }
                    } label: {
                        Text("Create Wallet")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.black)
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
            
            Spacer()
            
            Button {
                Task { await authViewModel.logout() }
            } label: {
                Text("Log Out")
                    .font(.system(size: 13))
                    .foregroundStyle(.blue)
            }
            .padding(.bottom, 32)
        }
        .background(Color(.systemBackground))
        .sheet(isPresented: $showAddMoney) {
            AddMoneyView(balance: $balance)
        }
    }
}

// MARK: - Portfolio Chart

struct PortfolioChart: View {
    let portfolioValue: Double
    let balance: Double
    let isPositive: Bool
    
    @State private var dragOffset: CGFloat = 0
    @State private var selectedIndex: Int? = nil
    
    private var chartData: [ChartDataPoint] {
        if portfolioValue == 0 && balance == 0 {
            return (0..<40).map { ChartDataPoint(index: $0, value: 0) }
        }
        
        let pnl = portfolioValue - balance
        
        return (0..<40).map { index in
            let progress = Double(index) / 39.0
            let smoothVariation = sin(Double(index) * 0.3) * abs(pnl) * 0.2
            let value = balance + (pnl * progress) + smoothVariation
            return ChartDataPoint(index: index, value: max(0, value))
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            Chart(chartData) { point in
                AreaMark(
                    x: .value("Time", point.index),
                    y: .value("Value", point.value)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: isPositive
                            ? [Color.green.opacity(0.25), Color.green.opacity(0.0)]
                            : [Color.red.opacity(0.25), Color.red.opacity(0.0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)
                
                LineMark(
                    x: .value("Time", point.index),
                    y: .value("Value", point.value)
                )
                .foregroundStyle(isPositive ? Color.green : Color.red)
                .lineStyle(StrokeStyle(lineWidth: 2))
                .interpolationMethod(.catmullRom)
                
                // Show point indicator when dragging
                if let selectedIndex = selectedIndex, point.index == selectedIndex {
                    PointMark(
                        x: .value("Time", point.index),
                        y: .value("Value", point.value)
                    )
                    .foregroundStyle(isPositive ? Color.green : Color.red)
                    .symbolSize(50)
                }
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let xPosition = value.location.x
                        let chartWidth = geometry.size.width
                        let index = Int((xPosition / chartWidth) * CGFloat(chartData.count - 1))
                        let clampedIndex = max(0, min(chartData.count - 1, index))
                        selectedIndex = clampedIndex
                    }
                    .onEnded { _ in
                        withAnimation(.easeOut(duration: 0.2)) {
                            selectedIndex = nil
                        }
                    }
            )
        }
    }
}

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let index: Int
    let value: Double
}
