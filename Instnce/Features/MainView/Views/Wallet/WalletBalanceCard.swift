//
//  WalletBalanceCard.swift
//  Instnce
//
//  Created by Wafi Choudhury on 10/24/25.
//

import SwiftUI

struct WalletBalanceCard: View {
    let balance: Double
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Total Balance")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Text("$\(balance, specifier: "%.2f")")
                .font(.system(size: 48, weight: .bold))
            
            Text("Your available balance for trading and transfers")
                .font(.footnote)
                .foregroundStyle(.secondary)
            
            Text("+12.5% this month")
                .font(.caption)
                .foregroundStyle(.green)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}
