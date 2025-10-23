import SwiftUI

struct CoreView: View {
    @State private var selectedTab: Tab = .home
    
    enum Tab {
        case home, wallet, profile
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Main content area
            Group {
                switch selectedTab {
                case .home:
                    HomeTrendingView()
                case .wallet:
                   WalletView()
                case .profile:
                    Text("hey")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
            
            // Slim tab bar
            HStack {
                TabBarButton(icon: "house", isSelected: selectedTab == .home) {
                    selectedTab = .home
                }
                
                TabBarButton(icon: "creditcard", isSelected: selectedTab == .wallet) {
                    selectedTab = .wallet
                }
                
                TabBarButton(icon: "person", isSelected: selectedTab == .profile) {
                    selectedTab = .profile
                }
            }
            .frame(height: 52)
            .padding(.horizontal, 40)
            .background(Color(.systemBackground).opacity(0.9))
            .overlay(
                Divider()
                    .frame(height: 1)
                    .foregroundColor(.gray.opacity(0.25)),
                alignment: .top
            )
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

private struct TabBarButton: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: icon + (isSelected ? ".fill" : ""))
                    .font(.system(size: 20, weight: .semibold))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundColor(isSelected ? .accentColor : .gray)
                
                // Small indicator dot when selected
                Circle()
                    .fill(isSelected ? Color.accentColor : .clear)
                    .frame(width: 4, height: 4)
                    .animation(.easeInOut(duration: 0.2), value: isSelected)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}
