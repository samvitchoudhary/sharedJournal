//
//  ContentView.swift
//  SharedJournal
//
//  Created by Samvit Choudhary on 3/16/26.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authState: AuthState

    var body: some View {
        Group {
            if authState.isLoading {
                Color.white
                    .ignoresSafeArea()
            } else if authState.isAuthenticated {
                Text("Home")
            } else {
                WelcomeView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthState())
}
