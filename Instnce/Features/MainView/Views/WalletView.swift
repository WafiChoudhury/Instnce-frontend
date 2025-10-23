//
//  WalletView.swift
//  Instnce
//
//  Created by Wafi Choudhury on 10/21/25.
//
//
//  WalletView.swift
//  Instnce
//
//  Created by You on \(DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none))
//

import SwiftUI
import Combine
import PrivySDK

struct WalletView: View {
    @StateObject private var viewModel = WalletViewModel()
    @EnvironmentObject private var authModel: AuthModel

    var body: some View {
        NavigationStack {
            VStack {
                if let wallet = viewModel.embeddedWallet {
                    // Wallet already created
                    VStack(spacing: 16) {
                        Text("Your Wallet")
                            .font(.title2)
                            .fontWeight(.semibold)

                        Text(wallet.address)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        // TODO: Add export or backup actions once SDK API is confirmed
                        // Example placeholder:
                        // Button("Backup / Export") { /* show backup UI */ }
                        //     .buttonStyle(.borderedProminent)

                        Spacer()

                        // TODO: Display balances, tokens, send / receive buttons
                    }
                    .padding()
                }
                else {
                    // No wallet yet — prompt to create
                    VStack(spacing: 20) {
                        Spacer()
                        Text("Set up your embedded wallet")
                            .font(.title3)
                            .fontWeight(.semibold)

                        Text("Your wallet is self-custodial yet embedded; you never need separate wallet apps.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        Button("Create Wallet") {
                            Task {
                                await viewModel.createWallet()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationTitle("Wallet")
            .onAppear {
                viewModel.initialize(authModel: authModel)
            }
            .alert("Error", isPresented: $viewModel.isShowingError, actions: {
                Button("OK", role: .cancel) { }
            }, message: {
                Text(viewModel.errorMessage)
            })
        }
    }
}

// MARK: - ViewModel

@MainActor
final class WalletViewModel: ObservableObject {
    @Published var embeddedWallet: EmbeddedSolanaWallet? = nil

    // Use a Bool + String for alert(isPresented:)
    @Published var isShowingError: Bool = false
    @Published var errorMessage: String = ""

    // If you have a concrete user type from the SDK, store it here
    // private var privyUser: PrivyUser?

    func initialize(authModel: AuthModel) {
        // Replace this with your real Privy user fetching logic.
        // Previously: guard let user = Privy.shared.user else { ... }
        guard authModel.signedIn else {
            presentError("User not authenticated")
            return
        }

        // TODO: Load current user and any existing embedded wallet(s) using your SDK.
        // Example (pseudocode — replace with your SDK's actual API):
        // self.privyUser = try await PrivyClient.shared.currentUser()
        // await fetchExistingWallet()
    }

    func fetchExistingWallet() async {
        // TODO: Query SDK for existing wallets and assign to embeddedWallet.
        // Example (pseudocode):
        // do {
        //     let wallets = try await privyUser?.embeddedSolanaWallets() ?? []
        //     if let first = wallets.first {
        //         embeddedWallet = first
        //     }
        // } catch {
        //     presentError(error.localizedDescription)
        // }
    }

    func createWallet() async {
        // TODO: Call your SDK to create an embedded Solana wallet, then set embeddedWallet.
        // Example (pseudocode):
        // do {
        //     guard let user = privyUser else {
        //         presentError("User not authenticated")
        //         return
        //     }
        //     let wallet = try await user.createEmbeddedWallet(chain: .solana)
        //     embeddedWallet = wallet
        // } catch {
        //     presentError(error.localizedDescription)
        // }

        // Temporary placeholder so the button doesn't do nothing:
        presentError("Wallet creation is not wired up to the SDK yet.")
    }

    // MARK: - Helpers

    private func presentError(_ message: String) {
        errorMessage = message
        isShowingError = true
    }
}

