//
//  HomeFeedView.swift
//  SharedJournal
//

import SwiftUI
import Supabase

struct HomeFeedView: View {
    @EnvironmentObject var authState: AuthState

    @State private var friendships: [Friendship] = []
    @State private var memories: [Memory] = []
    @State private var isLoading: Bool = true
    @State private var showAddMemorySheet: Bool = false

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
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                backgroundColor
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
                            .font(.system(size: 14))
                            .foregroundColor(Color(red: 0x99 / 255.0, green: 0x99 / 255.0, blue: 0x99 / 255.0))
                        Spacer()
                    } else {
                        memoriesList
                    }
                }

                addMemoryButton
            }
            .sheet(isPresented: $showAddMemorySheet) {
                Text("Add Memory")
                    .padding()
            }
            .task {
                await loadData()
            }
        }
    }

    // MARK: - Subviews

    private var topBar: some View {
        HStack {
            Text("SharedJournal")
                .font(.system(size: 22, weight: .medium))
                .kerning(-0.02 * 22)
                .foregroundColor(titleColor)

            Spacer()

            NavigationLink {
                Text("Notifications")
            } label: {
                Image(systemName: "bell.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color(red: 0x5b / 255.0, green: 0x3f / 255.0, blue: 0xf8 / 255.0))
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 18)
        .padding(.bottom, 8)
    }

    private var friendsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(friendships.enumerated()), id: \.element.id) { index, friendship in
                    let color = accentColors[index % accentColors.count]
                    NavigationLink {
                        Text("Friend Profile")
                    } label: {
                        VStack(spacing: 4) {
                            ZStack {
                                Circle()
                                    .fill(color)
                                    .frame(width: 46, height: 46)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: 2.5)
                                    )

                                Text(friendInitial(for: friendship))
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.white)
                            }

                            Text(friendName(for: friendship))
                                .font(.system(size: 9))
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
                                .frame(width: 46, height: 46)
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
                                .font(.system(size: 22))
                                .foregroundColor(Color(red: 0x9b / 255.0, green: 0x8b / 255.0, blue: 0xe0 / 255.0))
                        }

                        Text("Add")
                            .font(.system(size: 9))
                            .foregroundColor(Color(red: 0x66 / 255.0, green: 0x66 / 255.0, blue: 0x66 / 255.0))
                    }
                }
            }
            .padding(.leading, 16)
            .padding(.top, 8)
            .padding(.bottom, 10)
        }
    }

    private var sectionLabel: some View {
        HStack {
            Text("RECENT MEMORIES")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(Color(red: 0x99 / 255.0, green: 0x99 / 255.0, blue: 0x99 / 255.0))
                .kerning(0.07 * 10)

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
        .padding(.bottom, 6)
    }

    private var memoriesList: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(Array(memories.enumerated()), id: \.element.id) { index, memory in
                    let color = accentColors[index % accentColors.count]
                    NavigationLink {
                        Text("Memory Detail")
                    } label: {
                        memoryCard(memory: memory, accentColor: color)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 16)
        }
    }

    private func memoryCard(memory: Memory, accentColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(accentColor)
                        .frame(width: 8, height: 8)

                    Text("with \(friendName(forFriendshipId: memory.friendshipId))")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(red: 0x33 / 255.0, green: 0x33 / 255.0, blue: 0x33 / 255.0))
                }

                Spacer()

                Text(formattedDate(memory.memoryDate))
                    .font(.system(size: 9))
                    .foregroundColor(Color(red: 0xbb / 255.0, green: 0xbb / 255.0, blue: 0xbb / 255.0))
            }

            Text(memory.title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(red: 0x1a / 255.0, green: 0x1a / 255.0, blue: 0x2e / 255.0))
                .padding(.top, 4)

            if let body = memory.body, !body.isEmpty {
                Text(body)
                    .font(.system(size: 10))
                    .foregroundColor(Color(red: 0x77 / 255.0, green: 0x77 / 255.0, blue: 0x77 / 255.0))
                    .lineLimit(2)
                    .padding(.top, 3)
            }

            if let location = memory.location, !location.isEmpty {
                Text("📍 \(location)")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(Color(red: 0xc0 / 255.0, green: 0x4a / 255.0, blue: 0x1a / 255.0))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color(red: 0xff / 255.0, green: 0xf3 / 255.0, blue: 0xee / 255.0))
                    .cornerRadius(20)
                    .padding(.top, 6)
            }
        }
        .padding(.horizontal, 13)
        .padding(.vertical, 11)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color(red: 0xed / 255.0, green: 0xe9 / 255.0, blue: 0xff / 255.0), lineWidth: 0.5)
                )
        )
    }

    private var addMemoryButton: some View {
        Button {
            showAddMemorySheet = true
        } label: {
            ZStack {
                Circle()
                    .fill(Color(red: 0x5b / 255.0, green: 0x3f / 255.0, blue: 0xf8 / 255.0))
                    .frame(width: 40, height: 40)

                Text("+")
                    .font(.system(size: 22, weight: .light))
                    .foregroundColor(.white)
            }
        }
        .padding(.trailing, 16)
        .padding(.bottom, 16)
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

            await MainActor.run {
                friendships = loadedFriendships
            }

            if loadedFriendships.isEmpty {
                await MainActor.run {
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

            await MainActor.run {
                memories = loadedMemories
                isLoading = false
            }
        } catch {
            print("Failed to load home feed data:", error)
            await MainActor.run {
                friendships = []
                memories = []
                isLoading = false
            }
        }
    }

    private func friendInitial(for friendship: Friendship) -> String {
        let name = friendName(for: friendship)
        return name.first.map { String($0) } ?? "?"
    }

    private func friendName(for friendship: Friendship) -> String {
        // Placeholder until we have real friend names
        return "Friend"
    }

    private func friendName(forFriendshipId id: UUID) -> String {
        if let friendship = friendships.first(where: { $0.id == id }) {
            return friendName(for: friendship)
        }
        return "Friend"
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

#Preview {
    HomeFeedView()
        .environmentObject(AuthState())
}

