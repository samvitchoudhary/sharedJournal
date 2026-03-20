//
//  AddMemoryView.swift
//  SharedJournal
//

import SwiftUI
import Supabase
import PhotosUI

struct AddMemoryView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authState: AuthState

    let friendship: Friendship
    let friendProfile: Profile
    let accentColor: Color
    let onSave: () -> Void

    @State private var memoryDate: Date = .now
    @State private var title: String = ""
    @State private var bodyText: String = ""
    @State private var location: String = ""
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var loadedImages: [UIImage] = []
    @State private var isSaving: Bool = false
    @State private var errorMessage: String?

    private let backgroundColor = Color(red: 0xf0 / 255.0, green: 0xff / 255.0, blue: 0xf4 / 255.0)
    private let borderColor = Color(red: 0xc8 / 255.0, green: 0xf5 / 255.0, blue: 0xd8 / 255.0)

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    header

                    fieldSection(label: "WITH") {
                        HStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(accentColor)
                                    .frame(width: 22, height: 22)
                                Text(friendProfile.displayName.first.map { String($0) } ?? "?")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.white)
                            }
                            Text(friendProfile.displayName)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color(red: 0x33 / 255.0, green: 0x33 / 255.0, blue: 0x33 / 255.0))
                        }
                        .padding(.vertical, 6)
                    }

                    fieldSection(label: "DATE") {
                        DatePicker("", selection: $memoryDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                    }

                    fieldSection(label: "TITLE") {
                        TextField("Give this memory a title...", text: $title)
                            .font(.system(size: 12))
                            .padding(10)
                            .background(Color.white)
                            .overlay(RoundedRectangle(cornerRadius: 9).stroke(borderColor, lineWidth: 0.5))
                            .cornerRadius(9)
                    }

                    fieldSection(label: "WHAT HAPPENED") {
                        TextEditor(text: $bodyText)
                            .font(.system(size: 12))
                            .scrollContentBackground(.hidden)
                            .padding(10)
                            .frame(minHeight: 80)
                            .background(Color.white)
                            .overlay(RoundedRectangle(cornerRadius: 9).stroke(borderColor, lineWidth: 0.5))
                            .cornerRadius(9)
                            .overlay(alignment: .topLeading) {
                                if bodyText.isEmpty {
                                    Text("Write about this memory...")
                                        .font(.system(size: 12))
                                        .foregroundColor(Color.gray)
                                        .padding(14)
                                        .allowsHitTesting(false)
                                }
                            }
                    }

                    fieldSection(label: "LOCATION (optional)") {
                        TextField("Add a place...", text: $location)
                            .font(.system(size: 12))
                            .padding(10)
                            .background(Color.white)
                            .overlay(RoundedRectangle(cornerRadius: 9).stroke(borderColor, lineWidth: 0.5))
                            .cornerRadius(9)
                    }

                    photosRow

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 12))
                            .foregroundColor(.red)
                            .padding(.horizontal, 14)
                            .padding(.top, 8)
                    }

                    saveButton
                }
                .padding(.bottom, 24)
            }
        }
        .onChange(of: selectedPhotoItems) { oldValue, newValue in
            Task {
                await loadImages(from: newValue)
            }
        }
    }

    private var header: some View {
        HStack {
            Button("Cancel") {
                dismiss()
            }
            .font(.system(size: 11))
            .foregroundColor(Color(red: 0x99 / 255.0, green: 0x99 / 255.0, blue: 0x99 / 255.0))

            Spacer()

            Text("New memory")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(Color(red: 0x1a / 255.0, green: 0x2e / 255.0, blue: 0x1a / 255.0))

            Spacer()

            Button("Save") {
                Task { await saveMemory() }
            }
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(Color(red: 0x2e / 255.0, green: 0xcc / 255.0, blue: 0x71 / 255.0))
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

    private func fieldSection<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(Color(red: 0x33 / 255.0, green: 0x33 / 255.0, blue: 0x33 / 255.0))
            content()
        }
        .padding(.horizontal, 14)
        .padding(.bottom, 10)
    }

    private var photosRow: some View {
        HStack(spacing: 8) {
            ForEach(Array(loadedImages.enumerated()), id: \.offset) { _, image in
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 48, height: 48)
                    .clipped()
                    .cornerRadius(8)
            }

            PhotosPicker(
                selection: $selectedPhotoItems,
                maxSelectionCount: 10,
                matching: .images
            ) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(
                            style: StrokeStyle(lineWidth: 2, dash: [6])
                        )
                        .foregroundColor(Color(red: 0xb2 / 255.0, green: 0xdf / 255.0, blue: 0xcb / 255.0))
                        .frame(width: 48, height: 48)
                    Text("+")
                        .font(.system(size: 22))
                        .foregroundColor(Color(red: 0x5f / 255.0, green: 0xc4 / 255.0, blue: 0x88 / 255.0))
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.top, 8)
    }

    private var saveButton: some View {
        Button {
            Task { await saveMemory() }
        } label: {
            Text("Save memory")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color(red: 0x2e / 255.0, green: 0xcc / 255.0, blue: 0x71 / 255.0))
                .cornerRadius(12)
        }
        .disabled(isSaving)
        .padding(.horizontal, 14)
        .padding(.top, 16)
        .padding(.bottom, 14)
    }

    private func loadImages(from items: [PhotosPickerItem]) async {
        var images: [UIImage] = []
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self),
               let img = UIImage(data: data) {
                images.append(img)
            }
        }
        await MainActor.run {
            loadedImages = images
        }
    }

    private func saveMemory() async {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            await MainActor.run {
                errorMessage = "Please enter a title."
            }
            return
        }

        guard let authorId = authState.currentUser?.id else {
            await MainActor.run { errorMessage = "Not signed in." }
            return
        }

        await MainActor.run {
            isSaving = true
            errorMessage = nil
        }

        do {
            let supabase = SupabaseManager.shared
            let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
            let trimmedBody = bodyText.isEmpty ? nil : bodyText.trimmingCharacters(in: .whitespacesAndNewlines)
            let trimmedLocation = location.isEmpty ? nil : location.trimmingCharacters(in: .whitespacesAndNewlines)

            struct MemoryInsert: Encodable {
                let friendshipId: UUID
                let authorId: UUID
                let title: String
                let body: String?
                let memoryDate: String
                let location: String?
                let isFavorite: Bool
                enum CodingKeys: String, CodingKey {
                    case friendshipId = "friendship_id"
                    case authorId = "author_id"
                    case title
                    case body
                    case memoryDate = "memory_date"
                    case location
                    case isFavorite = "is_favorite"
                }
            }

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let memoryDateString = dateFormatter.string(from: memoryDate)

            let insert = MemoryInsert(
                friendshipId: friendship.id,
                authorId: authorId,
                title: trimmedTitle,
                body: trimmedBody,
                memoryDate: memoryDateString,
                location: trimmedLocation,
                isFavorite: false
            )

            let inserted: [Memory] = try await supabase
                .from("memories")
                .insert(insert)
                .select()
                .execute()
                .value

            guard let memory = inserted.first else {
                throw NSError(domain: "AddMemory", code: -1, userInfo: [NSLocalizedDescriptionKey: "Insert did not return memory"])
            }

            let memoryId = memory.id
            let friendshipIdStr = friendship.id.uuidString
            let memoryIdStr = memoryId.uuidString

            for (index, image) in loadedImages.enumerated() {
                guard let jpegData = image.jpegData(compressionQuality: 0.8) else { continue }
                let fileName = "\(UUID().uuidString).jpg"
                let path = "\(friendshipIdStr)/\(memoryIdStr)/\(fileName)"

                try await supabase.storage
                    .from("memory-photos")
                    .upload(path, data: jpegData)

                let publicURL = try supabase.storage.from("memory-photos").getPublicURL(path: path).absoluteString

                struct PhotoInsert: Encodable {
                    let memoryId: UUID
                    let url: String
                    let displayOrder: Int
                    let uploadedBy: UUID
                    enum CodingKeys: String, CodingKey {
                        case memoryId = "memory_id"
                        case url
                        case displayOrder = "display_order"
                        case uploadedBy = "uploaded_by"
                    }
                }
                let photoInsert = PhotoInsert(
                    memoryId: memoryId,
                    url: publicURL,
                    displayOrder: index,
                    uploadedBy: authorId
                )
                try await supabase.from("photos").insert(photoInsert).execute()
            }

            await MainActor.run {
                isSaving = false
                onSave()
                dismiss()
            }
        } catch {
            await MainActor.run {
                isSaving = false
                errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    AddMemoryView(
        friendship: Friendship(id: UUID(), userAId: UUID(), userBId: UUID(), coverPhotoUrl: nil, status: "accepted", requesterId: UUID(), createdAt: Date()),
        friendProfile: Profile(id: UUID(), username: "friend", displayName: "Friend", avatarUrl: nil, createdAt: Date()),
        accentColor: .green,
        onSave: {}
    )
    .environmentObject(AuthState())
}
