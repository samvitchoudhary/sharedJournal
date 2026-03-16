//
//  AuthState.swift
//  SharedJournal
//

import Foundation
import Combine
import Supabase

final class AuthState: ObservableObject {
    @Published var currentUser: Profile?
    @Published var isLoading: Bool = true
    @Published var errorMessage: String?

    var isAuthenticated: Bool {
        currentUser != nil
    }

    init() {
        Task {
            await initialize()
        }
    }

    private func initialize() async {
        let supabase = SupabaseManager.shared

        do {
            // Load existing session, if any
            let session = try await supabase.auth.session
            let userId = session.user.id
            await loadCurrentUser(id: userId)
        } catch {
            // No session or failed to load; treat as logged out
            currentUser = nil
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func signOut() async {
        let supabase = SupabaseManager.shared

        do {
            try await supabase.auth.signOut()
            currentUser = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signUp(email: String, password: String, username: String, displayName: String) async throws {
        isLoading = true
        errorMessage = nil

        let supabase = SupabaseManager.shared

        do {
            let response = try await supabase.auth.signUp(
                email: email,
                password: password,
                data: [
                    "username": .string(username),
                    "display_name": .string(displayName)
                ]
            )

            let user = response.user
            await loadCurrentUser(id: user.id)
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            throw error
        }

        isLoading = false
    }

    func signIn(email: String, password: String) async throws {
        isLoading = true
        errorMessage = nil

        let supabase = SupabaseManager.shared

        do {
            let response = try await supabase.auth.signIn(
                email: email,
                password: password
            )

            let userId = response.user.id
            await loadCurrentUser(id: userId)
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            throw error
        }

        isLoading = false
    }

    private func loadCurrentUser(id: UUID) async {
        let supabase = SupabaseManager.shared

        do {
            let profiles: [Profile] = try await supabase
                .from("profiles")
                .select()
                .eq("id", value: id)
                .limit(1)
                .execute()
                .value

            currentUser = profiles.first
        } catch {
            currentUser = nil
            errorMessage = error.localizedDescription
        }
    }
}

