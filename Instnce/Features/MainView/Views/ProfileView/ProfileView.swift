//
//  ProfileView.swift
//  Instnce
//
//  Clean, minimal profile view inspired by Linear & Robinhood
//

import SwiftUI
import PrivySDK
import Supabase

struct ProfileView: View {
    @ObservedObject var authViewModel: AuthViewModel 
    @EnvironmentObject var auth: AuthModel
    @State private var userData: UserProfile?
    @State private var isLoading = true
    @State private var showLogoutAlert = false
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                        Text("Loading...")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                } else if let user = userData {
                    profileContent(user: user)
                } else {
                    notLoggedInView
                }
            }
            .task {
                await loadProfileData()
            }
            .navigationBarHidden(true)
            .alert("Sign Out", isPresented: $showLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    Task {
                        await logoutUser()
                    }
                }
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
    
    // MARK: - Views
    
    @ViewBuilder
    private func profileContent(user: UserProfile) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                // Profile Header - Linear style
                VStack(spacing: 16) {
                    // Avatar with minimal border
                    ZStack {
                        Circle()
                            .stroke(Color(.systemGray5), lineWidth: 2)
                            .frame(width: 88, height: 88)
                        
                        // Avatar
                        if let avatarUrl = user.avatarUrl, !avatarUrl.isEmpty {
                            Image("avatar")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                        } else {
                            Image("avatar")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                        }
                    }
                    
                    // Name
                    Text(user.username ?? "User")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(.primary)
                }
                .padding(.top, 32)
                
                // Member Since Badge - Minimal Linear style
                MemberSinceBadge(date: formatDate(user.createdAt))
                    .padding(.horizontal)
                
                // Sign Out Button
                Button {
                    showLogoutAlert = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "arrow.right.square")
                            .font(.system(size: 16, weight: .medium))
                        Text("Sign Out")
                            .font(.system(size: 15, weight: .medium))
                        Spacer()
                    }
                    .foregroundStyle(.red.opacity(0.85))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
    }
    
    private var notLoggedInView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.circle")
                .font(.system(size: 56))
                .foregroundStyle(.secondary)
            
            Text("Not signed in")
                .font(.system(size: 17, weight: .medium))
        }
    }
    
    // MARK: - Helpers
    private func loadProfileData() async {
        isLoading = true
        
        do {
            // Try to get data from Supabase Auth (Google sign-in)
            if let _ = try? await supabase.auth.session {
                let authProfile = try await fetchAuthUserProfile()
                // Convert AuthUserProfile to UserProfile
                userData = UserProfile(
                    id: authProfile.id,
                    privyUserId: authProfile.id,
                    phoneNumberHash: nil,
                    username: authProfile.username,
                    avatarUrl: authProfile.avatarUrl,
                    createdAt: authProfile.createdAt,
                    updatedAt: authProfile.createdAt
                )
            } else if let user = authViewModel.currentUser {
                // Fallback to Privy user (phone login)
                userData = try await fetchUserProfile(privyUserId: user.id)
            }
        } catch {
            print("⚠️ Failed to load profile: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else {
            return dateString
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "MMM yyyy"
        return displayFormatter.string(from: date)
    }
    
    private func logoutUser() async {
        // Logout from Privy
        await authViewModel.logout()
        
        // Logout from Supabase Auth
        try? await supabase.auth.signOut()
        
        // Update AuthModel to show onboarding
        auth.signedIn = false
    }
}

// MARK: - Member Since Badge

struct MemberSinceBadge: View {
    let date: String
    
    var body: some View {
        HStack(spacing: 14) {
            // Icon with minimal background
            ZStack {
                Circle()
                    .fill(Color(.systemGray6))
                    .frame(width: 40, height: 40)
                
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Member Since")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary)
                
                Text(date)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.primary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.secondarySystemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(Color(.systemGray5), lineWidth: 1)
                )
        )
    }
}

// MARK: - Profile Row

struct ProfileRow: View {
    let icon: String
    let title: String
    var value: String? = nil
    var showChevron: Bool = true
    var isHeader: Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                
                if let value = value {
                    Text(value)
                        .font(.system(size: 16, weight: .medium))
                }
            }
            
            Spacer()
            
            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .overlay(alignment: .bottom) {
            Divider()
                .padding(.leading, 44)
        }
    }
}
