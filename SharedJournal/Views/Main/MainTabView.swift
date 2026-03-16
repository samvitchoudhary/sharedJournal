//
//  MainTabView.swift
//  SharedJournal
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authState: AuthState

    init() {
        UITabBar.appearance().backgroundColor = .white
        UITabBar.appearance().isTranslucent = false
        UITabBar.appearance().unselectedItemTintColor = .gray
    }

    var body: some View {
        TabView {
            HomeFeedView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }

            Text("Friends")
                .tabItem {
                    Image(systemName: "person.2.fill")
                    Text("Friends")
                }

            Text("Profile")
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
        .tint(Color(red: 0x5b / 255.0, green: 0x3f / 255.0, blue: 0xf8 / 255.0))
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthState())
}

