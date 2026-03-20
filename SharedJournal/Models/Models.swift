//
//  Models.swift
//  SharedJournal
//

import Foundation

struct Profile: Codable, Identifiable {
    let id: UUID
    let username: String
    let displayName: String
    let avatarUrl: String?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case username
        case displayName = "display_name"
        case avatarUrl = "avatar_url"
        case createdAt = "created_at"
    }
}

struct Friendship: Codable, Identifiable {
    let id: UUID
    let userAId: UUID
    let userBId: UUID
    let coverPhotoUrl: String?
    let status: String
    let requesterId: UUID
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userAId = "user_a_id"
        case userBId = "user_b_id"
        case coverPhotoUrl = "cover_photo_url"
        case status
        case requesterId = "requester_id"
        case createdAt = "created_at"
    }
}

struct Memory: Codable, Identifiable {
    let id: UUID
    let friendshipId: UUID
    let authorId: UUID
    let title: String
    let body: String?
    let memoryDate: String
    let location: String?
    let isFavorite: Bool
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case friendshipId = "friendship_id"
        case authorId = "author_id"
        case title
        case body
        case memoryDate = "memory_date"
        case location
        case isFavorite = "is_favorite"
        case createdAt = "created_at"
    }
}

/// Formats a Supabase `memory_date` string like `"2026-03-20"` for display.
func formatMemoryDate(_ dateString: String) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    guard let date = formatter.date(from: dateString) else { return dateString }
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter.string(from: date)
}

struct Photo: Codable, Identifiable {
    let id: UUID
    let memoryId: UUID
    let url: String
    let displayOrder: Int
    let uploadedBy: UUID
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case memoryId = "memory_id"
        case url
        case displayOrder = "display_order"
        case uploadedBy = "uploaded_by"
        case createdAt = "created_at"
    }
}

