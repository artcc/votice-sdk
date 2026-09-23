//
//  LoadingPaginationView.swift
//  Votice
//
//  Created by Arturo Carretero Calvo on 8/10/25.
//  Copyright © 2025 ArtCC. All rights reserved.
//

import SwiftUI

struct LoadingPaginationView: View {
    // MARK: - Properties

    @Environment(\.voticeTheme) private var theme

    // MARK: - View

    var body: some View {
        VStack(spacing: theme.spacing.sm) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: theme.colors.primary))
            Text(TextManager.shared.texts.loadingMore)
                .font(theme.typography.caption)
                .foregroundColor(theme.colors.secondary)
        }
        .padding(theme.spacing.md)
    }
}
