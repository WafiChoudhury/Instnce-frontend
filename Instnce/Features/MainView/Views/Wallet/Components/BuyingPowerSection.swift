//
//  BuyingPowerSection.swift
//  Instnce
//
//  Buying power display with Add Money button
//

import SwiftUI

struct BuyingPowerSection: View {
    let balance: Double
    let onAddMoney: () -> Void
    
    var body: some View {
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
                onAddMoney()
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
    }
}

