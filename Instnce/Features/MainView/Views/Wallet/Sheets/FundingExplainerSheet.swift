//
//  FundingExplainerSheet.swift
//  Instnce
//
//  Funding explainer modal with Linear-style design
//

import SwiftUI
import PrivySDK

struct FundingExplainerSheet: View {
    @ObservedObject var authViewModel: AuthViewModel
    @Binding var showExplainer: Bool
    @State private var showDetails = false
    
    var body: some View {
        VStack(spacing: 0) {
            if showDetails {
                detailsView
            } else {
                welcomeView
            }
        }
        .background(Color.black.ignoresSafeArea())
    }
    
    private var welcomeView: some View {
        VStack(spacing: 0) {
            // Header with close button
            HStack {
                Spacer()
                Button {
                    showExplainer = false
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.6))
                        .frame(width: 32, height: 32)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            
            Spacer()
            
            // Content
            VStack(spacing: 24) {
                Image(systemName: "wallet.pass.fill")
                    .font(.system(size: 56, weight: .medium))
                    .foregroundStyle(.white)
                    .symbolRenderingMode(.hierarchical)
                
                VStack(spacing: 12) {
                    Text("Add Funds")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)
                    
                    Text("You'll complete wallet funding in your browser, then return to the app. Your funds will be ready immediately.")
                        .font(.system(size: 16))
                        .foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                        .padding(.horizontal, 16)
                }
            }
            
            Spacer()
            
            // Action button
            VStack(spacing: 12) {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        showDetails = true
                    }
                } label: {
                    Text("Continue")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .cornerRadius(12)
                }
                .buttonStyle(.plain)
                
                Button {
                    showExplainer = false
                } label: {
                    Text("Cancel")
                        .font(.system(size: 16))
                        .foregroundStyle(.white.opacity(0.6))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
    
    private var detailsView: some View {
        VStack(spacing: 0) {
            // Header with back button
            HStack {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        showDetails = false
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.6))
                        .frame(width: 32, height: 32)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            
            ScrollView {
                VStack(spacing: 32) {
                    VStack(alignment: .leading, spacing: 24) {
                        FundingStepRow(icon: "1.circle.fill", title: "Choose Amount", description: "Select how much crypto you want to buy")
                        
                        FundingStepRow(icon: "2.circle.fill", title: "Pay Securely", description: "Use Apple Pay or your debit card for payment")
                        
                        FundingStepRow(icon: "3.circle.fill", title: "Return to App", description: "Come back when done—your wallet updates automatically")
                    }
                    .padding(.top, 32)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            
            Divider()
                .background(Color.white.opacity(0.1))
            
            Button {
                // Open Safari with funding URL
                if let address = authViewModel.embeddedWallet?.address {
                    let url = URL(string: "https://instnce-backend.vercel.app?address=\(address)")!
                    UIApplication.shared.open(url)
                }
                showExplainer = false
            } label: {
                Text("Start Funding")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.white)
                    .cornerRadius(12)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
        }
    }
}

private struct FundingStepRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(.white)
                .symbolRenderingMode(.hierarchical)
                .frame(width: 28)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                
                Text(description)
                    .font(.system(size: 15))
                    .foregroundStyle(.white.opacity(0.6))
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
    }
}

