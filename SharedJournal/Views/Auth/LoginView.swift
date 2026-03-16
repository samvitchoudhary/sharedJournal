//
//  LoginView.swift
//  SharedJournal
//

import SwiftUI

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject var authState: AuthState

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
                        Text("Welcome back")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(Color(red: 0x1a / 255.0, green: 0x1a / 255.0, blue: 0x2e / 255.0))

                        Text("Good to see you again")
                            .font(.system(size: 13))
                            .foregroundColor(Color(red: 0x88 / 255.0, green: 0x88 / 255.0, blue: 0x88 / 255.0))
                    }
                    .padding(.top, 8)

                    VStack(spacing: 14) {
                        LabeledField(label: "EMAIL", text: $email, isSecure: false)
                        LabeledField(label: "PASSWORD", text: $password, isSecure: true)
                    }
                    .padding(.top, 8)

                    HStack {
                        Spacer()
                        Button {
                            // Forgot password action
                        } label: {
                            Text("Forgot password?")
                                .font(.system(size: 11))
                                .foregroundColor(accentColor)
                        }
                    }

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 13))
                            .foregroundColor(.red)
                    }

                    Button {
                        Task {
                            await handleLogin()
                        }
                    } label: {
                        ZStack {
                            Text("Log in")
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
                        .cornerRadius(10)
                    }
                    .disabled(isLoading)
                    .padding(.top, 16)

                    // Divider with "or"
                    HStack {
                        Rectangle()
                            .fill(Color(red: 0xdd / 255.0, green: 0xd8 / 255.0, blue: 0xff / 255.0))
                            .frame(height: 0.5)

                        Text("or")
                            .font(.system(size: 10))
                            .foregroundColor(Color.gray)

                        Rectangle()
                            .fill(Color(red: 0xdd / 255.0, green: 0xd8 / 255.0, blue: 0xff / 255.0))
                            .frame(height: 0.5)
                    }
                    .padding(.vertical, 16)

                    Button {
                        // Sign in with Apple action
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "apple.logo")
                                .foregroundColor(.white)
                            Text("Sign in with Apple")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(Color.black)
                        .cornerRadius(10)
                    }
                    .buttonStyle(.plain)
                    .padding(.bottom, 24)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private func handleLogin() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        do {
            try await authState.signIn(email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

#Preview {
    LoginView()
}

