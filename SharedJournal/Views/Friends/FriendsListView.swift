//
//  FriendsListView.swift
//  SharedJournal
//

import SwiftUI
import Supabase

struct FriendsListView: View {
    @EnvironmentObject var authState: AuthState

    @State private var items: [FriendItem] = []
    @State private var isLoading: Bool = true
    @State private var showAddFriend: Bool = false
    @State private var showRequests: Bool = false
    @State private var pendingIncomingCount: Int = 0

    private let backgroundColor = Color(red: 0xf5 / 255.0, green: 0xf3 / 255.0, blue: 0xff / 255.0)
    private let titleColor = Color(red: 0x1a / 255.0, green: 0x1a / 255.0, blue: 0x2e / 255.0)
    private let accentColors: [Color] = [
        Color(red: 0xff / 255.0, green: 0x6b / 255.0, blue: 0x35 / 255.0),
        Color(red: 0x5b / 255.0, green: 0x3f / 255.0, blue: 0xf8 / 255.0),
        Color(red: 0x2e / 255.0, green: 0xcc / 255.0, blue: 0x71 / 255.0),
        Color(red: 0xff / 255.0, green: 0xce / 255.0, blue: 0x00 / 255.0),
        Color(red: 0x00 / 255.0, green: 0xbc / 255.0, blue: 0xd4 / 255.0)
    ]

    var body: some View {
        ZStack {
            Color(red: 0xf5 / 255.0, green: 0xf3 / 255.0, blue: 0xff / 255.0)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                topBar

                if isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if items.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                                let color = accentColors[index % accentColors.count]

                                if let currentUser = authState.currentUser {
                                    NavigationLink {
                                        FriendProfileView(
                                            friendship: item.friendship,
                                            friendProfile: item.otherUser,
                                            currentUserProfile: currentUser,
                                            accentColor: color
                                        )
                                        .environmentObject(authState)
                                    } label: {
                                        friendRow(item: item, accentColor: color)
                                    }
                                } else {
                                    friendRow(item: item, accentColor: color)
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.top, 12)
                    }
                }
            }
        }
        .sheet(isPresented: $showAddFriend, onDismiss: {
            Task {
                await loadFriends()
            }
        }) {
            AddFriendView()
                .environmentObject(authState)
        }
        .sheet(isPresented: $showRequests, onDismiss: {
            Task {
                await refreshCounts()
            }
        }) {
            FriendRequestsView()
                .environmentObject(authState)
        }
        .task {
            await loadFriends()
            await refreshCounts()
        }
    }

    private var topBar: some View {
        HStack {
            Text("Friends")
                .font(.system(size: 28, weight: .medium))
                .foregroundColor(titleColor)

            Spacer()

            Button {
                showRequests = true
            } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell")
                        .font(.system(size: 18))
                        .foregroundColor(Color(red: 0x5b / 255.0, green: 0x3f / 255.0, blue: 0xf8 / 255.0))

                    if pendingIncomingCount > 0 {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 10, height: 10)
                            .offset(x: 5, y: -5)
                    }
                }
            }
            .padding(.trailing, 8)

            Button {
                showAddFriend = true
            } label: {
                Text("+")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(Color(red: 0x5b / 255.0, green: 0x3f / 255.0, blue: 0xf8 / 255.0))
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 18)
    }

    private var emptyState: some View {
        VStack(spacing: 6) {
            Text("No friends yet")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(Color(red: 0x99 / 255.0, green: 0x99 / 255.0, blue: 0x99 / 255.0))

            Text("Tap + to add your first friend")
                .font(.system(size: 15))
                .foregroundColor(Color(red: 0xbb / 255.0, green: 0xbb / 255.0, blue: 0xbb / 255.0))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 40)
    }

    private func friendRow(item: FriendItem, accentColor: Color) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(accentColor)
                    .frame(width: 50, height: 50)

                Text(initial(for: item.otherUser))
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(item.otherUser.displayName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(titleColor)

                Text("\(item.memoryCount) memories together")
                    .font(.system(size: 12))
                    .foregroundColor(Color(red: 0x99 / 255.0, green: 0x99 / 255.0, blue: 0x99 / 255.0))
            }

            Spacer()

            Text("›")
                .font(.system(size: 14))
                .foregroundColor(Color(red: 0xcc / 255.0, green: 0xcc / 255.0, blue: 0xcc / 255.0))
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color(red: 0xed / 255.0, green: 0xe9 / 255.0, blue: 0xff / 255.0), lineWidth: 0.5)
                )
        )
    }

    private func loadFriends() async {
        guard let currentUser = authState.currentUser else {
            await MainActor.run {
                items = []
                isLoading = false
            }
            return
        }

        isLoading = true

        do {
            let friendships: [Friendship] = try await SupabaseManager.shared
                .from("friendships")
                .select()
                .or("user_a_id.eq.\(currentUser.id),user_b_id.eq.\(currentUser.id)")
                .eq("status", value: "accepted")
                .execute()
                .value

            var newItems: [FriendItem] = []

            for friendship in friendships {
                let otherUserId = friendship.userAId == currentUser.id ? friendship.userBId : friendship.userAId

                let profiles: [Profile] = try await SupabaseManager.shared
                    .from("profiles")
                    .select()
                    .eq("id", value: otherUserId)
                    .limit(1)
                    .execute()
                    .value

                guard let otherProfile = profiles.first else { continue }

                let memoriesForFriendship: [Memory] = try await SupabaseManager.shared
                    .from("memories")
                    .select()
                    .eq("friendship_id", value: friendship.id)
                    .execute()
                    .value

                let item = FriendItem(friendship: friendship,
                                      otherUser: otherProfile,
                                      memoryCount: memoriesForFriendship.count)
                newItems.append(item)
            }

            await MainActor.run {
                items = newItems
                isLoading = false
            }
        } catch {
            print("Failed to load friends:", error)
            await MainActor.run {
                items = []
                isLoading = false
            }
        }
    }

    private func refreshCounts() async {
        guard let currentUser = authState.currentUser else {
            await MainActor.run {
                pendingIncomingCount = 0
            }
            return
        }

        do {
            let friendships: [Friendship] = try await SupabaseManager.shared
                .from("friendships")
                .select()
                .eq("status", value: "pending")
                .or("user_a_id.eq.\(currentUser.id),user_b_id.eq.\(currentUser.id)")
                .execute()
                .value

            let incoming = friendships.filter { $0.requesterId != currentUser.id }

            await MainActor.run {
                pendingIncomingCount = incoming.count
            }
        } catch {
            print("Failed to load pending requests count:", error)
            await MainActor.run {
                pendingIncomingCount = 0
            }
        }
    }

    private func initial(for profile: Profile) -> String {
        profile.displayName.first.map { String($0) } ?? "?"
    }
}

struct FriendItem: Identifiable {
    let friendship: Friendship
    let otherUser: Profile
    let memoryCount: Int

    var id: UUID { friendship.id }
}

#Preview {
    FriendsListView()
        .environmentObject(AuthState())
}

