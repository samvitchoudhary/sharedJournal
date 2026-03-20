//
//  NotificationsView.swift
//  SharedJournal
//

import SwiftUI

struct AppNotification: Identifiable {
    let id = UUID()
    let friendName: String
    let friendInitial: String
    let accentColor: Color
    let message: String
    let timeAgo: String
    let isUnread: Bool
}

let mockNotifications: [AppNotification] = [
    AppNotification(
        friendName: "Test User",
        friendInitial: "T",
        accentColor: Color(red: 1, green: 107/255, blue: 53/255),
        message: "Test User added a new memory",
        timeAgo: "2 hours ago",
        isUnread: true
    ),
    AppNotification(
        friendName: "Test User",
        friendInitial: "T",
        accentColor: Color(red: 1, green: 107/255, blue: 53/255),
        message: "Test User favorited a memory",
        timeAgo: "Yesterday",
        isUnread: true
    ),
    AppNotification(
        friendName: "Test User",
        friendInitial: "T",
        accentColor: Color(red: 1, green: 107/255, blue: 53/255),
        message: "Test User sent you a friend request",
        timeAgo: "Mar 16",
        isUnread: false
    )
]

struct NotificationsView: View {
    private let notifications = mockNotifications

    private let bgColor = Color(red: 0xf5 / 255, green: 0xf3 / 255, blue: 0xff / 255)
    private let titleColor = Color(red: 0x1a / 255, green: 0x1a / 255, blue: 0x2e / 255)
    private let nameBoldColor = Color(red: 0x1a / 255, green: 0x1a / 255, blue: 0x2e / 255)
    private let actionColor = Color(red: 0x55 / 255, green: 0x55 / 255, blue: 0x55 / 255)
    private let timeColor = Color(red: 0xbb / 255, green: 0xbb / 255, blue: 0xbb / 255)
    private let borderColor = Color(red: 0xed / 255, green: 0xe9 / 255, blue: 0xff / 255)
    private let readDotColor = Color(red: 0xdd / 255, green: 0xdd / 255, blue: 0xdd / 255)
    private let unreadCardBg = Color(red: 0xf5 / 255, green: 0xf3 / 255, blue: 0xff / 255)

    var body: some View {
        ZStack {
            bgColor
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Text("Notifications")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(titleColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 18)
                    .padding(.bottom, 12)

                if notifications.isEmpty {
                    Spacer()
                    Text("No notifications yet")
                        .font(.system(size: 16))
                        .foregroundColor(Color(red: 0x99 / 255, green: 0x99 / 255, blue: 0x99 / 255))
                        .frame(maxWidth: .infinity)
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(notifications) { item in
                                notificationRow(item)
                            }
                        }
                        .padding(.horizontal, 12)
                    }
                }
            }
        }
    }

    private func notificationRow(_ item: AppNotification) -> some View {
        let actionText = messageSuffix(from: item.message, friendName: item.friendName)

        return HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(item.isUnread ? item.accentColor : readDotColor)
                .frame(width: 8, height: 8)
                .padding(.top, 16)

            ZStack {
                Circle()
                    .fill(item.accentColor)
                    .frame(width: 40, height: 40)
                Text(item.friendInitial)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
            }
            .padding(.top, 4)

            VStack(alignment: .leading, spacing: 4) {
                (Text(item.friendName)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(nameBoldColor)
                + Text(" " + actionText)
                    .font(.system(size: 13))
                    .foregroundColor(actionColor))
                    .fixedSize(horizontal: false, vertical: true)

                Text(item.timeAgo)
                    .font(.system(size: 10))
                    .foregroundColor(timeColor)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(item.isUnread ? unreadCardBg : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(borderColor, lineWidth: 0.5)
                )
        )
    }

    private func messageSuffix(from message: String, friendName: String) -> String {
        if message.hasPrefix(friendName) {
            let rest = message.dropFirst(friendName.count)
            return String(rest).trimmingCharacters(in: .whitespaces)
        }
        return message
    }
}

#Preview {
    NavigationStack {
        NotificationsView()
    }
}
