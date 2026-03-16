//
//  AddFriendView.swift
//  SharedJournal
//

import SwiftUI
import Supabase

struct AddFriendView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authState: AuthState

    @State private var searchText: String = ""
    @State private var results: [SearchResult] = []
    @State private var existingFriendIds: Set<UUID> = []

    private let backgroundColor = Color(red: 0xf5 / 255.0, green: 0xf3 / 255.0, blue: 0xff / 255.0)

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header
                Divider()

                searchBar

                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(results) { result in
                            searchResultRow(result: result)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 8)
                }
            }
        }
        .task {
            await loadExistingFriends()
        }
        .onChange(of: searchText) { oldValue, newValue in
            Task {
                await searchUsers(query: newValue)
            }
        }
    }

    private var header: some View {
        HStack {
            Spacer()

            Text("Add friend")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(Color(red: 0x1a / 255.0, green: 0x1a / 255.0, blue: 0x2e / 255.0))

            Spacer()

            Button {
                dismiss()
            } label: {
                Text("✕")
                    .font(.system(size: 16))
                    .foregroundColor(Color(red: 0x99 / 255.0, green: 0x99 / 255.0, blue: 0x99 / 255.0))
            }
            .padding(.trailing, 16)
        }
        .padding(.vertical, 12)
    }

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color.gray)

            TextField("Search by username...", text: $searchText)
                .font(.system(size: 14))
        }
        .padding(14)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(red: 0xdd / 255.0, green: 0xd8 / 255.0, blue: 0xff / 255.0), lineWidth: 0.5)
        )
        .cornerRadius(10)
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }

    private func searchResultRow(result: SearchResult) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(red: 0x5b / 255.0, green: 0x3f / 255.0, blue: 0xf8 / 255.0))
                    .frame(width: 46, height: 46)

                Text(initial(for: result.profile))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(result.profile.displayName)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color(red: 0x1a / 255.0, green: 0x1a / 255.0, blue: 0x2e / 255.0))

                Text("@\(result.profile.username)")
                    .font(.system(size: 12))
                    .foregroundColor(Color(red: 0x99 / 255.0, green: 0x99 / 255.0, blue: 0x99 / 255.0))
            }

            Spacer()

            Button {
                Task {
                    await sendRequest(for: result)
                }
            } label: {
                Text(result.requestSent ? "Sent" : "Add")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(result.requestSent ? Color.gray : Color.white)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 10)
                    .background(result.requestSent ? Color(red: 0xee / 255.0, green: 0xee / 255.0, blue: 0xee / 255.0) :
                                Color(red: 0x5b / 255.0, green: 0x3f / 255.0, blue: 0xf8 / 255.0))
                    .cornerRadius(7)
            }
            .disabled(result.requestSent)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(red: 0xed / 255.0, green: 0xe9 / 255.0, blue: 0xff / 255.0), lineWidth: 0.5)
                )
        )
    }

    private func loadExistingFriends() async {
        guard let currentUser = authState.currentUser else { return }

        do {
            let friendships: [Friendship] = try await SupabaseManager.shared
                .from("friendships")
                .select()
                .or("user_a_id.eq.\(currentUser.id),user_b_id.eq.\(currentUser.id)")
                .execute()
                .value

            var ids = Set<UUID>()
            for friendship in friendships {
                if friendship.userAId == currentUser.id {
                    ids.insert(friendship.userBId)
                } else if friendship.userBId == currentUser.id {
                    ids.insert(friendship.userAId)
                }
            }

            await MainActor.run {
                existingFriendIds = ids
            }
        } catch {
            print("Failed to load existing friends:", error)
        }
    }

    private func searchUsers(query: String) async {
        guard let currentUser = authState.currentUser else { return }
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            await MainActor.run {
                results = []
            }
            return
        }

        do {
            let profiles: [Profile] = try await SupabaseManager.shared
                .from("profiles")
                .select()
                .ilike("username", pattern: "%\(trimmed)%")
                .execute()
                .value

            let filtered = profiles.filter { profile in
                profile.id != currentUser.id && !existingFriendIds.contains(profile.id)
            }

            let mapped = filtered.map { SearchResult(profile: $0, requestSent: false) }

            await MainActor.run {
                results = mapped
            }
        } catch {
            print("Failed to search users:", error)
        }
    }

    private func sendRequest(for result: SearchResult) async {
        guard let currentUser = authState.currentUser else { return }

        let otherId = result.profile.id
        let (userA, userB) = currentUser.id.uuidString < otherId.uuidString
            ? (currentUser.id, otherId)
            : (otherId, currentUser.id)

        struct NewFriendship: Encodable {
            let userAId: UUID
            let userBId: UUID
            let status: String
            let requesterId: UUID

            enum CodingKeys: String, CodingKey {
                case userAId = "user_a_id"
                case userBId = "user_b_id"
                case status
                case requesterId = "requester_id"
            }
        }

        let payload = NewFriendship(
            userAId: userA,
            userBId: userB,
            status: "pending",
            requesterId: currentUser.id
        )

        do {
            _ = try await SupabaseManager.shared
                .from("friendships")
                .insert(payload)
                .execute()

            await MainActor.run {
                if let index = results.firstIndex(where: { $0.id == result.id }) {
                    results[index].requestSent = true
                    existingFriendIds.insert(otherId)
                }
            }
        } catch {
            print("Failed to send friend request:", error)
        }
    }

    private func initial(for profile: Profile) -> String {
        profile.displayName.first.map { String($0) } ?? "?"
    }
}

struct SearchResult: Identifiable {
    let profile: Profile
    var requestSent: Bool

    var id: UUID { profile.id }
}

#Preview {
    AddFriendView()
        .environmentObject(AuthState())
}

