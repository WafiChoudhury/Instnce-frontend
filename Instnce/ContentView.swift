import SwiftUI
import PrivySDK

struct ContentView: View {
    @EnvironmentObject var auth: AuthModel

  



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
