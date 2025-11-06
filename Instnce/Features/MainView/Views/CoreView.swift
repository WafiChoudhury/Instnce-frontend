import SwiftUI

struct CoreView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var trendingViewModel = HomeTrendingViewModel()
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
                    HomeTrendingView(viewModel: trendingViewModel, authViewModel: authViewModel)
                case .wallet:
                   WalletView(authViewModel: authViewModel)
                case .profile:
                    ProfileView(authViewModel: authViewModel)  
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
            
            // Minimal tab bar
            HStack(spacing: 0) {
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
            .frame(height: 80)
            .padding(.horizontal, 40)
            .padding(.top, 10)
            .background(Color(.systemBackground))
            .shadow(color: Color.black.opacity(0.05), radius: 8, y: -2)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

private struct TabBarButton: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon + (isSelected ? ".fill" : ""))
                    .font(.system(size: 24, weight: .medium))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundColor(isSelected ? .blue : Color(.systemGray))
                
                Circle()
                    .fill(Color.blue)
                    .frame(width: 4, height: 4)
                    .opacity(isSelected ? 1 : 0)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
