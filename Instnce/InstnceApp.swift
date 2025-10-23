//
//  InstnceApp.swift
//  Instnce
//
//  Created by Wafi Choudhury on 10/14/25.
//

import SwiftUI

@main
struct InstnceApp: App {
    @StateObject private var auth = AuthModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(auth)
        }
    }
}
