//
//  AuthModel.swift
//  Instnce
//
//  Created by Wafi Choudhury on 10/19/25.
//

import SwiftUI
import Combine

class AuthModel: ObservableObject {
    @Published var signedIn: Bool {
        didSet {
            // Save whenever signedIn changes
            UserDefaults.standard.set(signedIn, forKey: "signedIn")
            print("🔐 Auth.signedIn changed to: \(signedIn)")
        }
    }

    init() {
        // Restore last state from UserDefaults
        let savedState = UserDefaults.standard.bool(forKey: "signedIn")
        self.signedIn = savedState
        print("🔁 AuthModel init: \(ObjectIdentifier(self)) | Restored signedIn = \(savedState)")
    }
}
