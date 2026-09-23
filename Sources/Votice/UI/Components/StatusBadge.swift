//
//  StatusBadge.swift
//  Votice
//
//  Created by Arturo Carretero Calvo on 29/6/25.
//  Copyright © 2025 ArtCC. All rights reserved.
//

import SwiftUI

struct StatusBadge: View {
    // MARK: - Properties

    @Environment(\.voticeTheme) private var theme

    let status: SuggestionStatusEntity
    let progress: Int?
    let useLiquidGlass: Bool

    // MARK: - View

    var body: some View {
        if status == .inProgress, let progress {
            inProgressTagView(with: progress)
        } else {
            defaultTagView
        }
    }
}

// MARK: - Private

private extension StatusBadge {
    // MARK: - Properties

    var statusColor: Color {
        switch status {
        case .accepted:
            return theme.colors.accepted
        case .blocked:
            return theme.colors.rejected
        case .completed:
            return theme.colors.completed
        case .inProgress:
            return theme.colors.inProgress
        case .pending:
            return theme.colors.pending
        case .rejected:
            return theme.colors.rejected
        }
    }

    var statusText: String {
        let texts = TextManager.shared.texts

        switch status {
        case .accepted:
            return texts.accepted
        case .blocked:
            return texts.blocked
        case .completed:
            return texts.completed
        case .inProgress:
            if let progress {
                return "\(texts.inProgress) \(progress)%"
            }

            return texts.inProgress
        case .pending:
            return texts.pending
        case .rejected:
            return texts.rejected
        }
    }

    var defaultTagView: some View {
        Text(statusText)
            .font(theme.typography.caption)
            .fontWeight(.medium)
            .foregroundColor(statusColor)
            .padding(.vertical, theme.spacing.xs)
            .padding(.horizontal, theme.spacing.sm)
            .adaptiveGlassBackground(
                useLiquidGlass: useLiquidGlass,
                cornerRadius: theme.cornerRadius.sm,
                fillColor: statusColor.opacity(0.14)
            )
    }

    // MARK: - Functions

    func inProgressTagView(with progress: Int) -> some View {
        let progressValue = min(max(progress, 0), 100)

        return Text(statusText)
            .font(theme.typography.caption)
            .fontWeight(.medium)
            .foregroundColor(statusColor)
            .padding(.vertical, theme.spacing.xs)
            .padding(.horizontal, theme.spacing.sm)
            .background {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: theme.cornerRadius.sm)
                            .fill(statusColor.opacity(0.14))
                        RoundedRectangle(cornerRadius: theme.cornerRadius.sm)
                            .fill(statusColor.opacity(0.28))
                            .frame(width: geometry.size.width * CGFloat(progressValue) / 100.0)
                    }
                }
            }
    }
}
