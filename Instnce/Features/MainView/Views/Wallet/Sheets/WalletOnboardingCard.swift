//
//  WalletOnboardingCard.swift
//  Instnce
//
//  Wallet onboarding explainer card
//

import SwiftUI

struct WalletOnboardingCard: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var showOnboarding = false
    @State private var isCreating = false
    var showPhoneLogin: Binding<Bool>? // Optional for use in WalletView
    
    var body: some View {
        VStack(spacing: 0) {
            if showOnboarding {
                onboardingContentView
            } else {
                getStartedView
            }
        }
        .padding(.horizontal)
        .padding(.top, 20)
    }
    
    private var getStartedView: some View {
        VStack(spacing: 0) {
            // Hero Section
            VStack(spacing: 20) {
                Image(systemName: "wallet.pass.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.blue)
                
                Text("Get Started with Your Wallet")
                    .font(.system(size: 24, weight: .bold))
                    .multilineTextAlignment(.center)
                
                Text("Your secure Solana wallet will be created instantly. Buy crypto, trade tokens, and manage your portfolio all in one place.")
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.horizontal, 32)
            .padding(.top, 40)
            .padding(.bottom, 32)
            
            Divider()
            
            // Get Started Button
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    showOnboarding = true
                }
            } label: {
                Text("Get Started")
                    .font(.system(size: 17, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.blue)
                    .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
        }
        .background(Color(.secondarySystemBackground))
        .cornerRadius(20)
    }
    
    private var onboardingContentView: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 28) {
                    // Features List
                    VStack(alignment: .leading, spacing: 20) {
                        WalletFeatureRow(icon: "shield.checkered", title: "Secure & Encrypted", description: "Your wallet is protected with industry-standard encryption")
                        
                        WalletFeatureRow(icon: "creditcard.fill", title: "Easy Funding", description: "Add funds with debit cards, Apple Pay, or bank transfer")
                        
                        WalletFeatureRow(icon: "chart.line.uptrend.xyaxis", title: "Start Trading", description: "Buy, sell, and track tokens in real-time")
                    }
                    .padding(.top, 20)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 24)
            }
            
            Divider()
            
            // Create Wallet or Login Button
            if showPhoneLogin != nil {
                // User not logged in - trigger login
                Button {
                    showPhoneLogin?.wrappedValue = true
                } label: {
                    Text("Continue with Phone")
                        .font(.system(size: 17, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
            } else {
                // User logged in but no wallet - create wallet
                Button {
                    createWallet()
                } label: {
                    HStack {
                        if isCreating {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Create Wallet")
                                .font(.system(size: 17, weight: .semibold))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(isCreating ? Color.blue.opacity(0.6) : Color.blue)
                    .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
                .disabled(isCreating)
            }
        }
        .background(Color(.secondarySystemBackground))
        .cornerRadius(20)
    }
    
    private func createWallet() {
        isCreating = true
        Task {
            let success = await authViewModel.createWallet()
            isCreating = false
        }
    }
}

private struct WalletFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(.blue)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
    }
}

