//
//  TimeframeSelector.swift
//  Instnce
//
//  Timeframe selection buttons
//

import SwiftUI

enum PortfolioTimeframe: String, CaseIterable {
    case day = "1D"
    case week = "1W"
    case month = "1M"
    case threeMonth = "3M"
    case year = "1Y"
    case all = "ALL"
}

struct TimeframeSelector: View {
    @Binding var selectedTimeframe: PortfolioTimeframe
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(PortfolioTimeframe.allCases, id: \.self) { timeframe in
                Button {
                    selectedTimeframe = timeframe
                } label: {
                    Text(timeframe.rawValue)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(selectedTimeframe == timeframe ? .primary : .secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(selectedTimeframe == timeframe ? Color(.systemGray5) : Color.clear)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6).opacity(0.5))
                .padding(.horizontal, 16)
        )
    }
}

