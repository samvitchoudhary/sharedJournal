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
        ZStack {
            Color(red: 0xf5 / 255.0, green: 0xf3 / 255.0, blue: 0xff / 255.0)
                .ignoresSafeArea()

            TabView {
                NavigationStack {
                    HomeFeedView()
                }
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }

                NavigationStack {
                    FriendsListView()
                }
                .tabItem {
                    Image(systemName: "person.2.fill")
                    Text("Friends")
                }

                NavigationStack {
                    Text("Profile")
                }
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
            }
            .tint(Color(red: 0x5b / 255.0, green: 0x3f / 255.0, blue: 0xf8 / 255.0))
            .toolbarBackground(Color.white, for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthState())
}

