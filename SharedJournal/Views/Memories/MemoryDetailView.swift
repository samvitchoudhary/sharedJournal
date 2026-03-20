//
//  MemoryDetailView.swift
//  SharedJournal
//

import SwiftUI
import Supabase

struct MemoryDetailView: View {
    @Environment(\.dismiss) private var dismiss

    let memory: Memory
    let friendProfile: Profile
    let currentUserProfile: Profile
    let accentColor: Color

    @State private var isFavorite: Bool
    @State private var showMenu: Bool = false

    private let purple = Color(red: 91/255, green: 63/255, blue: 248/255)
    private let headerPurple = Color(red: 0x5b/255, green: 0x3f/255, blue: 0xf8/255)
    private let titleColor = Color(red: 0x1a/255, green: 0x1a/255, blue: 0x2e/255)
    private let bodyGray = Color(red: 0x55/255, green: 0x55/255, blue: 0x55/255)
    private let favoriteStar = Color(red: 245/255, green: 166/255, blue: 35/255)
    private let favoriteBgOff = Color(red: 1, green: 248/255, blue: 224/255)
    private let favoriteBgOn = Color(red: 1, green: 206/255, blue: 0)
    private let favoriteBorder = Color(red: 1, green: 224/255, blue: 170/255)

    init(memory: Memory, friendProfile: Profile, currentUserProfile: Profile, accentColor: Color) {
        self.memory = memory
        self.friendProfile = friendProfile
        self.currentUserProfile = currentUserProfile
        self.accentColor = accentColor
        _isFavorite = State(initialValue: memory.isFavorite)
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color(red: 1, green: 1, blue: 1)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    headerSection
                    photoSection
                    bodySection
                }
            }

            if memory.authorId == currentUserProfile.id {
                favoriteButton
            }
        }
        .navigationBarHidden(true)
        .confirmationDialog("Memory", isPresented: $showMenu, titleVisibility: .visible) {
            if memory.authorId == currentUserProfile.id {
                Button("Edit memory") {}
                Button("Delete memory", role: .destructive) {}
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    private var headerSection: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Text("← \(friendProfile.displayName.isEmpty ? "Friend" : friendProfile.displayName)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(headerPurple)
            }
            .buttonStyle(.plain)

            Spacer()

            Button {
                showMenu = true
            } label: {
                Text("···")
                    .font(.system(size: 20))
                    .foregroundColor(Color(red: 0xbb/255, green: 0xbb/255, blue: 0xbb/255))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

    private var photoSection: some View {
        LinearGradient(
            colors: [
                Color(red: 1, green: 211/255, blue: 181/255),
                Color(red: 1, green: 170/255, blue: 165/255),
                Color(red: 1, green: 154/255, blue: 158/255)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .frame(maxWidth: .infinity)
        .frame(height: 200)
    }

    private var bodySection: some View {
        VStack(alignment: .leading, spacing: 0) {
            authorRow
                .padding(.bottom, 8)

            Text(memory.title)
                .font(.system(size: 22, weight: .medium))
                .foregroundColor(titleColor)
                .tracking(-0.22)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(formatMemoryDate(memory.memoryDate))
                .font(.system(size: 11))
                .foregroundColor(Color(red: 0xbb/255, green: 0xbb/255, blue: 0xbb/255))
                .padding(.top, 4)

            if let body = memory.body, !body.isEmpty {
                Text(body)
                    .font(.system(size: 15))
                    .foregroundColor(bodyGray)
                    .lineSpacing(15 * 0.6)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 12)
            }

            if let loc = memory.location, !loc.isEmpty {
                Text("📍 \(loc)")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(Color(red: 192/255, green: 74/255, blue: 26/255))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(red: 1, green: 243/255, blue: 238/255))
                    )
                    .padding(.top, 12)
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, memory.authorId == currentUserProfile.id ? 80 : 24)
    }

    private var authorRow: some View {
        let isFriendAuthor = memory.authorId == friendProfile.id
        let authorName = isFriendAuthor
            ? (friendProfile.displayName.isEmpty ? "Friend" : friendProfile.displayName)
            : (currentUserProfile.displayName.isEmpty ? "You" : currentUserProfile.displayName)
        let avatarColor = isFriendAuthor ? accentColor : purple

        return HStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(avatarColor)
                    .frame(width: 26, height: 26)
                Text(initial(for: isFriendAuthor ? friendProfile : currentUserProfile))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white)
            }

            Text("Added by \(authorName) · \(formatMemoryDate(memory.memoryDate))")
                .font(.system(size: 11))
                .foregroundColor(Color(red: 0x99/255, green: 0x99/255, blue: 0x99/255))
        }
    }

    private func initial(for profile: Profile) -> String {
        profile.displayName.first.map { String($0) } ?? "?"
    }

    private var favoriteButton: some View {
        Button {
            Task {
                await toggleFavorite()
            }
        } label: {
            Text("★")
                .font(.system(size: 20))
                .foregroundColor(favoriteStar)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(isFavorite ? favoriteBgOn : favoriteBgOff)
                        .overlay(
                            Circle()
                                .stroke(favoriteBorder, lineWidth: 0.5)
                        )
                )
        }
        .buttonStyle(.plain)
        .padding(.trailing, 20)
        .padding(.bottom, 24)
    }

    private func toggleFavorite() async {
        let newValue = !isFavorite
        do {
            try await SupabaseManager.shared
                .from("memories")
                .update(["is_favorite": newValue])
                .eq("id", value: memory.id)
                .execute()
            await MainActor.run {
                isFavorite = newValue
            }
        } catch {
            print("Error toggling favorite: \(error)")
        }
    }
}
