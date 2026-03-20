//
//  HomeFeedView.swift
//  SharedJournal
//

import SwiftUI
import Supabase

struct HomeFeedView: View {
    @EnvironmentObject var authState: AuthState

    @State private var friendships: [Friendship] = []
    @State private var friendItems: [FriendItem] = []
    @State private var memories: [Memory] = []
    @State private var isLoading: Bool = true
    @State private var showFriendPicker: Bool = false
    @State private var showAddMemorySheet: Bool = false
    @State private var selectedFriendForMemory: FriendItem?

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
        ZStack(alignment: .bottomTrailing) {
            Color(red: 0xf5 / 255.0, green: 0xf3 / 255.0, blue: 0xff / 255.0)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                friendsRow
                sectionLabel

                if isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if memories.isEmpty {
                    Spacer()
                    Text("No memories yet")
                        .font(.system(size: 18))
                        .foregroundColor(Color(red: 0x99 / 255.0, green: 0x99 / 255.0, blue: 0x99 / 255.0))
                    Spacer()
                } else {
                    memoriesList
                }
            }

            addMemoryButton
        }
        .sheet(isPresented: $showFriendPicker) {
            friendPickerSheet
        }
        .sheet(isPresented: $showAddMemorySheet) {
            if let item = selectedFriendForMemory {
                AddMemoryView(
                    friendship: item.friendship,
                    friendProfile: item.otherUser,
                    accentColor: accentColors[(friendItems.firstIndex(where: { $0.id == item.id }) ?? 0) % accentColors.count],
                    onSave: { Task { await loadData() } }
                )
                .environmentObject(authState)
            }
        }
        .task {
            await loadData()
        }
    }

    // MARK: - Subviews

    private var topBar: some View {
        HStack {
            Text("SharedJournal")
                .font(.system(size: 28, weight: .medium))
                .kerning(-0.02 * 28)
                .foregroundColor(titleColor)

            Spacer()

            NavigationLink {
                NotificationsView()
            } label: {
                Image(systemName: "bell.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color(red: 0x5b / 255.0, green: 0x3f / 255.0, blue: 0xf8 / 255.0))
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 20)
        .padding(.bottom, 12)
    }

    private var friendsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(Array(friendItems.enumerated()), id: \.element.id) { index, item in
                    let color = accentColors[index % accentColors.count]
                    NavigationLink {
                        FriendProfileView(
                            friendship: item.friendship,
                            friendProfile: item.otherUser,
                            currentUserProfile: authState.currentUser!,
                            accentColor: color
                        )
                        .environmentObject(authState)
                    } label: {
                        VStack(spacing: 4) {
                            ZStack {
                                Circle()
                                    .fill(color)
                                    .frame(width: 62, height: 62)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: 3)
                                    )

                                Text(item.otherUser.displayName.first.map { String($0) } ?? "?")
                                    .font(.system(size: 22, weight: .medium))
                                    .foregroundColor(.white)
                            }

                            Text(item.otherUser.displayName)
                                .font(.system(size: 12))
                                .foregroundColor(Color(red: 0x66 / 255.0, green: 0x66 / 255.0, blue: 0x66 / 255.0))
                                .lineLimit(1)
                        }
                    }
                }

                NavigationLink {
                    Text("Add Friend")
                } label: {
                    VStack(spacing: 4) {
                        ZStack {
                            Circle()
                                .fill(Color(red: 0xed / 255.0, green: 0xe9 / 255.0, blue: 0xff / 255.0))
                                .frame(width: 62, height: 62)
                                .overlay(
                                    Circle()
                                        .strokeBorder(
                                            style: StrokeStyle(
                                                lineWidth: 2,
                                                dash: [6]
                                            )
                                        )
                                        .foregroundColor(Color(red: 0xb3 / 255.0, green: 0xa6 / 255.0, blue: 0xf0 / 255.0))
                                )

                            Text("+")
                                .font(.system(size: 28))
                                .foregroundColor(Color(red: 0x9b / 255.0, green: 0x8b / 255.0, blue: 0xe0 / 255.0))
                        }

                        Text("Add")
                            .font(.system(size: 12))
                            .foregroundColor(Color(red: 0x66 / 255.0, green: 0x66 / 255.0, blue: 0x66 / 255.0))
                    }
                }
            }
            .padding(.leading, 16)
            .padding(.top, 10)
            .padding(.bottom, 14)
        }
    }

    private var sectionLabel: some View {
        HStack {
            Text("RECENT MEMORIES")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color(red: 0x99 / 255.0, green: 0x99 / 255.0, blue: 0x99 / 255.0))
                .kerning(0.07 * 13)

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 8)
    }

    private var memoriesList: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(Array(memories.enumerated()), id: \.element.id) { index, memory in
                    let color = accentColors[index % accentColors.count]
                    NavigationLink {
                        Text("Memory Detail")
                    } label: {
                        memoryCard(memory: memory, accentColor: color)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
    }

    private func memoryCard(memory: Memory, accentColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(accentColor)
                        .frame(width: 11, height: 11)

                    Text("with \(friendDisplayName(forFriendshipId: memory.friendshipId))")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(red: 0x33 / 255.0, green: 0x33 / 255.0, blue: 0x33 / 255.0))
                }

                Spacer()

                Text(formatMemoryDate(memory.memoryDate))
                    .font(.system(size: 12))
                    .foregroundColor(Color(red: 0xbb / 255.0, green: 0xbb / 255.0, blue: 0xbb / 255.0))
            }

            Text(memory.title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color(red: 0x1a / 255.0, green: 0x1a / 255.0, blue: 0x2e / 255.0))
                .padding(.top, 4)

            if let body = memory.body, !body.isEmpty {
                Text(body)
                    .font(.system(size: 13))
                    .foregroundColor(Color(red: 0x77 / 255.0, green: 0x77 / 255.0, blue: 0x77 / 255.0))
                    .lineLimit(2)
                    .padding(.top, 3)
            }

            if let location = memory.location, !location.isEmpty {
                Text("📍 \(location)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(red: 0xc0 / 255.0, green: 0x4a / 255.0, blue: 0x1a / 255.0))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color(red: 0xff / 255.0, green: 0xf3 / 255.0, blue: 0xee / 255.0))
                    .cornerRadius(20)
                    .padding(.top, 6)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color(red: 0xed / 255.0, green: 0xe9 / 255.0, blue: 0xff / 255.0), lineWidth: 0.5)
                )
        )
    }

    private var addMemoryButton: some View {
        Button {
            showFriendPicker = true
        } label: {
            ZStack {
                Circle()
                    .fill(Color(red: 0x5b / 255.0, green: 0x3f / 255.0, blue: 0xf8 / 255.0))
                    .frame(width: 56, height: 56)

                Text("+")
                    .font(.system(size: 30, weight: .light))
                    .foregroundColor(.white)
            }
        }
        .padding(.trailing, 20)
        .padding(.bottom, 20)
    }

    private var friendPickerSheet: some View {
        NavigationStack {
            ZStack {
                Color(red: 0xf5 / 255.0, green: 0xf3 / 255.0, blue: 0xff / 255.0)
                    .ignoresSafeArea()
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(Array(friendItems.enumerated()), id: \.element.id) { index, item in
                            let color = accentColors[index % accentColors.count]
                            Button {
                                selectedFriendForMemory = item
                                showFriendPicker = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    showAddMemorySheet = true
                                }
                            } label: {
                                HStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(color)
                                            .frame(width: 44, height: 44)
                                        Text(item.otherUser.displayName.first.map { String($0) } ?? "?")
                                            .font(.system(size: 18, weight: .medium))
                                            .foregroundColor(.white)
                                    }
                                    Text(item.otherUser.displayName)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(Color(red: 0x1a / 255.0, green: 0x1a / 255.0, blue: 0x2e / 255.0))
                                    Spacer()
                                }
                                .padding(14)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white)
                                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(red: 0xed / 255.0, green: 0xe9 / 255.0, blue: 0xff / 255.0), lineWidth: 0.5))
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Add memory with...")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showFriendPicker = false
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private func loadData() async {
        guard let userId = authState.currentUser?.id else {
            isLoading = false
            return
        }

        do {
            let loadedFriendships: [Friendship] = try await SupabaseManager.shared
                .from("friendships")
                .select()
                .or("user_a_id.eq.\(userId),user_b_id.eq.\(userId)")
                .eq("status", value: "accepted")
                .execute()
                .value

            if loadedFriendships.isEmpty {
                await MainActor.run {
                    friendships = []
                    friendItems = []
                    memories = []
                    isLoading = false
                }
                return
            }

            let friendshipIds = loadedFriendships.map { $0.id.uuidString }

            let loadedMemories: [Memory] = try await SupabaseManager.shared
                .from("memories")
                .select()
                .in("friendship_id", values: friendshipIds)
                .order("memory_date", ascending: false)
                .execute()
                .value

            var items: [FriendItem] = []
            for friendship in loadedFriendships {
                let otherUserId = friendship.userAId == userId ? friendship.userBId : friendship.userAId
                let profiles: [Profile] = try await SupabaseManager.shared
                    .from("profiles")
                    .select()
                    .eq("id", value: otherUserId)
                    .limit(1)
                    .execute()
                    .value
                guard let profile = profiles.first else { continue }
                let count = loadedMemories.filter { $0.friendshipId == friendship.id }.count
                items.append(FriendItem(friendship: friendship, otherUser: profile, memoryCount: count))
            }

            await MainActor.run {
                friendships = loadedFriendships
                friendItems = items
                memories = loadedMemories
                isLoading = false
            }
        } catch {
            print("Failed to load home feed data:", error)
            await MainActor.run {
                friendships = []
                friendItems = []
                memories = []
                isLoading = false
            }
        }
    }

    private func friendDisplayName(forFriendshipId id: UUID) -> String {
        friendItems.first(where: { $0.friendship.id == id })?.otherUser.displayName ?? "Friend"
    }

}

#Preview {
    HomeFeedView()
        .environmentObject(AuthState())
}

