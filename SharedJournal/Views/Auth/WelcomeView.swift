//
//  WelcomeView.swift
//  SharedJournal
//

import SwiftUI

struct WelcomeView: View {
    private let backgroundColor = Color(red: 0x5b / 255.0, green: 0x3f / 255.0, blue: 0xf8 / 255.0)

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor
                    .ignoresSafeArea()

                VStack {
                    // Logo and titles
                    VStack(spacing: 16) {
                        LogoView()

                        VStack(spacing: 6) {
                            Text("SharedJournal")
                                .font(.system(size: 28, weight: .medium))
                                .kerning(-0.02 * 28)
                                .foregroundColor(.white)

                            Text("Keep memories with the people who matter most")
                                .font(.system(size: 13))
                                .foregroundColor(Color.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                                .padding(.bottom, 40)
                        }
                    }

                    Spacer()

                    // Buttons and terms
                    VStack(spacing: 8) {
                        NavigationLink {
                            SignUpView()
                        } label: {
                            Text("Create an account")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(backgroundColor)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 11)
                                .background(Color.white)
                                .cornerRadius(12)
                        }

                        NavigationLink {
                            LoginView()
                        } label: {
                            Text("Log in")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 11)
                                .background(Color.white.opacity(0.15))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 0.5)
                                )
                                .cornerRadius(12)
                        }

                        Button {
                            // Sign in with Apple action will be implemented later
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "apple.logo")
                                    .foregroundColor(.white)
                                Text("Sign in with Apple")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 11)
                            .background(Color.black)
                            .cornerRadius(12)
                        }
                        .buttonStyle(.plain)

                        Text("By continuing you agree to our Terms & Privacy Policy")
                            .font(.system(size: 9))
                            .foregroundColor(Color.white.opacity(0.4))
                            .multilineTextAlignment(.center)
                            .padding(.top, 8)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
            }
        }
    }
}

private struct LogoView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.2))
                .frame(width: 60, height: 60)

            Circle()
                .fill(Color.white)
                .frame(width: 32, height: 32)
        }
    }
}

#Preview {
    WelcomeView()
}

