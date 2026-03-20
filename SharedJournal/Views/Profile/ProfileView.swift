//
//  ProfileView.swift
//  SharedJournal
//

import SwiftUI
import Supabase

struct ProfileView: View {
    @EnvironmentObject var authState: AuthState

    @State private var friendsCount: Int = 0
    @State private var memoriesCount: Int = 0
    @State private var showEditProfile: Bool = false

    private let bgColor = Color(red: 0xf5 / 255, green: 0xf3 / 255, blue: 0xff / 255)
    private let heroStart = Color(red: 0x5b / 255, green: 0x3f / 255, blue: 0xf8 / 255)
    private let heroEnd = Color(red: 0x9b / 255, green: 0x8b / 255, blue: 0xe0 / 255)
    private let rowText = Color(red: 0x33 / 255, green: 0x33 / 255, blue: 0x33 / 255)
    private let chevronColor = Color(red: 0xcc / 255, green: 0xcc / 255, blue: 0xcc / 255)
    private let borderColor = Color(red: 0xed / 255, green: 0xe9 / 255, blue: 0xff / 255)

    var body: some View {
        ZStack {
            bgColor
                .ignoresSafeArea()

            VStack(spacing: 0) {
                heroSection

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        sectionLabel("Account")

                        VStack(spacing: 0) {
                            Button {
                                showEditProfile = true
                            } label: {
                                settingsRowContent(emoji: "✏️", title: "Edit profile")
                            }
                            .buttonStyle(.plain)
                            .overlay(alignment: .top) {
                                Rectangle()
                                    .fill(borderColor)
                                    .frame(height: 0.5)
                            }
                            .overlay(alignment: .bottom) {
                                Rectangle()
                                    .fill(borderColor)
                                    .frame(height: 0.5)
                            }

                            NavigationLink {
                                Text("Notifications")
                            } label: {
                                settingsRowContent(emoji: "🔔", title: "Notifications")
                            }
                            .buttonStyle(.plain)
                            .overlay(alignment: .bottom) {
                                Rectangle()
                                    .fill(borderColor)
                                    .frame(height: 0.5)
                            }

                            NavigationLink {
                                Text("Privacy")
                            } label: {
                                settingsRowContent(emoji: "🔒", title: "Privacy")
                            }
                            .buttonStyle(.plain)
                            .overlay(alignment: .bottom) {
                                Rectangle()
                                    .fill(borderColor)
                                    .frame(height: 0.5)
                            }
                        }
                        .background(Color.white)

                        sectionLabel("More")

                        VStack(spacing: 0) {
                            Button {} label: {
                                settingsRowContent(emoji: "⭐", title: "Rate SharedJournal")
                            }
                            .buttonStyle(.plain)
                            .overlay(alignment: .top) {
                                Rectangle()
                                    .fill(borderColor)
                                    .frame(height: 0.5)
                            }
                            .overlay(alignment: .bottom) {
                                Rectangle()
                                    .fill(borderColor)
                                    .frame(height: 0.5)
                            }

                            Button {} label: {
                                settingsRowContent(emoji: "💬", title: "Send feedback")
                            }
                            .buttonStyle(.plain)
                            .overlay(alignment: .bottom) {
                                Rectangle()
                                    .fill(borderColor)
                                    .frame(height: 0.5)
                            }
                        }
                        .background(Color.white)

                        signOutButton
                    }
                }
            }
        }
        .task {
            await loadStats()
        }
        .sheet(isPresented: $showEditProfile) {
            EditProfileView()
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        ZStack {
            LinearGradient(
                colors: [heroStart, heroEnd],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 200)

            if let user = authState.currentUser {
                VStack(spacing: 0) {
                    avatarView(for: user)
                        .padding(.bottom, 10)

                    Text(user.displayName.isEmpty ? "User" : user.displayName)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)

                    Text("@\(user.username)")
                        .font(.system(size: 11))
                        .foregroundColor(Color.white.opacity(0.65))
                        .padding(.top, 3)

                    HStack(spacing: 24) {
                        statColumn(value: friendsCount, label: "friends")
                        statColumn(value: memoriesCount, label: "memories")
                    }
                    .padding(.top, 14)
                }
            }
        }
        .frame(height: 200)
    }

    @ViewBuilder
    private func avatarView(for user: Profile) -> some View {
        if let urlString = user.avatarUrl, let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    placeholderAvatar(initial: initial(for: user))
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 64, height: 64)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.6), lineWidth: 2)
                        )
                case .failure:
                    placeholderAvatar(initial: initial(for: user))
                @unknown default:
                    placeholderAvatar(initial: initial(for: user))
                }
            }
        } else {
            placeholderAvatar(initial: initial(for: user))
        }
    }

    private func placeholderAvatar(initial: String) -> some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.3))
                .frame(width: 64, height: 64)
            Text(initial)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.white)
        }
        .overlay(
            Circle()
                .stroke(Color.white.opacity(0.6), lineWidth: 2)
                .frame(width: 64, height: 64)
        )
    }

    private func initial(for profile: Profile) -> String {
        profile.displayName.first.map { String($0) } ?? "?"
    }

    private func statColumn(value: Int, label: String) -> some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(Color.white.opacity(0.6))
        }
    }

    // MARK: - Settings rows

    private func sectionLabel(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.system(size: 10))
            .foregroundColor(Color(red: 0xbb / 255, green: 0xbb / 255, blue: 0xbb / 255))
            .tracking(0.7)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 5)
    }

    private func settingsRowContent(emoji: String, title: String) -> some View {
        HStack {
            Text(emoji)
                .font(.system(size: 14))
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(rowText)
            Spacer()
            Text("›")
                .font(.system(size: 14))
                .foregroundColor(chevronColor)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
    }

    private var signOutButton: some View {
        Button {
            Task {
                await authState.signOut()
            }
        } label: {
            Text("Sign out")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(red: 0xcc / 255, green: 0x33 / 255, blue: 0x33 / 255))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 1, green: 0xee / 255, blue: 0xee / 255))
                )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 14)
        .padding(.top, 16)
        .padding(.bottom, 32)
    }

    // MARK: - Data

    private func loadStats() async {
        guard let userId = authState.currentUser?.id else {
            await MainActor.run {
                friendsCount = 0
                memoriesCount = 0
            }
            return
        }

        do {
            let friendships: [Friendship] = try await SupabaseManager.shared
                .from("friendships")
                .select()
                .or("user_a_id.eq.\(userId),user_b_id.eq.\(userId)")
                .eq("status", value: "accepted")
                .execute()
                .value

            let friendCount = friendships.count
            let friendshipIds = friendships.map { $0.id.uuidString }

            var memoryTotal = 0
            if !friendshipIds.isEmpty {
                let memories: [Memory] = try await SupabaseManager.shared
                    .from("memories")
                    .select()
                    .in("friendship_id", values: friendshipIds)
                    .execute()
                    .value
                memoryTotal = memories.count
            }

            await MainActor.run {
                friendsCount = friendCount
                memoriesCount = memoryTotal
            }
        } catch {
            print("Failed to load profile stats: \(error)")
            await MainActor.run {
                friendsCount = 0
                memoriesCount = 0
            }
        }
    }
}

// MARK: - Placeholder

struct EditProfileView: View {
    var body: some View {
        Text("Edit profile")
            .padding()
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .environmentObject(AuthState())
    }
}
