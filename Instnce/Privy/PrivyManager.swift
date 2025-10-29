//
//  PrivyManager.swift
//  Instnce
//
//  Singleton to access Privy instance globally
//

import Foundation
import PrivySDK

class PrivyManager {
    static let shared = PrivyManager()
    
    var privy: Privy?
    
    private init() {}
    

}

