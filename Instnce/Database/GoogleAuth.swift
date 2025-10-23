//
//  GoogleAuth.swift
//  Instnce
//
//  Created by Wafi Choudhury on 10/18/25.
//

//
//  GoogleAuth.swift
//  Instnce
//

import Foundation
import GoogleSignIn
import UIKit // needed to get a presenting view controller
import Supabase

enum GoogleAuthError: Error {
    case noRootViewController
    case noIDToken
}

@MainActor
func signInWithGoogleNative() async throws {
    // Ensure required frameworks are available at compile-time
    #if canImport(UIKit) && canImport(GoogleSignIn)
    // TODO: If you didn’t add GIDClientID in Info.plist, configure it here:
    GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: "422527677195-d6pn1qkbth77d8hlsuq4dnfdjskfoamq.apps.googleusercontent.com")

    // Find a presenter for Google’s UI
    guard let presenter = UIApplication.shared.connectedScenes
        .compactMap({ $0 as? UIWindowScene })
        .flatMap({ $0.windows })
        .first(where: { $0.isKeyWindow })?.rootViewController
    else {
        throw GoogleAuthError.noRootViewController
    }

    let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presenter)
    guard let idToken = result.user.idToken?.tokenString else {
        throw GoogleAuthError.noIDToken
    }
    let accessToken = result.user.accessToken.tokenString

    // Send tokens to Supabase to create a session
    try await supabase.auth.signInWithIdToken(
        credentials: OpenIDConnectCredentials(
            provider: .google,
            idToken: idToken,
            accessToken: accessToken
        )
    )
    #else
    throw GoogleAuthError.unavailable
    #endif
}
