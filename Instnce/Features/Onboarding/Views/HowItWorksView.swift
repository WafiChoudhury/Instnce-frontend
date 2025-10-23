//
//  HowItWorksView.swift
//  Instnce
//
//  Created by Wafi Choudhury on 10/17/25.
//

import SwiftUI

struct HowItWorksView: View {
    var onBack: (() -> Void)?
    var onContinue: (() -> Void)?

    var body: some View {
        ZStack {
            // Subtle gradient background
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    Color(.systemGray6).opacity(0.3),
                    Color(.systemBackground)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar - refined
                HStack {
                    Button {
                        onBack?()
                    } label: {
                        Image(systemName: "arrow.left")
                            .font(.body.weight(.medium))
                            .foregroundStyle(.secondary)
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .fill(Color(.systemGray6).opacity(0.5))
                            )
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    // Refined page dots
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color(.systemGray4).opacity(0.4))
                            .frame(width: 5, height: 5)
                        Capsule()
                            .fill(Color(.label))
                            .frame(width: 16, height: 5)
                        Circle()
                            .fill(Color(.systemGray4).opacity(0.4))
                            .frame(width: 5, height: 5)
                    }

                    Spacer()

                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 36) {
                        Text("How it works")
                            .font(.system(size: 40, weight: .semibold))
                            .foregroundStyle(.primary)
                            .tracking(-0.5)
                            .padding(.top, 32)

                        VStack(spacing: 20) {
                            FeatureRow(
                                icon: "square.and.arrow.up",
                                iconTint: Color(.label),
                                tileTint: Color(.systemGray6).opacity(0.6),
                                title: "Share content",
                                subtitle: "Drop any link to invest in it"
                            )

                            FeatureRow(
                                icon: "arrow.up.right",
                                iconTint: Color(.label),
                                tileTint: Color(.systemGray6).opacity(0.6),
                                title: "Watch it grow",
                                subtitle: "Value rises as content goes viral"
                            )

                            FeatureRow(
                                icon: "sparkles",
                                iconTint: Color.green,
                                tileTint: Color.green.opacity(0.12),
                                title: "Profit",
                                subtitle: "Sell anytime to cash out your gains"
                            )
                        }
                    }
                    .padding(.horizontal, 28)
                    .padding(.bottom, 140)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                // Bottom CTA
                Button {
                    onContinue?()
                } label: {
                    HStack(spacing: 10) {
                        Text("Continue")
                            .font(.system(size: 16, weight: .medium))
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .semibold))
                            .imageScale(.small)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color(.label))
                            .shadow(color: Color.black.opacity(0.12), radius: 16, x: 0, y: 6)
                            .shadow(color: Color.black.opacity(0.08), radius: 1, x: 0, y: 1)
                    )
                    .foregroundStyle(Color(.systemBackground))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 28)
                .padding(.top, 10)
                .padding(.bottom, 40)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
}

private struct FeatureRow: View {
    let icon: String
    let iconTint: Color
    let tileTint: Color
    let title: String
    let subtitle: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Icon container with refined styling
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(tileTint)
                .frame(width: 52, height: 52)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(iconTint)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(Color(.separator).opacity(0.2), lineWidth: 0.5)
                )
                .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.primary)

                Text(subtitle)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(.secondary)
                    .lineSpacing(1)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                .shadow(color: Color.black.opacity(0.02), radius: 1, x: 0, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color(.separator).opacity(0.3), lineWidth: 0.5)
        )
    }
}

#Preview("How It Works") {
    HowItWorksView()
}
