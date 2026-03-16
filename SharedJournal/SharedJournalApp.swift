//
//  SharedJournalApp.swift
//  SharedJournal
//
//  Created by Samvit Choudhary on 3/16/26.
//

import SwiftUI
import Supabase

@main
struct SharedJournalApp: App {
    @StateObject private var authState = AuthState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authState)
        }
    }
}
