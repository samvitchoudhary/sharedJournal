//
//  AddMemoryView.swift
//  SharedJournal
//

import SwiftUI
import Supabase
import PhotosUI

struct AddMemoryView: View {
    let friendship: Friendship
    let friendProfile: Profile
    let accentColor: Color
    let onSave: () -> Void

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authState: AuthState

    @State private var title = ""
    @State private var memoryBody = ""
    @State private var memoryDate = Date()
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    @State private var isLoading = false
    @State private var errorMessage: String? = nil

    var body: some View {
        ZStack {
            Color(red: 240/255, green: 1, blue: 244/255).ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Color(white: 0.6))
                        .font(.system(size: 13))
                    Spacer()
                    Text("New memory")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color(red: 26/255, green: 46/255, blue: 26/255))
                    Spacer()
                    Button("Save") {
                        Task { await saveMemory() }
                    }
                    .foregroundColor(Color(red: 46/255, green: 204/255, blue: 113/255))
                    .font(.system(size: 13, weight: .medium))
                    .disabled(isLoading || title.isEmpty)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 12)

                ScrollView {
                    VStack(spacing: 0) {
                        // With chip
                        HStack {
                            Text("WITH")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(Color(white: 0.53))
                                .tracking(1)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 5)

                        HStack(spacing: 8) {
                            Circle()
                                .fill(accentColor)
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Text(String(friendProfile.displayName.prefix(1)))
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundColor(.white)
                                )
                            Text(friendProfile.displayName)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color(red: 51/255, green: 51/255, blue: 51/255))
                            Spacer()
                        }
                        .padding(10)
                        .background(Color.white)
                        .cornerRadius(9)
                        .overlay(RoundedRectangle(cornerRadius: 9).stroke(Color(red: 200/255, green: 245/255, blue: 216/255), lineWidth: 0.5))
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)

                        // Date
                        VStack(alignment: .leading, spacing: 4) {
                            Text("DATE")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(Color(white: 0.53))
                                .tracking(1)
                            DatePicker("", selection: $memoryDate, displayedComponents: .date)
                                .labelsHidden()
                                .padding(10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white)
                                .cornerRadius(9)
                                .overlay(RoundedRectangle(cornerRadius: 9).stroke(Color(red: 200/255, green: 245/255, blue: 216/255), lineWidth: 0.5))
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)

                        // Title
                        VStack(alignment: .leading, spacing: 4) {
                            Text("TITLE")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(Color(white: 0.53))
                                .tracking(1)
                            TextField("Give this memory a title...", text: $title)
                                .font(.system(size: 13))
                                .padding(10)
                                .background(Color.white)
                                .cornerRadius(9)
                                .overlay(RoundedRectangle(cornerRadius: 9).stroke(Color(red: 200/255, green: 245/255, blue: 216/255), lineWidth: 0.5))
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)

                        // Body
                        VStack(alignment: .leading, spacing: 4) {
                            Text("WHAT HAPPENED?")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(Color(white: 0.53))
                                .tracking(1)
                            ZStack(alignment: .topLeading) {
                                if memoryBody.isEmpty {
                                    Text("Write about this memory...")
                                        .font(.system(size: 13))
                                        .foregroundColor(Color(white: 0.75))
                                        .padding(10)
                                }
                                TextEditor(text: $memoryBody)
                                    .font(.system(size: 13))
                                    .frame(height: 100)
                                    .padding(6)
                                    .scrollContentBackground(.hidden)
                            }
                            .background(Color.white)
                            .cornerRadius(9)
                            .overlay(RoundedRectangle(cornerRadius: 9).stroke(Color(red: 200/255, green: 245/255, blue: 216/255), lineWidth: 0.5))
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)

                        // Photos
                        VStack(alignment: .leading, spacing: 4) {
                            Text("PHOTOS")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(Color(white: 0.53))
                                .tracking(1)
                            HStack(spacing: 8) {
                                ForEach(Array(selectedImages.enumerated()), id: \.offset) { _, image in
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 56, height: 56)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                                PhotosPicker(selection: $selectedPhotos, maxSelectionCount: 5, matching: .images) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [4]))
                                            .foregroundColor(Color(red: 178/255, green: 223/255, blue: 203/255))
                                            .frame(width: 56, height: 56)
                                        Text("+")
                                            .font(.system(size: 24, weight: .light))
                                            .foregroundColor(Color(red: 95/255, green: 196/255, blue: 136/255))
                                    }
                                }
                                .onChange(of: selectedPhotos) { _, newItems in
                                    Task {
                                        selectedImages = []
                                        for item in newItems {
                                            if let data = try? await item.loadTransferable(type: Data.self),
                                               let image = UIImage(data: data) {
                                                selectedImages.append(image)
                                            }
                                        }
                                    }
                                }
                                Spacer()
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)

                        if let error = errorMessage {
                            Text(error)
                                .font(.system(size: 12))
                                .foregroundColor(.red)
                                .padding(.horizontal, 16)
                                .padding(.bottom, 8)
                        }

                        // Save button
                        Button {
                            Task { await saveMemory() }
                        } label: {
                            if isLoading {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 13)
                            } else {
                                Text("Save memory")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 13)
                            }
                        }
                        .background(title.isEmpty ? Color.gray.opacity(0.4) : Color(red: 46/255, green: 204/255, blue: 113/255))
                        .cornerRadius(12)
                        .disabled(isLoading || title.isEmpty)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 30)
                    }
                }
            }
        }
    }

    func saveMemory() async {
        guard let currentUser = authState.currentUser else { return }
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let memoryDateString = dateFormatter.string(from: memoryDate)

        do {
            struct MemoryInsert: Encodable {
                let friendship_id: UUID
                let author_id: UUID
                let title: String
                let body: String?
                let memory_date: String
                let is_favorite: Bool
            }

            let inserted: [Memory] = try await SupabaseManager.shared
                .from("memories")
                .insert(MemoryInsert(
                    friendship_id: friendship.id,
                    author_id: currentUser.id,
                    title: title,
                    body: memoryBody.isEmpty ? nil : memoryBody,
                    memory_date: memoryDateString,
                    is_favorite: false
                ))
                .select()
                .execute()
                .value

            guard let newMemory = inserted.first else {
                throw NSError(domain: "AddMemory", code: -1, userInfo: [NSLocalizedDescriptionKey: "Insert did not return a memory"])
            }

            let supabase = SupabaseManager.shared
            for (index, image) in selectedImages.enumerated() {
                guard let imageData = image.jpegData(compressionQuality: 0.8) else { continue }
                let fileName = "\(UUID().uuidString).jpg"
                let photoPath = "\(friendship.id.uuidString)/\(newMemory.id.uuidString)/\(fileName)"

                try await supabase.storage
                    .from("memory-photos")
                    .upload(photoPath, data: imageData)

                let publicURL = try supabase.storage.from("memory-photos").getPublicURL(path: photoPath).absoluteString

                struct PhotoInsert: Encodable {
                    let memory_id: UUID
                    let url: String
                    let display_order: Int
                    let uploaded_by: UUID
                }

                try await supabase
                    .from("photos")
                    .insert(PhotoInsert(
                        memory_id: newMemory.id,
                        url: publicURL,
                        display_order: index,
                        uploaded_by: currentUser.id
                    ))
                    .execute()
            }

            await MainActor.run {
                isLoading = false
                onSave()
                dismiss()
            }
        } catch {
            await MainActor.run {
                isLoading = false
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
