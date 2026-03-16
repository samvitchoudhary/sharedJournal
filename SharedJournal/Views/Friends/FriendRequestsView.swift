//
//  FriendRequestsView.swift
//  SharedJournal
//

import SwiftUI
import Supabase

struct FriendRequestsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authState: AuthState

    @State private var incoming: [RequestItem] = []
    @State private var outgoing: [RequestItem] = []
    @State private var isLoading: Bool = true

    private let backgroundColor = Color(red: 0xf5 / 255.0, green: 0xf3 / 255.0, blue: 0xff / 255.0)

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    header

                    if isLoading {
                        Spacer()
                        ProgressView()
                        Spacer()
                    } else if incoming.isEmpty && outgoing.isEmpty {
                        Spacer()
                        Text("No pending requests")
                            .font(.system(size: 14))
                            .foregroundColor(Color(red: 0x99 / 255.0, green: 0x99 / 255.0, blue: 0x99 / 255.0))
                        Spacer()
                    } else {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 16) {
                                if !incoming.isEmpty {
                                    section(label: "INCOMING") {
                                        ForEach(incoming) { item in
                                            incomingCard(for: item)
                                        }
                                    }
                                }

                                if !outgoing.isEmpty {
                                    section(label: "SENT") {
                                        ForEach(outgoing) { item in
                                            outgoingCard(for: item)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 12)
                        }
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .task {
                await loadRequests()
            }
        }
    }

    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Text("← Back")
                    .font(.system(size: 10))
                    .foregroundColor(Color(red: 0x5b / 255.0, green: 0x3f / 255.0, blue: 0xf8 / 255.0))
            }

            Spacer()

            Text("Requests")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(red: 0x1a / 255.0, green: 0x1a / 255.0, blue: 0x2e / 255.0))

            Spacer()

            Spacer().frame(width: 44)
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    private func section<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color(red: 0xbb / 255.0, green: 0xbb / 255.0, blue: 0xbb / 255.0))
                .kerning(0.07 * 11)
                .padding(.bottom, 10)

            content()
        }
    }

    private func incomingCard(for item: RequestItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                avatar(for: item)

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.otherUser.displayName)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(red: 0x1a / 255.0, green: 0x1a / 255.0, blue: 0x2e / 255.0))

                    Text("@\(item.otherUser.username)")
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 0xaa / 255.0, green: 0xaa / 255.0, blue: 0xaa / 255.0))
                }

                Spacer()
            }

            HStack(spacing: 6) {
                Button {
                    Task {
                        await accept(item: item)
                    }
                } label: {
                    Text("Accept")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color(red: 0x5b / 255.0, green: 0x3f / 255.0, blue: 0xf8 / 255.0))
                        .cornerRadius(7)
                }

                Button {
                    Task {
                        await decline(item: item)
                    }
                } label: {
                    Text("Decline")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(red: 0x5b / 255.0, green: 0x3f / 255.0, blue: 0xf8 / 255.0))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color(red: 0xed / 255.0, green: 0xe9 / 255.0, blue: 0xff / 255.0))
                        .cornerRadius(7)
                }
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(red: 0xed / 255.0, green: 0xe9 / 255.0, blue: 0xff / 255.0), lineWidth: 0.5)
                )
        )
    }

    private func outgoingCard(for item: RequestItem) -> some View {
        HStack(spacing: 10) {
            avatar(for: item)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.otherUser.displayName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(red: 0x1a / 255.0, green: 0x1a / 255.0, blue: 0x2e / 255.0))

                Text("@\(item.otherUser.username)")
                    .font(.system(size: 12))
                    .foregroundColor(Color(red: 0xaa / 255.0, green: 0xaa / 255.0, blue: 0xaa / 255.0))
            }

            Spacer()

            Text("Pending")
                .font(.system(size: 10))
                .foregroundColor(Color(red: 0xbb / 255.0, green: 0xbb / 255.0, blue: 0xbb / 255.0))
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(red: 0xed / 255.0, green: 0xe9 / 255.0, blue: 0xff / 255.0), lineWidth: 0.5)
                )
        )
    }

    private func avatar(for item: RequestItem) -> some View {
        ZStack {
            Circle()
                .fill(item.accentColor)
                .frame(width: 38, height: 38)

            Text(initial(for: item.otherUser))
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
        }
    }

    private func loadRequests() async {
        guard let currentUser = authState.currentUser else {
            await MainActor.run {
                incoming = []
                outgoing = []
                isLoading = false
            }
            return
        }

        isLoading = true

        do {
            let friendships: [Friendship] = try await SupabaseManager.shared
                .from("friendships")
                .select()
                .eq("status", value: "pending")
                .or("user_a_id.eq.\(currentUser.id),user_b_id.eq.\(currentUser.id)")
                .execute()
                .value

            var incomingItems: [RequestItem] = []
            var outgoingItems: [RequestItem] = []

            let accentColors: [Color] = [
                Color(red: 0xff / 255.0, green: 0x6b / 255.0, blue: 0x35 / 255.0),
                Color(red: 0x5b / 255.0, green: 0x3f / 255.0, blue: 0xf8 / 255.0),
                Color(red: 0x2e / 255.0, green: 0xcc / 255.0, blue: 0x71 / 255.0),
                Color(red: 0xff / 255.0, green: 0xce / 255.0, blue: 0x00 / 255.0),
                Color(red: 0x00 / 255.0, green: 0xbc / 255.0, blue: 0xd4 / 255.0)
            ]

            for (index, friendship) in friendships.enumerated() {
                let otherId = friendship.userAId == currentUser.id ? friendship.userBId : friendship.userAId

                let profiles: [Profile] = try await SupabaseManager.shared
                    .from("profiles")
                    .select()
                    .eq("id", value: otherId)
                    .limit(1)
                    .execute()
                    .value

                guard let otherProfile = profiles.first else { continue }

                let color = accentColors[index % accentColors.count]
                let item = RequestItem(friendship: friendship, otherUser: otherProfile, accentColor: color)

                if friendship.requesterId == currentUser.id {
                    outgoingItems.append(item)
                } else {
                    incomingItems.append(item)
                }
            }

            await MainActor.run {
                incoming = incomingItems
                outgoing = outgoingItems
                isLoading = false
            }
        } catch {
            print("Failed to load friend requests:", error)
            await MainActor.run {
                incoming = []
                outgoing = []
                isLoading = false
            }
        }
    }

    private func accept(item: RequestItem) async {
        do {
            _ = try await SupabaseManager.shared
                .from("friendships")
                .update(["status": "accepted"])
                .eq("id", value: item.friendship.id)
                .execute()

            await MainActor.run {
                incoming.removeAll { $0.id == item.id }
            }
        } catch {
            print("Failed to accept request:", error)
        }
    }

    private func decline(item: RequestItem) async {
        do {
            _ = try await SupabaseManager.shared
                .from("friendships")
                .delete()
                .eq("id", value: item.friendship.id)
                .execute()

            await MainActor.run {
                incoming.removeAll { $0.id == item.id }
            }
        } catch {
            print("Failed to decline request:", error)
        }
    }

    private func initial(for profile: Profile) -> String {
        profile.displayName.first.map { String($0) } ?? "?"
    }
}

struct RequestItem: Identifiable {
    let friendship: Friendship
    let otherUser: Profile
    let accentColor: Color

    var id: UUID { friendship.id }
}

#Preview {
    FriendRequestsView()
        .environmentObject(AuthState())
}

