//
//  VoticeTextFieldStyle.swift
//  Votice
//
//  Created by Arturo Carretero Calvo on 29/6/25.
//  Copyright © 2025 ArtCC. All rights reserved.
//

import SwiftUI

struct VoticeTextFieldStyle: TextFieldStyle {
    // MARK: - Properties

    @Environment(\.voticeTheme) private var theme

    // MARK: - View

    // swiftlint:disable identifier_name
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .textFieldStyle(PlainTextFieldStyle())
            .padding(theme.spacing.md)
            .background(theme.colors.surface)
            .cornerRadius(theme.cornerRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: theme.cornerRadius.md)
                    .stroke(theme.colors.secondary.opacity(0.3), lineWidth: 1)
            )
    }
    // swiftlint:enable identifier_name
}
