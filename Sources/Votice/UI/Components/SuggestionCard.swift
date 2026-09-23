//
//  SuggestionCard.swift
//  Votice
//
//  Created by Arturo Carretero Calvo on 28/6/25.
//  Copyright © 2025 ArtCC. All rights reserved.
//

import SwiftUI

struct SuggestionCard: View {
    // MARK: - Properties

    @Environment(\.voticeTheme) private var theme

    @State private var isPressed = false

    let suggestion: SuggestionEntity
    let currentVote: VoteType?
    let useLiquidGlass: Bool
    let onVote: (VoteType) -> Void
    let onTap: () -> Void

    // MARK: - View

    var body: some View {
        VStack(spacing: theme.spacing.xs) {
            HStack {
                Spacer()
                StatusBadge(
                    status: suggestion.status ?? .pending,
                    progress: suggestion.progress,
                    useLiquidGlass: useLiquidGlass
                )
                .padding(.top, theme.spacing.sm)
                .padding(.trailing, theme.spacing.sm)

            }
            HStack(alignment: .center, spacing: theme.spacing.md) {
                VStack(spacing: theme.spacing.sm) {
                    VotingButtons(
                        upvotes: max(0, suggestion.voteCount ?? 0),
                        downvotes: 0,
                        currentVote: currentVote,
                        onVote: onVote
                    )
                    if ConfigurationManager.shared.commentIsEnabled, suggestion.commentCount ?? 0 > 0 {
                        VStack(spacing: theme.spacing.xs) {
                            Image(systemName: "bubble.left.fill")
                                .font(.subheadline)
                                .foregroundColor(theme.colors.secondary)
                            Text("\(suggestion.commentCount ?? 0)")
                                .font(theme.typography.subheadline)
                                .foregroundColor(theme.colors.secondary)
                        }
                    }
                }
                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    titleView
                    metadataView
                }
                .padding(.trailing, theme.spacing.xs)
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(theme.colors.secondary.opacity(0.5))
                    .scaleEffect(isPressed ? 1.2 : 1.0)
            }
            .padding(.horizontal, theme.spacing.md)
            .padding(.bottom, theme.spacing.md)
        }
        .background(
            RoundedRectangle(cornerRadius: theme.cornerRadius.lg)
                .fill(theme.colors.surface)
                .shadow(
                    color: .black.opacity(isPressed ? 0.08 : 0.04),
                    radius: isPressed ? 6 : 3,
                    x: 0,
                    y: isPressed ? 3 : 1
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.cornerRadius.lg)
                .stroke(theme.colors.secondary.opacity(isPressed ? 0.2 : 0.1), lineWidth: 1)
        )
        .scaleEffect(isPressed ? 1.005 : 1.0)
        .onTapGesture {
            isPressed = true

            withAnimation(.easeInOut(duration: 0.15)) {
                isPressed = false
            }

            HapticManager.shared.lightImpact()

            onTap()
        }
    }
}

// MARK: - Private

private extension SuggestionCard {
    var metadataView: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            authorView
            createdAtView
        }
    }

    var titleView: some View {
        VStack(spacing: theme.spacing.xs) {
            HStack(spacing: 5) {
                if let issue = suggestion.issue, issue {
                    Image(systemName: "ladybug.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(theme.colors.pending)
                }
                Text(suggestion.displayText)
                    .font(theme.typography.headline)
                    .foregroundColor(theme.colors.onSurface)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
            }
            if let description = suggestion.description {
                HStack {
                    Text(description)
                        .font(theme.typography.callout)
                        .foregroundColor(theme.colors.onSurface.opacity(0.7))
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                }
            }
        }
    }

    var authorView: some View {
        HStack {
            HStack(spacing: theme.spacing.xs) {
                Image(systemName: suggestion.nickname != nil ? "person.circle.fill" : "person.circle")
                    .font(.subheadline)
                    .foregroundColor(theme.colors.secondary.opacity(0.7))
                if let nickname = suggestion.nickname {
                    Text("\(TextManager.shared.texts.suggestedBy) \(nickname)")
                        .font(theme.typography.subheadline)
                        .foregroundColor(theme.colors.secondary.opacity(0.7))
                } else {
                    Text(TextManager.shared.texts.suggestedAnonymously)
                        .font(theme.typography.subheadline)
                        .foregroundColor(theme.colors.secondary.opacity(0.7))
                }
            }
            Spacer()
        }
    }

    @ViewBuilder
    var createdAtView: some View {
        if let createdAt = suggestion.createdAt, let date = Date.formatFromISOString(createdAt) {
            HStack {
                HStack(spacing: theme.spacing.xs) {
                    Image(systemName: "clock")
                        .font(.subheadline)
                        .foregroundColor(theme.colors.secondary.opacity(0.7))
                    Text(date)
                        .font(theme.typography.subheadline)
                        .foregroundColor(theme.colors.secondary.opacity(0.7))
                }
                Spacer()
            }
        }
    }
}
