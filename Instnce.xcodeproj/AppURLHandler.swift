//
//  AppURLHandler.swift
//  Instnce
//
//  Created by Wafi Choudhury on 10/18/25.
//

import SwiftUI

// A simple view modifier to forward incoming URLs to SupabaseAuthService.
// Attach this to your root view (ContentView) or InstnceApp WindowGroup.
struct AppURLHandler: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onOpenURL { url in
                // Ensure this matches the redirect URL you configured (scheme + host/path).
                SupabaseAuthService.shared.handleOpenURL(url)
            }
    }
}

extension View {
    func installAppURLHandler() -> some View {
        self.modifier(AppURLHandler())
    }
}

