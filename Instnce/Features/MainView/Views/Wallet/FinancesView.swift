//
//  FinancesView.swift
//  Instnce
//
//  Main wallet finances view
//

import SwiftUI
import PrivySDK

struct FinancesView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @StateObject private var balanceViewModel = WalletBalanceViewModel()
    @State private var showAddMoney = false
    @State private var showOnramp = false
    @State private var showFundingExplainer = false
    @State private var selectedTimeframe: PortfolioTimeframe = .day
    @State private var isWalletDetailsExpanded: Bool = false
    
    private var balance: Double {
        balanceViewModel.balanceUsd
    }
    
    // Portfolio value is the wallet balance (for now, can be extended to include token holdings)
    private var portfolioValue: Double {
        balance
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Portfolio Header
            PortfolioHeaderView(
                portfolioValue: portfolioValue,
                todayPnL: balanceViewModel.todayPnL,
                todayPnLPercentage: balanceViewModel.todayPnLPercentage,
                isPositive: balanceViewModel.isPositive
            )

            // MARK: - Chart
            PortfolioChart(
                portfolioHistory: balanceViewModel.portfolioHistory,
                currentValue: portfolioValue,
                isPositive: balanceViewModel.isPositive
            )
            .frame(height: 220)
            .padding(.top, 24)
            
            // MARK: - Timeframe Selector
            TimeframeSelector(selectedTimeframe: $selectedTimeframe)
            
            Spacer().frame(height: 24)
            
            // MARK: - Buying Power Section
            BuyingPowerSection(balance: balance) {
                if authViewModel.embeddedWallet?.address != nil {
                    showFundingExplainer = true
                } else {
                    showAddMoney = true
                }
            }
            
            Divider()
                .padding(.horizontal, 16)
            
            Spacer()
            
            // MARK: - Wallet Details Section
            if let wallet = authViewModel.embeddedWallet {
                WalletDetailsSection(
                    walletAddress: wallet.address,
                    isExpanded: $isWalletDetailsExpanded
                )
            } else {
                VStack(spacing: 10) {
                    ProgressView()
                        .tint(.blue)
                    Text("Setting up your wallet…")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
            
            Spacer(minLength: 12)
        }
        .background(Color(.systemBackground).ignoresSafeArea())
        .sheet(isPresented: $showAddMoney) {
            AddMoneyView(balance: .constant(balance))
        }
        .sheet(isPresented: $showFundingExplainer) {
            FundingExplainerSheet(authViewModel: authViewModel, showExplainer: $showFundingExplainer)
        }
        .onChange(of: showOnramp) { _, newValue in
            if newValue, let address = authViewModel.embeddedWallet?.address {
                let url = URL(string: "https://instnce-backend.vercel.app?address=\(address)")!
                UIApplication.shared.open(url)
                showOnramp = false
            }
        }
        .onAppear {
            // Start polling when view appears
            if let address = authViewModel.embeddedWallet?.address {
                balanceViewModel.startPolling(walletAddress: address)
            }
        }
        .onDisappear {
            // Stop polling when view disappears
            balanceViewModel.stopPolling()
        }
        .onReceive(NotificationCenter.default.publisher(for: .onrampCompleted)) { _ in
            // Refresh balance immediately after onramp completes
            if let address = authViewModel.embeddedWallet?.address {
                Task {
                    await balanceViewModel.loadBalance(walletAddress: address)
                }
            }
        }
    }
}
