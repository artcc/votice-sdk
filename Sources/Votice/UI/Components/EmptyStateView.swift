//
//  EmptyStateView.swift
//  Votice
//
//  Created by Arturo Carretero Calvo on 29/6/25.
//  Copyright © 2025 ArtCC. All rights reserved.
//

import SwiftUI

struct EmptyStateView: View {
    // MARK: - Properties

    @Environment(\.voticeTheme) private var theme

    let title: String
    let message: String

    // MARK: - View

    var body: some View {
        VStack {
            Spacer()
            contentView
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Private

private extension EmptyStateView {
    var contentView: some View {
        VStack(spacing: theme.spacing.lg) {
            Image(systemName: "lightbulb")
                .font(.system(size: 40))
                .foregroundColor(theme.colors.primary)
                .frame(width: 88, height: 88)
                .background(Circle().fill(theme.colors.primary.opacity(0.08)))
            contentTextView
        }
        .padding(theme.spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: theme.cornerRadius.lg)
                .fill(theme.colors.surface)
                .shadow(color: .black.opacity(0.04), radius: 3, x: 0, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.cornerRadius.lg)
                .stroke(theme.colors.secondary.opacity(0.1), lineWidth: 1)
        )
        .padding(.horizontal, theme.spacing.md)
    }

    var contentTextView: some View {
        VStack(spacing: theme.spacing.md) {
            Text(title)
                .font(theme.typography.title3)
                .fontWeight(.medium)
                .foregroundColor(theme.colors.onBackground)
                .multilineTextAlignment(.center)
            Text(message)
                .font(theme.typography.body)
                .foregroundColor(theme.colors.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            HStack {
                Image(systemName: "arrow.up.circle.fill")
                    .foregroundColor(theme.colors.primary)
                Text(TextManager.shared.texts.tapPlusToGetStarted)
                    .font(theme.typography.caption)
                    .foregroundColor(theme.colors.primary)
            }
            .padding(.top, theme.spacing.sm)
        }
    }
}
