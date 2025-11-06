//
//  PortfolioChart.swift
//  Instnce
//
//  Portfolio value chart component
//

import SwiftUI
import Charts

struct PortfolioChart: View {
    let portfolioHistory: [PortfolioValueSnapshot]
    let currentValue: Double
    let isPositive: Bool
    
    @State private var selectedIndex: Int? = nil
    
    private var chartData: [ChartDataPoint] {
        // If no history and current value is 0, show empty chart
        if portfolioHistory.isEmpty && currentValue == 0 {
            return []
        }
        
        var dataPoints: [ChartDataPoint] = []
        
        // Add historical data points
        for (index, snapshot) in portfolioHistory.enumerated() {
            dataPoints.append(ChartDataPoint(
                index: index,
                value: snapshot.portfolioValueUsd,
                timestamp: ISO8601DateFormatter().date(from: snapshot.timestamp) ?? Date()
            ))
        }
        
        // Add current value as the last point (if different from last history point)
        if let lastHistoryValue = portfolioHistory.last?.portfolioValueUsd {
            if abs(currentValue - lastHistoryValue) > 0.01 {
                dataPoints.append(ChartDataPoint(
                    index: portfolioHistory.count,
                    value: currentValue,
                    timestamp: Date()
                ))
            }
        } else if currentValue > 0 {
            // No history, but we have a current value
            dataPoints.append(ChartDataPoint(
                index: 0,
                value: currentValue,
                timestamp: Date()
            ))
        }
        
        return dataPoints
    }
    
    var body: some View {
        if chartData.isEmpty {
            // Show empty state when no data
            VStack(spacing: 8) {
                Text("No data yet")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                Text("Chart will appear as balance changes")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary.opacity(0.7))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            let baseColor = isPositive ? Color(red: 0.0, green: 0.78, blue: 0.33) : Color(red: 1.0, green: 0.33, blue: 0.33)
            let areaGradient = LinearGradient(
                gradient: Gradient(colors: [baseColor.opacity(0.1), baseColor.opacity(0.0)]),
                startPoint: .top,
                endPoint: .bottom
            )
            
            Chart(chartData) { point in
                // Subtle gradient area
                AreaMark(
                    x: .value("Time", point.index),
                    y: .value("Value", point.value)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(areaGradient)
                
                // Thicker line
                LineMark(
                    x: .value("Time", point.index),
                    y: .value("Value", point.value)
                )
                .interpolationMethod(.catmullRom)
                .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                .foregroundStyle(baseColor)
                
                // Selection rings
                if let selectedIndex = selectedIndex, point.index == selectedIndex {
                    PointMark(
                        x: .value("Time", point.index),
                        y: .value("Value", point.value)
                    )
                    .symbolSize(80)
                    .foregroundStyle(baseColor)
                    
                    PointMark(
                        x: .value("Time", point.index),
                        y: .value("Value", point.value)
                    )
                    .symbolSize(40)
                    .foregroundStyle(Color(.systemBackground))
                }
            }
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
                                        let count = chartData.count
                                        selectedIndex = max(0, min(max(0, count - 1), idx))
                                    }
                                }
                                .onEnded { _ in selectedIndex = nil }
                        )
                }
            }
        }
    }
}

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let index: Int
    let value: Double
    let timestamp: Date
    
    init(index: Int, value: Double, timestamp: Date = Date()) {
        self.index = index
        self.value = value
        self.timestamp = timestamp
    }
}

