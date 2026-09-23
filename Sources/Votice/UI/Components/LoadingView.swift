//
//  LoadingView.swift
//  Votice
//
//  Created by Arturo Carretero Calvo on 29/6/25.
//  Copyright © 2025 ArtCC. All rights reserved.
//

import SwiftUI

struct LoadingView: View {
    // MARK: - Properties

    @Environment(\.voticeTheme) private var theme

    let message: String

    // MARK: - View

    var body: some View {
        VStack(spacing: theme.spacing.sm) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: theme.colors.primary))
            Text(message)
                .font(theme.typography.subheadline)
                .foregroundColor(theme.colors.onBackground)
                .multilineTextAlignment(.center)
        }
        .padding(theme.spacing.lg)
    }
}
