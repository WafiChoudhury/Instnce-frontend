//
//  EmptyWalletCard.swift
//  Instnce
//
//  Created by Wafi Choudhury on 10/24/25.
//

import SwiftUI

struct EmptyWalletCard: View {
    @Binding var showAddMoney: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "creditcard.fill")
                .font(.system(size: 48))
                .foregroundStyle(.primary)
            
            Text("Get Started with Instnce")
                .font(.headline)
            
            Text("Add funds to your wallet to start exploring, trading, and sending securely.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            
            Button {
                showAddMoney = true
            } label: {
                Text("Add Funds")
                    .font(.system(size: 15, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.primary.opacity(0.9))
                    .foregroundStyle(Color(.systemBackground))
                    .cornerRadius(8)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 32)
            
            Divider().padding(.horizontal)
            
            Text("Secured by Privy’s embedded wallet technology")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}
