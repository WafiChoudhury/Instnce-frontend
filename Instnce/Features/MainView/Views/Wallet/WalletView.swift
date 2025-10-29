//
//  WalletView.swift
//  Instnce
//
//  Linear-style: clean, trust-first wallet UX
//

import SwiftUI
import PrivySDK

struct WalletView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @State private var showPhoneLogin = false
    
    var body: some View {
        NavigationStack {
            Group {
                if authViewModel.isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                        Text("Loading your wallet…")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                } else if authViewModel.isAuthenticated {
                    FinancesView(authViewModel: authViewModel)
                } else {
                    LoginPromptView(showPhoneLogin: $showPhoneLogin)
                }
            }
            .onAppear { authViewModel.initialize() }
            .navigationBarHidden(true)
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .alert("Error", isPresented: $authViewModel.showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(authViewModel.errorMessage)
            }
            .sheet(isPresented: $showPhoneLogin) {
                PhoneLoginView(authViewModel: authViewModel)
            }
        }
    }
}

//
// MARK: - Login Prompt
//

struct LoginPromptView: View {
    @Binding var showPhoneLogin: Bool
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 16) {
                Image(systemName: "wallet.pass.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(.primary)
                
                Text("Welcome to Instnce")
                    .font(.system(size: 28, weight: .bold))
                
                Text("Manage your finances securely and effortlessly.")
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button {
                showPhoneLogin = true
            } label: {
                Text("Continue with Phone")
                    .font(.system(size: 17, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.primary.opacity(0.9))
                    .foregroundStyle(Color(.systemBackground))
                    .cornerRadius(8)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 32)
            
            Spacer()
            
            Text("Your data is encrypted and protected with Privy.")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Spacer().frame(height: 20)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}


//
// MARK: - Components
//

struct PrimaryActionButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

struct WalletInfoCard: View {
    let wallet: EmbeddedSolanaWallet
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Solana Wallet", systemImage: "lock.shield")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Address")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(wallet.address)
                    .font(.system(.caption, design: .monospaced))
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            
            Button {
                UIPasteboard.general.string = wallet.address
            } label: {
                Label("Copy Address", systemImage: "doc.on.doc")
                    .font(.caption)
            }
            .buttonStyle(.plain)
            .padding(.top, 6)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct CreateWalletCard: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var isCreating = false
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "plus.circle")
                .font(.system(size: 48))
            
            Text("Create Wallet")
                .font(.headline)
            
            Text("Generate a secure embedded Solana wallet.")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Button {
                createWallet()
            } label: {
                if isCreating {
                    ProgressView()
                } else {
                    Text("Create Wallet")
                        .font(.system(size: 15, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.primary.opacity(0.9))
                        .foregroundStyle(Color(.systemBackground))
                        .cornerRadius(8)
                }
            }
            .buttonStyle(.plain)
            .disabled(isCreating)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private func createWallet() {
        isCreating = true
        Task {
            await authViewModel.createWallet()
            isCreating = false
        }
    }
}

struct TransactionRow: View {
    let title: String
    let date: String
    let amount: Double
    let icon: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .frame(width: 36, height: 36)
                .background(Color(.tertiarySystemBackground))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text(amount > 0 ? "+$\(amount, specifier: "%.2f")" : "-$\(abs(amount), specifier: "%.2f")")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(amount > 0 ? .green : .primary)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

struct AddMoneyView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var balance: Double
    @State private var amount = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()
                
                VStack(spacing: 8) {
                    Image(systemName: "dollarsign.circle")
                        .font(.system(size: 72))
                    
                    Text("Add Money")
                        .font(.system(size: 28, weight: .bold))
                }
                
                TextField("0.00", text: $amount)
                    .font(.system(size: 44, weight: .bold, design: .monospaced))
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                
                Text("Enter amount to deposit")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 12) {
                    ForEach([20, 50, 100, 200], id: \.self) { value in
                        Button("$\(value)") { amount = String(value) }
                            .buttonStyle(.bordered)
                    }
                }
                
                Spacer()
                
                Button {
                    if let value = Double(amount) {
                        balance += value
                        dismiss()
                    }
                } label: {
                    Text("Add Funds")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .font(.system(size: 17, weight: .semibold))
                        .background(Color.primary.opacity(0.9))
                        .foregroundStyle(Color(.systemBackground))
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                .disabled(amount.isEmpty)
                
                Spacer().frame(height: 20)
            }
            .padding()
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Add Money")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
