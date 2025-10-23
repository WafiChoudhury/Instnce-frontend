//
//  SupabaseAuthService.swift
//  Instnce
//
//  Created by Wafi Choudhury on 10/18/25.
//

import Foundation
import Supabase
import AuthenticationServices

// Global client you provided. Prefer moving into this service or DI if you like.
public let supabase = SupabaseClient(
  supabaseURL: URL(string: "https://hbuctvafykfazgfahseo.supabase.co")!,
  supabaseKey: "<TODO: Use your publishable key for native apps (not anon)>" // TODO
)

final class SupabaseAuthService: NSObject, ObservableObject {
    static let shared = SupabaseAuthService()

    // Expose session/user as needed
    @Published var isSignedIn: Bool = false
    @Published var lastError: Error?

    private var authStateTask: Task<Void, Never>?

    private override init() {
        super.init()
        // Observe auth state changes
        authStateTask = Task { [weak self] in
            for await state in supabase.auth.authStateChanges {
                switch state.event {
                case .initialSession, .signedIn:
                    await MainActor.run { self?.isSignedIn = state.session != nil }
                case .signedOut, .userDeleted, .tokenRefreshed, .passwordRecovery, .userUpdated:
                    await MainActor.run { self?.isSignedIn = (try? await supabase.auth.session) != nil }
                @unknown default:
                    break
                }
            }
        }
    }

    deinit {
        authStateTask?.cancel()
    }

    // Start Google OAuth using Supabase helper. Requires a redirect URL that matches your Info.plist scheme and Supabase Auth settings.
    @MainActor
    func signInWithGoogle(redirectURL: URL) async throws {
        do {
            lastError = nil
            // Note: Supabase iOS SDK will internally drive ASWebAuthenticationSession when given a redirect URL.
            try await supabase.auth.signInWithOAuth(
                provider: .google,
                redirectTo: redirectURL
            )
            // Completion continues via app URL callback. We rely on authStateChanges to flip isSignedIn.
        } catch {
            lastError = error
            throw error
        }
    }

    // Forward incoming callback URL to Supabase to finish the OAuth exchange.
    func handleOpenURL(_ url: URL) {
        // Supabase SDK inspects and completes the auth session if this URL matches the redirect
        Task {
            do {
                try await supabase.auth.session(from: url)
                await MainActor.run {
                    self.isSignedIn = (try? await supabase.auth.session) != nil
                }
            } catch {
                await MainActor.run {
                    self.lastError = error
                }
            }
        }
    }

    @MainActor
    func signOut() async {
        do {
            try await supabase.auth.signOut()
            isSignedIn = false
        } catch {
            lastError = error
        }
    }
}

