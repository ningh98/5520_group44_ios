//
//  AuthManager.swift
//  5520_IOS_Group44
//
//  Created by Ninghui Cai on 11/21/24.
//

import Foundation
import FirebaseAuth

class AuthManager {
    static let shared = AuthManager()
    
    var currentUser: FirebaseAuth.User? {
        return Auth.auth().currentUser
    }
    
    private init() {}
}
