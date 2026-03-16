//
//  SupabaseClient.swift
//  SharedJournal
//

import Foundation
import Supabase

enum SupabaseManager {
    static let shared: SupabaseClient = {
        let url = URL(string: Secrets.supabaseURL)!
        let client = SupabaseClient(
            supabaseURL: url,
            supabaseKey: Secrets.supabaseAnonKey
        )
        return client
    }()
}

