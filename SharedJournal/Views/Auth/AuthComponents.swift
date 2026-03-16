//
//  AuthComponents.swift
//  SharedJournal
//

import SwiftUI

struct LabeledField: View {
    let label: String
    @Binding var text: String
    let isSecure: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Color.gray)

            Group {
                if isSecure {
                    SecureField("", text: $text)
                } else {
                    TextField("", text: $text)
                }
            }
            .font(.system(size: 13))
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

