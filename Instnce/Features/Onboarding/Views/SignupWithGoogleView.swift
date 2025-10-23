//
//  SignupWithGoogleView.swift
//  Instnce
//
//  Created by Wafi Choudhury on 10/18/25.
//

import SwiftUI

struct SignupWithGoogleView: View {
    
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    @EnvironmentObject var auth: AuthModel
    var onBack: (() -> Void)?

    var body: some View {
        ZStack {
            // Subtle gradient background (very faint)
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
                // Top bar - more minimal
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
                    .disabled(isLoading)

                    Spacer()

                    // Refined page dots
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color(.systemGray4).opacity(0.4))
                            .frame(width: 5, height: 5)
                        Circle()
                            .fill(Color(.systemGray4).opacity(0.4))
                            .frame(width: 5, height: 5)
                        Capsule()
                            .fill(Color(.label))
                            .frame(width: 16, height: 5)
                    }

                    Spacer()

                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Hero content - tighter spacing, cleaner hierarchy
                        VStack(spacing: 8) {
                            Text("Join Instnce")
                                .font(.system(size: 40, weight: .semibold))
                                .foregroundStyle(.primary)
                                .tracking(-0.5)

                            Text("Invest in content before it goes viral.")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 60)
                        .padding(.horizontal, 32)
                        
                        Spacer()
                            .frame(height: 80)
                        
                        // Premium card-style button container
                        VStack(spacing: 16) {
                            Button {
                                isLoading = true
                                Task { await signInWithGoogle() }
                            } label: {
                                HStack(spacing: 14) {
                                    // Custom Google icon styling
                                    ZStack {
                                        Circle()
                                            .fill(.white)
                                            .frame(width: 32, height: 32)
                                        
                                        Image(systemName: "g.circle.fill")
                                            .symbolRenderingMode(.multicolor)
                                            .font(.title3)
                                    }
                                    
                                    Text("Continue with Google")
                                        .font(.system(size: 16, weight: .medium))
                                    
                                    Spacer(minLength: 0)
                                    
                                    if isLoading {
                                        ProgressView()
                                            .progressViewStyle(.circular)
                                            .scaleEffect(0.9)
                                    } else {
                                        Image(systemName: "arrow.right")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .padding(.vertical, 18)
                                .padding(.horizontal, 20)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(Color(.systemBackground))
                                        .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
                                        .shadow(color: Color.black.opacity(0.04), radius: 1, x: 0, y: 1)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .strokeBorder(Color(.separator).opacity(0.5), lineWidth: 0.5)
                                )
                                .foregroundStyle(.primary)
                            }
                            .buttonStyle(.plain)
                            .disabled(isLoading)
                            .opacity(isLoading ? 0.7 : 1.0)
                            .animation(.easeInOut(duration: 0.15), value: isLoading)

                            if let error = errorMessage {
                                HStack(spacing: 8) {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .font(.footnote)
                                    Text(error)
                                        .font(.footnote)
                                }
                                .foregroundStyle(.red)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(Color.red.opacity(0.08))
                                )
                                .transition(.move(edge: .top).combined(with: .opacity))
                            }
                        }
                        .padding(.horizontal, 28)
                        
                        // Legal text - more refined
                        Text("By continuing, you agree to our **Terms** and acknowledge our **Privacy Policy**.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .padding(.top, 40)
                    }
                    .padding(.bottom, 60)
                }
            }
            
   
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isLoading)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    @MainActor
    private func signInWithGoogle() async {
        errorMessage = nil
        do {
            try await signInWithGoogleNative()
            auth.signedIn = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

#Preview("Signup With Google") {
    SignupWithGoogleView()
        .environmentObject(AuthModel())
}
