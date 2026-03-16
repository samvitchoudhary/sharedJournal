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

    private static var friendsSinceFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM yyyy"
        return f
    }()

    var body: some View {
        let _ = print("FriendProfileView body rendering - friendship: \(friendship.id), friend: \(friendProfile.displayName)")
        ZStack(alignment: .bottomTrailing) {
            Color.red.ignoresSafeArea()

            Text("DEBUG: \(friendProfile.displayName)")
                .foregroundColor(.black)
                .font(.largeTitle)
                .zIndex(999)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    coverSection
                    mainContent
                }
            }

            fab
        }
        .navigationBarBackButtonHidden(true)
        .task {
            print("Task started - fetching memories for friendship: \(friendship.id)")
            do {
                memories = try await SupabaseManager.shared
                    .from("memories")
                    .select()
                    .eq("friendship_id", value: friendship.id)
                    .order("memory_date", ascending: false)
                    .execute()
                    .value
                print("Fetched \(memories.count) memories")
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Cover (100pt)

    private var coverSection: some View {
        ZStack(alignment: .topLeading) {
            LinearGradient(
                colors: [accentColor, Color(red: 1, green: 206/255, blue: 0)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 100)

            HStack {
                Button {
                    dismiss()
                } label: {
                    Text("← Back")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
                .padding(.leading, 16)
                .padding(.top, 12)

                Spacer()

                Button {
                    // edit photo
                } label: {
                    Text("edit photo")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.25))
                }
                .padding(.trailing, 16)
                .padding(.top, 12)
            }
        }
        .frame(height: 100)
    }

    // MARK: - Main content

    private var mainContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(friendProfile.displayName.isEmpty ? "Friend" : friendProfile.displayName) & You")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(Color(red: 0x1a/255, green: 0x1a/255, blue: 0x2e/255))

                Text("Friends since \(Self.friendsSinceFormatter.string(from: friendship.createdAt))")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 14)

            // Tabs
            Picker("", selection: $selectedTab) {
                Text("All").tag(0)
                Text("Best of").tag(1)
                Text("Photos").tag(2)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 14)

            tabContent
                .padding(.horizontal, 14)
                .padding(.bottom, 80)
        }
        .padding(.top, 12)
    }

    @ViewBuilder
    private var tabContent: some View {
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

    private var allTabContent: some View {
        Group {
            if memories.isEmpty {
                Text("No memories yet")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 24)
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(memories) { memory in
                        memoryCard(memory)
                    }
                }
                .padding(.top, 8)
            }
        }
    }

    private func memoryCard(_ memory: Memory) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(memory.title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(red: 0x1a/255, green: 0x1a/255, blue: 0x2e/255))
            Text(Self.friendsSinceFormatter.string(from: memory.memoryDate))
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
        )
    }

    private var bestOfTabContent: some View {
        Text("Best of")
            .font(.system(size: 15))
            .foregroundColor(.gray)
            .frame(maxWidth: .infinity)
            .padding(.top, 24)
    }

    private var photosTabContent: some View {
        Text("Photos")
            .font(.system(size: 15))
            .foregroundColor(.gray)
            .frame(maxWidth: .infinity)
            .padding(.top, 24)
    }

    // MARK: - FAB

    private var fab: some View {
        Button {
            // Add memory
        } label: {
            Text("+")
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(accentColor, in: Circle())
        }
        .padding(.trailing, 20)
        .padding(.bottom, 24)
    }
}
