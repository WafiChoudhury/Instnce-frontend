//
//  AuthViewModel.swift
//  Instnce
//
//  Handles authentication with automatic wallet setup
//

import Foundation
import SwiftUI
import Combine
import PrivySDK

@MainActor
class AuthViewModel: ObservableObject {
    // Published state
    @Published var isAuthenticated = false
    @Published var isLoading = true
    @Published var currentUser: PrivyUser?
    @Published var embeddedWallet: EmbeddedSolanaWalletAccount?
    // Error handling
    @Published var errorMessage = ""
    @Published var showError = false
    
    private var privy: Privy? {
        PrivyManager.shared.privy
    }
    
    // MARK: - Initialize
    
    init() {
        initialize()
    }
    
    func initialize() {
        Task {
            await checkAuthState()
        }
    }
    
    private func checkAuthState() async {
        guard let privy = privy else {
            showErrorMessage("Privy not initialized")
            isLoading = false
            return
        }
        
        do {
            try await privy.getAuthState()
            
            if let user = try await privy.getUser() {
                print("✅ User authenticated: \(user.id)")
                currentUser = user
                isAuthenticated = true
                await ensureWalletExists(user: user, phoneNumber: nil)  
            } else {
                print("ℹ️ No user authenticated")
                isAuthenticated = false
            }
        } catch {
            showErrorMessage("Failed to initialize: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    // MARK: - Phone Authentication
    
    func sendPhoneCode(phoneNumber: String) async -> Bool {
        guard let privy = privy else {
            showErrorMessage("Privy not initialized")
            return false
        }
        
        do {
            try await privy.sms.sendCode(to: phoneNumber)
            print("✅ SMS code sent to \(phoneNumber)")
            return true
        } catch {
            showErrorMessage("Failed to send code: \(error.localizedDescription)")
            return false
        }
    }
    func loginWithPhoneCode(phoneNumber: String, code: String) async -> Bool {
        guard let privy = privy else {
            showErrorMessage("Privy not initialized")
            return false
        }
        
        do {
            let user = try await privy.sms.loginWithCode(code, sentTo: phoneNumber)
            print("✅ Login successful: \(user.id)")
            currentUser = user
            isAuthenticated = true
            
            // Automatically ensure wallet exists after login
            await ensureWalletExists(user: user, phoneNumber: phoneNumber)  
            
            return true
        } catch {
            showErrorMessage("Login failed: \(error.localizedDescription)")
            return false
        }
    }
    // MARK: - Wallet Management
    

    private func ensureWalletExists(user: PrivyUser, phoneNumber: String? = nil) async {  // <-- CHANGE 3: add phoneNumber parameter
          // Check if user already has a Solana wallet
          let existingWallet = user.linkedAccounts.compactMap { account -> EmbeddedSolanaWalletAccount? in
              if case .embeddedSolanaWallet(let walletAccount) = account {
                  return walletAccount
              }
              return nil
          }.first
          
          if let wallet = existingWallet {
              print("✅ Existing wallet found: \(wallet.address)")
              embeddedWallet = wallet
              
              // <-- CHANGE 4: Add Supabase sync for existing wallet
              await syncUserAndWallet(privyUser: user, walletAddress: wallet.address, phoneNumber: phoneNumber)
              
          } else {
              // No wallet exists, create one automatically
              print("ℹ️ No wallet found, creating one...")
              await createWalletAutomatically(for: user, phoneNumber: phoneNumber)  // <-- CHANGE 5: pass phoneNumber
          }
      }
    
    /// Creates a wallet automatically during setup
    private func createWalletAutomatically(for user: PrivyUser, phoneNumber: String? = nil) async {  // <-- CHANGE 6: add phoneNumber parameter
        do {
          
            let wallet = try await user.createSolanaWallet()
            print("✅ Wallet created automatically: \(wallet.address)")
            let refreshedUser = try await privy?.getUser()
            embeddedWallet = refreshedUser?.linkedAccounts.compactMap {
                if case .embeddedSolanaWallet(let acc) = $0 { return acc } else { return nil }
            }.first

            // <-- keep Supabase sync using the live wallet's address
            await syncUserAndWallet(privyUser: user, walletAddress: wallet.address, phoneNumber: phoneNumber)
            
        } catch {
            print("⚠️ Failed to create wallet: \(error.localizedDescription)")
        }
    }
    /// Manual wallet creation (backup if auto-creation failed)
    func createWallet() async -> Bool {
        guard let user = currentUser else {
            showErrorMessage("Not authenticated")
            return false
        }
        
        do {
            let wallet = try await user.createSolanaWallet()
            print("✅ Wallet created: \(wallet.address)")
            let refreshedUser = try await privy?.getUser()
            embeddedWallet = refreshedUser?.linkedAccounts.compactMap {
                if case .embeddedSolanaWallet(let acc) = $0 { return acc } else { return nil }
            }.first
            return true
        } catch {
            showErrorMessage("Failed to create wallet: \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - Logout
    
    func logout() async {
        guard let privy = privy else { return }
        if let user = await privy.getUser() {
             await user.logout()
             // Navigate back to login screen
            print("✅ Logged out successfully")
            isAuthenticated = false
            currentUser = nil
            embeddedWallet = nil
           }
        
       
    }
    
    // MARK: - Helpers
    
    private func showErrorMessage(_ message: String) {
        print("❌ \(message)")
        errorMessage = message
        showError = true
    }
}
