//
//  SuggestionDetailView+Comments.swift
//  Votice
//
//  Created by Arturo Carretero Calvo on 12/10/25.
//  Copyright © 2025 ArtCC. All rights reserved.
//

import SwiftUI

// MARK: - Create comment

extension SuggestionDetailView {
    var addCommentSheet: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
#if os(iOS)
            if !viewModel.liquidGlassEnabled {
                headerCommentSheet
            }
#elseif os(macOS)
            headerCommentSheet
#endif
            contentCommentSheet
        }
        .background(theme.colors.background)
        .onAppear {
            isCommentFocused = true
        }
#if os(iOS)
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(viewModel.liquidGlassEnabled ? .hidden : .automatic, for: .navigationBar)
        .toolbar {
            if viewModel.liquidGlassEnabled {
                headerCommentGlassView
            }
        }
#endif
    }

    var headerCommentSheet: some View {
        ZStack {
            HStack {
                commentCloseButton
                Spacer()
                commentSubmitButton
            }
            HStack(alignment: .center) {
                Spacer()
                commentTitle
                Spacer()
            }
        }
        .padding(theme.spacing.md)
        .background(
            theme.colors.background
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }

#if os(iOS)
    var headerCommentGlassView: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarLeading) {
                commentCloseButton
            }
            ToolbarItem(placement: .principal) {
                commentTitle
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                commentSubmitButton
            }
        }
    }
#endif

    var commentCloseButton: some View {
        Button {
            showingAddComment = false

            viewModel.resetCommentForm()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(theme.colors.secondary)
                .padding(8)
                .background(
                    Circle()
                        .fill(viewModel.liquidGlassEnabled ? .clear : theme.colors.secondary.opacity(0.1))
                )
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    var commentTitle: some View {
        Text(TextManager.shared.texts.newComment)
            .font(theme.typography.title3)
            .fontWeight(.regular)
            .foregroundColor(theme.colors.onBackground)
    }

    var commentSubmitButton: some View {
        Button {
            Task {
                await viewModel.submitComment(for: currentSuggestion.id) {
                    showingAddComment = false
                }
            }
        } label: {
            Image(systemName: "paperplane.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(commentSubmitButtonForegroundColor)
                .padding(8)
                .background(
                    Circle()
                        .fill(
                            viewModel.liquidGlassEnabled ?
                                .clear :
                                viewModel.isCommentFormValid && !viewModel.isSubmittingComment
                            ? theme.colors.primary
                            : theme.colors.secondary.opacity(0.1)
                        )
                )
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(Rectangle())
        }
        .disabled(!viewModel.isCommentFormValid || viewModel.isSubmittingComment)
        .buttonStyle(.plain)
    }

    var commentSubmitButtonForegroundColor: Color {
        if viewModel.liquidGlassEnabled {
            if viewModel.isCommentFormValid && !viewModel.isSubmittingComment {
                return theme.colors.primary
            } else {
                return theme.colors.secondary
            }
        } else {
            if viewModel.isCommentFormValid && !viewModel.isSubmittingComment {
                return .white
            } else {
                return theme.colors.secondary
            }
        }
    }

    var contentCommentSheet: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    Text(TextManager.shared.texts.yourComment)
                        .font(theme.typography.headline)
                        .foregroundColor(theme.colors.onBackground)
                    TextField(
                        TextManager.shared.texts.shareYourThoughts,
                        text: $viewModel.newComment,
                        axis: .vertical
                    )
                    .textFieldStyle(VoticeTextFieldStyle())
                    .lineLimit(3...8)
                    .focused($isCommentFocused)
                }
                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    Text(TextManager.shared.texts.yourNameOptional)
                        .font(theme.typography.headline)
                        .foregroundColor(theme.colors.onBackground)
                    TextField(TextManager.shared.texts.enterYourName, text: $viewModel.commentNickname)
                        .textFieldStyle(VoticeTextFieldStyle())
                }
                Spacer()
            }
            .padding(theme.spacing.md)
        }
        .scrollBounceBehavior(.basedOnSize)
        .scrollDismissesKeyboard(.immediately)
    }
}
