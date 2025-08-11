//
//  AuthService.swift
//  rufus
//
//  Created by Mubashir Osmani on 2025-08-03.

import Foundation
import Supabase
import Combine
import GoogleSignIn

#if canImport(UIKit)
import UIKit
#endif

@MainActor
final class AuthService: ObservableObject {
    static let shared = AuthService()

    @Published var isAuthenticated = false
    @Published var user: User?
    @Published var isLoading = false

    private let client = SupabaseClient(
        supabaseURL: URL(string: "https://vmzmwybvcybsiplmmelv.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZtem13eWJ2Y3lic2lwbG1tZWx2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU1NDQ3MTEsImV4cCI6MjA2MTEyMDcxMX0.SVWjQUjA5km-db31SwNV0CLZAG0hM213OXIN11nlshQ"
    )

    private init() {
        Task {
            await loadSession()
        }
    }

    func loadSession() async {
        do {
            let session = try await client.auth.session
            self.user = session.user
            self.isAuthenticated = true
        } catch {
            print("Error loading session: \(error)")
            self.isAuthenticated = false
        }
    }

    // Email & Password Sign Up
    func signUp(email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        let response = try await client.auth.signUp(email: email, password: password)
        self.user = response.user
        self.isAuthenticated = true
    }

    // Email & Password Sign In
    func signIn(email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        let session = try await client.auth.signIn(email: email, password: password)
        self.user = session.user
        self.isAuthenticated = true
    }

    // Google OAuth Sign In
    func signInWithGoogle() async throws {
        isLoading = true
        defer { isLoading = false }
        
        #if canImport(UIKit)
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let presentingViewController = windowScene.windows.first?.rootViewController else {
            throw AuthError.noViewController
        }
        
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController)
        
        guard let idToken = result.user.idToken?.tokenString else {
            throw AuthError.noIdToken
        }
        
        let accessToken = result.user.accessToken.tokenString
        
        let session = try await client.auth.signInWithIdToken(
            credentials: .init(
                provider: .google,
                idToken: idToken,
                accessToken: accessToken
            )
        )
        
        self.user = session.user
        self.isAuthenticated = true
        #else
        throw AuthError.platformNotSupported
        #endif
    }

    func signOut() async throws {
        isLoading = true
        defer { isLoading = false }
        
        try await client.auth.signOut()
        self.user = nil
        self.isAuthenticated = false
    }
}

enum AuthError: Error, LocalizedError {
    case noViewController
    case noIdToken
    case platformNotSupported
    
    var errorDescription: String? {
        switch self {
        case .noViewController:
            return "No view controller available for sign-in"
        case .noIdToken:
            return "Failed to get ID token from Google"
        case .platformNotSupported:
            return "Google Sign-In not supported on this platform"
        }
    }
}
