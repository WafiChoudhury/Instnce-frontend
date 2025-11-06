//
//  InstnceApp.swift
//  Instnce
//
//  App initialization with Privy SDK
//

import SwiftUI
import PrivySDK

@main
struct InstnceApp: App {
    @StateObject private var authModel = AuthModel()
    
    init() {
        // Configure Privy SDK
        let config = PrivyConfig(
            appId: "cmh2vmapv047bif0c19sx0v6r",
            appClientId: "client-WY6SHSxS4cL3ih4nARsgqLN4W97tyigWTNyigqMN3yvTW" 
        )
        
        
        // Initialize Privy (only do this once!)
        let privy = PrivySdk.initialize(config: config)
        
        // Store privy instance globally for access throughout the app
        PrivyManager.shared.privy = privy
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authModel)
                .onOpenURL { url in
                    // Expecting: instnce://onramp-complete
                    if url.scheme == "instnce", url.host == "onramp-complete" {
                        NotificationCenter.default.post(name: .onrampCompleted, object: nil)
                    }
                }
        }
    }
}
