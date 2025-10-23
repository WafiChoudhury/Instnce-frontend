import SwiftUI

struct WelcomeView: View {
    @State private var navigateNext = false
    @State private var goToSignup = false
    @EnvironmentObject var auth: AuthModel

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
                Spacer()

                // Hero content
                VStack(spacing: 12) {
                    Text("Instnce")
                        .font(.system(size: 52, weight: .semibold))
                        .foregroundStyle(.primary)
                        .tracking(-1)

                    Text("Invest in content before it goes viral")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .lineSpacing(2)
                }

                Spacer()

                // CTA section
                VStack(spacing: 12) {
                    Button {
                        navigateNext = true
                    } label: {
                        HStack(spacing: 10) {
                            Text("Get Started")
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

                    Text("Free to start, no credit card required")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 40)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(isPresented: $navigateNext) {
            HowItWorksView(
                onBack: { navigateNext = false },
                onContinue: { goToSignup = true }
            )
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden, for: .navigationBar)
        }
        .navigationDestination(isPresented: $goToSignup) {
            SignupWithGoogleView(
                onBack: { navigateNext = true }
            )
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

#Preview {
    NavigationStack {
        WelcomeView()
            .environmentObject(AuthModel())
    }
}
