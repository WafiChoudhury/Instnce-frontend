import SwiftUI
import PrivySDK

struct ContentView: View {
    @EnvironmentObject var auth: AuthModel

    let config = PrivyConfig(
        appId: "cmh2vmapv047bif0c19sx0v6r",
        appClientId: "client-WY6SHSxS4cL3ih4nARsgqLN4W97tyigWTNyigqMN3yvTW",
        loggingConfig: .init(
            logLevel: .verbose
        )
    )

    let privy: Privy

    init() {
        self.privy = PrivySdk.initialize(config: config)
    }

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            if auth.signedIn {
                CoreView()
            } else {
                // ✅ Onboarding flow wrapped in its own NavigationStack
                NavigationStack {
                    WelcomeView()
                }
                .transition(.move(edge: .leading).combined(with: .opacity))
            }
        }
        .animation(.easeInOut, value: auth.signedIn)
    }
}
