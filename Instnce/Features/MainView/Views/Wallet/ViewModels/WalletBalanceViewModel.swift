//
//  WalletBalanceViewModel.swift
//  Instnce
//
//  Manages wallet balance polling and portfolio value history
//

import Foundation
import SwiftUI
import Combine

@MainActor
class WalletBalanceViewModel: ObservableObject {
    @Published var balanceSol: Double = 0.0
    @Published var solPriceUsd: Double = 150.0
    @Published var isLoading: Bool = false
    @Published var portfolioHistory: [PortfolioValueSnapshot] = []
    @Published var startOfDayBalanceUsd: Double = 0.0
    @Published var startOfDayPriceUsd: Double = 150.0
    
    private var pollingTask: Task<Void, Never>?
    private var isPolling: Bool = false
    private var pollCount: Int = 0
    private var lastBalanceSol: Double = 0.0
    private var walletAddress: String = ""
    private var userId: String?
    
    var balanceUsd: Double {
        balanceSol * solPriceUsd
    }
    
    // Today's P&L in USD
    var todayPnL: Double {
        balanceUsd - startOfDayBalanceUsd
    }
    
    // Today's P&L percentage
    var todayPnLPercentage: Double {
        guard startOfDayBalanceUsd > 0 else { return 0 }
        return (todayPnL / startOfDayBalanceUsd) * 100
    }
    
    var isPositive: Bool {
        todayPnL >= 0
    }
    
    func startPolling(walletAddress: String) {
        guard !isPolling else { return }
        isPolling = true
        pollCount = 0
        self.walletAddress = walletAddress
        
        // Fetch userId and load initial data
        Task {
            // Get userId from wallet address
            if let uid = try? await getUserIdFromWalletAddress(walletAddress: walletAddress) {
                self.userId = uid
                
                // Load portfolio history
                await loadPortfolioHistory()
                
                // Set start-of-day balance (first snapshot of today or current balance)
                await setStartOfDayBalance()
            }
            
            // Load initial balance and price
            await loadBalance(walletAddress: walletAddress)
        }
        
        // Start polling every 15 seconds
        pollingTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 15_000_000_000) // 15 seconds
                await loadBalance(walletAddress: walletAddress)
            }
        }
    }
    
    private func loadPortfolioHistory() async {
        guard let userId = userId else { return }
        
        do {
            let history = try await fetchPortfolioValueHistory(userId: userId, hours: 24, limit: 100)
            portfolioHistory = history
            print("✅ Loaded \(history.count) portfolio snapshots")
        } catch {
            print("⚠️ Failed to load portfolio history: \(error.localizedDescription)")
        }
    }
    
    private func setStartOfDayBalance() async {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Find first snapshot of today
        if let firstToday = portfolioHistory.first(where: { snapshot in
            if let timestamp = ISO8601DateFormatter().date(from: snapshot.timestamp) {
                return calendar.isDate(timestamp, inSameDayAs: today)
            }
            return false
        }) {
            startOfDayBalanceUsd = firstToday.portfolioValueUsd
            startOfDayPriceUsd = firstToday.solPriceUsd
        } else if let firstSnapshot = portfolioHistory.first {
            // No snapshot today, use oldest available
            startOfDayBalanceUsd = firstSnapshot.portfolioValueUsd
            startOfDayPriceUsd = firstSnapshot.solPriceUsd
        }
        // If no history, startOfDayBalanceUsd stays 0 (will be set on first balance load)
    }
    
    func stopPolling() {
        isPolling = false
        pollingTask?.cancel()
        pollingTask = nil
    }
    
    func loadBalance(walletAddress: String) async {
        isLoading = true
        defer { isLoading = false }
        
        pollCount += 1
        
        var fetchedBalance: Double = 0.0
        var fetchedPrice: Double = solPriceUsd
        
        do {
            // Fetch SOL balance from blockchain
            fetchedBalance = try await fetchSolanaBalance(walletAddress: walletAddress)
            
            // Update Supabase
            try await updateWalletBalanceSol(walletAddress: walletAddress, balanceSol: fetchedBalance)
            
            // Update local state
            balanceSol = fetchedBalance
        } catch {
            // Fallback to Supabase if blockchain fetch fails
            if let cachedBalance = try? await fetchWalletBalanceSol(walletAddress: walletAddress) {
                fetchedBalance = cachedBalance
                balanceSol = cachedBalance
            }
            print("⚠️ Failed to load balance: \(error.localizedDescription)")
        }
        
        // Fetch SOL price on first load and every 5 polls (~2.5 minutes)
        if pollCount == 1 || pollCount % 5 == 0 {
            if let price = try? await fetchSolPrice() {
                fetchedPrice = price
                solPriceUsd = price
            }
        }
        
        // Set start-of-day balance on first load if not set
        if pollCount == 1 && startOfDayBalanceUsd == 0 {
            startOfDayBalanceUsd = fetchedBalance * fetchedPrice
            startOfDayPriceUsd = fetchedPrice
        }
        
        // Check if balance changed (using small threshold to avoid floating point issues)
        let balanceChanged = abs(fetchedBalance - lastBalanceSol) > 0.0001
        
        // Always insert snapshot on first poll (to establish baseline), or when balance changes
        let shouldInsertSnapshot = (pollCount == 1) || balanceChanged
        
        if shouldInsertSnapshot, let userId = userId {
            // Insert portfolio snapshot
            do {
                try await insertPortfolioValueSnapshot(
                    userId: userId,
                    walletAddress: walletAddress,
                    walletBalanceSol: fetchedBalance,
                    solPriceUsd: fetchedPrice
                )
                
                print("✅ Inserted portfolio snapshot: \(fetchedBalance) SOL @ $\(fetchedPrice)")
                
                // Reload portfolio history
                await loadPortfolioHistory()
            } catch {
                print("⚠️ Failed to insert portfolio snapshot: \(error.localizedDescription)")
            }
        } else if shouldInsertSnapshot && userId == nil {
            print("⚠️ Cannot insert snapshot: userId is nil (user may not be synced to Supabase yet)")
        }
        
        lastBalanceSol = fetchedBalance
    }
}

