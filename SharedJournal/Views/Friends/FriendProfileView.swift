//
//  FriendProfileView.swift
//  SharedJournal
//

import SwiftUI
import Supabase

struct FriendProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authState: AuthState

    let friendship: Friendship
    let friendProfile: Profile
    let currentUserProfile: Profile
    let accentColor: Color

    @State private var memories: [Memory] = []
    @State private var selectedTab: Int = 0
    @State private var showAddMemorySheet: Bool = false

    private static var friendsSinceFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM yyyy"
        return f
    }()

    private var favoriteMemories: [Memory] {
        memories.filter { $0.isFavorite }
    }

    private let tabOrange = Color(red: 1, green: 107/255, blue: 53/255)
    private let tabUnselected = Color(red: 0.75, green: 0.75, blue: 0.75)
    private let tabBarBorder = Color(red: 1, green: 224/255, blue: 204/255)
    private let tabBarBg = Color(red: 1, green: 248/255, blue: 244/255)
    private let yourPurple = Color(red: 91/255, green: 63/255, blue: 248/255)
    private let titleColor = Color(red: 26/255, green: 26/255, blue: 46/255)
    private let entryTitleColor = Color(red: 45/255, green: 45/255, blue: 58/255)
    private let timelineLineColor = Color(red: 240/255, green: 232/255, blue: 224/255)
    private let dividerColor = Color(red: 240/255, green: 235/255, blue: 232/255)
    private let favoriteLabelColor = Color(red: 245/255, green: 166/255, blue: 35/255)
    private let favoriteCardBg = Color(red: 1, green: 248/255, blue: 238/255)
    private let favoriteCardBorder = Color(red: 1, green: 224/255, blue: 170/255)
    private let locationPillBg = Color(red: 1, green: 243/255, blue: 238/255)
    private let locationPillText = Color(red: 192/255, green: 74/255, blue: 26/255)
    private let photoPlaceholderStart = Color(red: 1, green: 211/255, blue: 181/255)
    private let photoPlaceholderEnd = Color(red: 1, green: 170/255, blue: 165/255)

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color(red: 1, green: 245/255, blue: 240/255)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    coverSection
                    avatarSection
                    nameSection
                    customTabBar
                    tabContent
                }
            }

            fab
        }
        .navigationBarBackButtonHidden(true)
        .task {
            await loadMemories()
        }
        .sheet(isPresented: $showAddMemorySheet) {
            AddMemoryView(
                friendship: friendship,
                friendProfile: friendProfile,
                accentColor: accentColor,
                onSave: { Task { await loadMemories() } }
            )
            .environmentObject(authState)
        }
    }

    // MARK: - Data

    private func loadMemories() async {
        do {
            memories = try await SupabaseManager.shared
                .from("memories")
                .select()
                .eq("friendship_id", value: friendship.id.uuidString)
                .order("memory_date", ascending: false)
                .execute()
                .value
        } catch {
            print("Error loading memories: \(error)")
        }
    }

    // MARK: - Cover (110pt)

    private var coverSection: some View {
        ZStack(alignment: .topLeading) {
            LinearGradient(
                colors: [accentColor, Color(red: 1, green: 206/255, blue: 0)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 110)
            .ignoresSafeArea(edges: .top)

            HStack {
                Button {
                    dismiss()
                } label: {
                    Text("← Back")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                }
                .padding(.leading, 16)
                .padding(.top, 50)

                Spacer()

                Button {
                    // edit photo
                } label: {
                    Text("edit photo")
                        .font(.system(size: 9))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.25), in: RoundedRectangle(cornerRadius: 8))
                }
                .padding(.trailing, 16)
                .padding(.top, 50)
            }
        }
        .frame(height: 110)
    }

    // MARK: - Avatars (overlap cover by 20pt)

    private var avatarSection: some View {
        ZStack(alignment: .topLeading) {
            HStack(spacing: -12) {
                ZStack {
                    Circle()
                        .fill(accentColor)
                        .frame(width: 44, height: 44)
                    Text(initial(for: friendProfile))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 3)
                )

                ZStack {
                    Circle()
                        .fill(yourPurple)
                        .frame(width: 44, height: 44)
                    Text(initial(for: currentUserProfile))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 3)
                )
            }
            .padding(.leading, 16)
            .offset(y: -20)

            HStack {
                Spacer()
                Text("\(memories.count) memories")
                    .font(.system(size: 10))
                    .foregroundColor(Color(red: 0xaa/255, green: 0xaa/255, blue: 0xaa/255))
                    .padding(.trailing, 16)
            }
            .offset(y: -20)
        }
        .frame(height: 24)
    }

    private func initial(for profile: Profile) -> String {
        profile.displayName.first.map { String($0) } ?? "?"
    }

    // MARK: - Name section

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("\(friendProfile.displayName.isEmpty ? "Friend" : friendProfile.displayName) & You")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(titleColor)

            Text("Friends since \(Self.friendsSinceFormatter.string(from: friendship.createdAt))")
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }

    // MARK: - Custom tab bar

    private var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(0..<3, id: \.self) { index in
                tabButton(index: index)
            }
        }
        .background(tabBarBg)
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(tabBarBorder),
            alignment: .bottom
        )
    }

    private func tabButton(index: Int) -> some View {
        let label: String = {
            switch index {
            case 0: return "All"
            case 1: return "Best of"
            case 2: return "Photos"
            default: return ""
            }
        }()
        let isSelected = selectedTab == index
        return Button {
            selectedTab = index
        } label: {
            VStack(spacing: 0) {
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(isSelected ? tabOrange : tabUnselected)
                Rectangle()
                    .fill(isSelected ? tabOrange : Color.clear)
                    .frame(height: 2)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Tab content

    @ViewBuilder
    private var tabContent: some View {
        Group {
            switch selectedTab {
            case 0:
                allTabContent
            case 1:
                bestOfTabContent
            case 2:
                photosTabContent
            default:
                allTabContent
            }
        }
        .padding(.bottom, 100)
    }

    private var allTabContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            if !favoriteMemories.isEmpty {
                Text("★ BEST OF")
                    .font(.system(size: 10, weight: .medium))
                    .tracking(0.5)
                    .foregroundColor(favoriteLabelColor)
                    .padding(.leading, 14)
                    .padding(.top, 10)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(favoriteMemories) { memory in
                            favoriteCard(memory)
                        }
                    }
                    .padding(.horizontal, 14)
                }
                .padding(.bottom, 6)

                Divider()
                    .background(dividerColor)
                    .padding(.horizontal, 14)
            }

            Text("TIMELINE")
                .font(.system(size: 10, weight: .medium))
                .tracking(0.5)
                .foregroundColor(.gray)
                .padding(.leading, 14)
                .padding(.top, 8)
                .padding(.bottom, 6)

            if memories.isEmpty {
                Text("No memories yet")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 16)
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(memories) { memory in
                        timelineEntry(memory)
                    }
                }
                .padding(.horizontal, 14)
            }
        }
    }

    private func favoriteCard(_ memory: Memory) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(formatMemoryDate(memory.memoryDate))
                .font(.system(size: 9))
                .foregroundColor(.gray)
            Text(memory.title)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(Color(red: 0x33/255, green: 0x33/255, blue: 0x33/255))
        }
        .frame(minWidth: 96, alignment: .leading)
        .padding(9)
        .background(
            RoundedRectangle(cornerRadius: 9)
                .fill(favoriteCardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 9)
                        .stroke(favoriteCardBorder, lineWidth: 0.5)
                )
        )
    }

    private func timelineEntry(_ memory: Memory) -> some View {
        HStack(alignment: .top, spacing: 10) {
            VStack(spacing: 0) {
                Circle()
                    .fill(memory.authorId != currentUserProfile.id ? accentColor : yourPurple)
                    .frame(width: 9, height: 9)
                Rectangle()
                    .fill(timelineLineColor)
                    .frame(width: 1)
                    .frame(minHeight: 40)
            }
            .frame(width: 9)

            NavigationLink {
                MemoryDetailView(
                    memory: memory,
                    friendProfile: friendProfile,
                    currentUserProfile: currentUserProfile,
                    accentColor: accentColor
                )
            } label: {
                timelineEntryCard(memory)
            }
            .buttonStyle(.plain)
        }
    }

    private func timelineEntryCard(_ memory: Memory) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(formatMemoryDate(memory.memoryDate))
                .font(.system(size: 9))
                .foregroundColor(.gray)
            Text(memory.title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(entryTitleColor)
            if let body = memory.body, !body.isEmpty {
                Text(body)
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            if let loc = memory.location, !loc.isEmpty {
                Text("📍 \(loc)")
                    .font(.system(size: 9))
                    .foregroundColor(locationPillText)
                    .padding(.vertical, 3)
                    .padding(.horizontal, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(locationPillBg)
                    )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
        )
    }

    private var bestOfTabContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("TIMELINE")
                .font(.system(size: 10, weight: .medium))
                .tracking(0.5)
                .foregroundColor(.gray)
                .padding(.leading, 14)
                .padding(.top, 8)
                .padding(.bottom, 6)

            if favoriteMemories.isEmpty {
                Text("No favorites yet\nLong press a memory to favorite it")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 24)
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(favoriteMemories) { memory in
                        timelineEntry(memory)
                    }
                }
                .padding(.horizontal, 14)
            }
        }
    }

    private var photosTabContent: some View {
        Group {
            if memories.isEmpty {
                Text("No photos yet")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 24)
            } else {
                let columns = [
                    GridItem(.flexible(), spacing: 3),
                    GridItem(.flexible(), spacing: 3),
                    GridItem(.flexible(), spacing: 3)
                ]
                LazyVGrid(columns: columns, spacing: 3) {
                    ForEach(memories) { memory in
                        ZStack(alignment: .bottom) {
                            Rectangle()
                                .aspectRatio(1, contentMode: .fill)
                                .overlay(
                                    LinearGradient(
                                        colors: [photoPlaceholderStart, photoPlaceholderEnd],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                            Text(memory.title)
                                .font(.system(size: 8))
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .padding(6)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    LinearGradient(
                                        colors: [.clear, .black.opacity(0.5)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.top, 8)
            }
        }
    }

    // MARK: - FAB

    private var fab: some View {
        Button {
            showAddMemorySheet = true
        } label: {
            Text("+")
                .font(.system(size: 28, weight: .light))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(accentColor, in: Circle())
        }
        .padding(.trailing, 20)
        .padding(.bottom, 20)
    }
}
