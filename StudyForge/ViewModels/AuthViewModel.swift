//
//  AuthViewModel.swift
//  StudyForge
//
//  Created by Yash  Khanande on 22/07/25.
//


import Foundation
import FirebaseAuth
import Combine

class AuthViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var userId: String? = nil
    
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?

    init() {
        setupAuthStateListener()
    }

    private func setupAuthStateListener() {
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] (_, user) in
            guard let self = self else { return }
            if let user = user {
                self.userId = user.uid
                self.isLoggedIn = true
            } else {
                self.userId = nil
                self.isLoggedIn = false
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userId = nil
            self.isLoggedIn = false
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }

    deinit {
        if let handle = authStateListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}
