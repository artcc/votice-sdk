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
            HStack {
                Text(comment.displayName)
                    .font(theme.typography.subheadline)
                    .foregroundColor(theme.colors.secondary.opacity(0.7))
                Spacer()
                if let createdAt = comment.createdAt, let date = Date.formatFromISOString(createdAt) {
                    Text(date)
                        .font(theme.typography.subheadline)
                        .foregroundColor(theme.colors.secondary.opacity(0.7))
                }
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
