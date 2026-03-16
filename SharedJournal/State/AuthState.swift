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

    var isAuthenticated: Bool {
        currentUser != nil
    }

    init() {
        Task {
            await initialize()
        }
    }

    private func initialize() async {
        defer { isLoading = false }

        let supabase = SupabaseManager.shared

        do {
            // Load existing session, if any
            let session = try await supabase.auth.session
            let userId = session.user.id
            await loadCurrentUser(id: userId)
        } catch {
            // No session or failed to load; treat as logged out
            currentUser = nil
        }
    }

    func signOut() async {
        let supabase = SupabaseManager.shared

        do {
            try await supabase.auth.signOut()
            currentUser = nil
        } catch {
            // Handle sign-out error as needed (logging, etc.)
        }
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
        }
    }
}

