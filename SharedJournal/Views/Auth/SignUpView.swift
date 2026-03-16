//
//  SignUpView.swift
//  SharedJournal
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authState: AuthState

    @State private var displayName: String = ""
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    private let backgroundColor = Color(red: 0xf5 / 255.0, green: 0xf3 / 255.0, blue: 0xff / 255.0)
    private let accentColor = Color(red: 0x5b / 255.0, green: 0x3f / 255.0, blue: 0xf8 / 255.0)

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Button {
                        dismiss()
                    } label: {
                        Text("← Back")
                            .font(.system(size: 10))
                            .foregroundColor(accentColor)
                    }
                    .padding(.top, 16)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Create account")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(Color(red: 0x1a / 255.0, green: 0x1a / 255.0, blue: 0x2e / 255.0))

                        Text("You'll use this to find friends")
                            .font(.system(size: 13))
                            .foregroundColor(Color(red: 0x88 / 255.0, green: 0x88 / 255.0, blue: 0x88 / 255.0))
                    }
                    .padding(.top, 8)

                    // Avatar picker
                    HStack {
                        Spacer()
                        Button {
                            // Avatar picker action to be implemented
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(Color(red: 0xed / 255.0, green: 0xe9 / 255.0, blue: 0xff / 255.0))
                                    .frame(width: 54, height: 54)
                                    .overlay(
                                        Circle()
                                            .strokeBorder(
                                                style: StrokeStyle(
                                                    lineWidth: 2,
                                                    dash: [6]
                                                )
                                            )
                                            .foregroundColor(Color(red: 0xb3 / 255.0, green: 0xa6 / 255.0, blue: 0xf0 / 255.0))
                                    )

                                Text("+")
                                    .font(.system(size: 22))
                                    .foregroundColor(Color(red: 0x9b / 255.0, green: 0x8b / 255.0, blue: 0xe0 / 255.0))
                            }
                        }
                        .buttonStyle(.plain)
                        Spacer()
                    }
                    .padding(.top, 12)

                    VStack(spacing: 14) {
                        LabeledField(label: "DISPLAY NAME", text: $displayName, isSecure: false)

                        LabeledUsernameField(label: "USERNAME", text: $username)

                        LabeledField(label: "EMAIL", text: $email, isSecure: false)

                        LabeledField(label: "PASSWORD", text: $password, isSecure: true)
                    }
                    .padding(.top, 8)

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 13))
                            .foregroundColor(.red)
                    }

                    Button {
                        Task {
                            await handleSignUp()
                        }
                    } label: {
                        ZStack {
                            Text("Create account")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                                .opacity(isLoading ? 0 : 1)

                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(accentColor)
                        .cornerRadius(12)
                    }
                    .disabled(isLoading)
                    .padding(.top, 20)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private func handleSignUp() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        do {
            try await authState.signUp(
                email: email,
                password: password,
                username: username,
                displayName: displayName
            )
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

private struct LabeledUsernameField: View {
    let label: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Color.gray)

            HStack(spacing: 4) {
                Text("@")
                    .font(.system(size: 13))
                    .foregroundColor(Color.gray)

                TextField("", text: $text)
                    .font(.system(size: 13))
            }
            .padding(11)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 9)
                    .stroke(Color(red: 0xdd / 255.0, green: 0xd8 / 255.0, blue: 0xff / 255.0), lineWidth: 0.5)
            )
            .cornerRadius(9)
        }
    }
}

#Preview {
    SignUpView()
}

