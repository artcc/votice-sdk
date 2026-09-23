//
//  CommentCard.swift
//  Votice
//
//  Created by Arturo Carretero Calvo on 29/6/25.
//  Copyright © 2025 ArtCC. All rights reserved.
//

import SwiftUI

struct CommentCard: View {
    // MARK: - Properties

    @Environment(\.voticeTheme) private var theme

    let comment: CommentEntity
    let currentDeviceId: String
    let onDeleteConfirmation: (() -> Void)?

    // MARK: - Init

    init(comment: CommentEntity,
         currentDeviceId: String,
         onDeleteConfirmation: (() -> Void)? = nil) {
        self.comment = comment
        self.currentDeviceId = currentDeviceId
        self.onDeleteConfirmation = onDeleteConfirmation
    }

    // MARK: - View

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    Text(comment.displayName)
                        .font(theme.typography.subheadline)
                        .foregroundColor(theme.colors.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    if let createdAt = comment.createdAt, let date = Date.formatFromISOString(createdAt) {
                        Text(date)
                            .font(theme.typography.subheadline)
                            .foregroundColor(theme.colors.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                Spacer(minLength: theme.spacing.sm)
                if let commentDeviceId = comment.deviceId, commentDeviceId == currentDeviceId {
                    Button(role: .destructive) {
                        HapticManager.shared.warning()

                        onDeleteConfirmation?()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(theme.colors.error.opacity(0.1))
                                .frame(width: 28, height: 28)
                            Image(systemName: "trash.fill")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(theme.colors.error)
                        }
                        .frame(minWidth: 44, minHeight: 44)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            Text(comment.text)
                .font(theme.typography.body)
                .foregroundColor(theme.colors.onSurface)
        }
        .padding(theme.spacing.md)
        .background {
            RoundedRectangle(cornerRadius: theme.cornerRadius.md)
                .fill(theme.colors.surface)
        }
        .overlay {
            RoundedRectangle(cornerRadius: theme.cornerRadius.md)
                .stroke(theme.colors.secondary.opacity(0.1), lineWidth: 1)
        }
    }
}
