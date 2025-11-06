//
//  PortfolioHeaderView.swift
//  Instnce
//
//  Portfolio value header with P&L display
//

import SwiftUI

struct PortfolioHeaderView: View {
    let portfolioValue: Double
    let todayPnL: Double
    let todayPnLPercentage: Double
    let isPositive: Bool
    
    var body: some View {
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
        .padding(.top, 58)
        .padding(.bottom, 12)
    }
}

