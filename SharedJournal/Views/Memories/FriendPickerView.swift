//
//  FriendPickerView.swift
//  SharedJournal
//

import SwiftUI

struct FriendPickerView: View {
    @Environment(\.dismiss) private var dismiss

    let friendships: [Friendship]
    let friendProfiles: [UUID: Profile]
    let accentColors: [UUID: Color]
    let memories: [Memory]
    let onSelect: (Friendship, Profile, Color) -> Void

    private let backgroundColor = Color(red: 0xf5 / 255.0, green: 0xf3 / 255.0, blue: 0xff / 255.0)
    private let titleColor = Color(red: 0x1a / 255.0, green: 0x1a / 255.0, blue: 0x2e / 255.0)

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header
                Divider()
                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    private var header: some View {
        ZStack {
            Text("Add a memory with...")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(titleColor)

            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Text("✕")
                        .font(.system(size: 18))
                        .foregroundColor(Color(red: 0x99 / 255.0, green: 0x99 / 255.0, blue: 0x99 / 255.0))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    @ViewBuilder
    private var content: some View {
        if friendships.isEmpty {
            Text("Add some friends first!")
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(friendships, id: \.id) { friendship in
                        if let profile = friendProfiles[friendship.id],
                           let color = accentColors[friendship.id] {
                            Button {
                                print("Friend selected: \(profile.displayName), friendship: \(friendship.id)")
                                onSelect(friendship, profile, color)
                            } label: {
                                friendRow(profile: profile, accentColor: color, memoryCount: memoryCount(for: friendship.id))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(16)
            }
        }
    }

    private func memoryCount(for friendshipId: UUID) -> Int {
        memories.filter { $0.friendshipId == friendshipId }.count
    }

    private func friendRow(profile: Profile, accentColor: Color, memoryCount: Int) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(accentColor)
                    .frame(width: 50, height: 50)

                Text(profile.displayName.first.map { String($0) } ?? "?")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(profile.displayName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(titleColor)

                Text("\(memoryCount) memories together")
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
}
