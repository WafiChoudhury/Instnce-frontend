//
//  WalletDetailsSection.swift
//  Instnce
//
//  Wallet address display section
//

import SwiftUI

private func shortAddress(_ full: String) -> String {
    guard full.count > 10 else { return full }
    let start = full.prefix(4)
    let end = full.suffix(4)
    return "\(start)…\(end)"
}

struct WalletDetailsSection: View {
    let walletAddress: String
    @Binding var isExpanded: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            DisclosureGroup(
                isExpanded: $isExpanded,
                content: {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 8) {
                            Text(walletAddress)
                                .font(.system(size: 12, design: .monospaced))
                                .lineLimit(1)
                                .truncationMode(.middle)
                            Spacer()
                            Button {
                                UIPasteboard.general.string = walletAddress
                            } label: {
                                Label("Copy", systemImage: "doc.on.doc")
                                    .labelStyle(.iconOnly)
                                    .font(.system(size: 14))
                                    .foregroundStyle(.blue)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.top, 8)
                },
                label: {
                    HStack {
                        Image(systemName: "wallet.pass")
                            .foregroundStyle(.secondary)
                        Text("Wallet")
                            .font(.system(size: 15, weight: .semibold))
                        Spacer()
                        Text(shortAddress(walletAddress))
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }
                }
            )
            .tint(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }
}

