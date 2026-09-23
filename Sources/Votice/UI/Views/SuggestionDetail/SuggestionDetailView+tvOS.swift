//
//  SuggestionDetailView+tvOS.swift
//  Votice
//
//  Created by Arturo Carretero Calvo on 28/10/25.
//  Copyright © 2025 ArtCC. All rights reserved.
//

import SwiftUI

// MARK: - tvOS

#if os(tvOS)
extension SuggestionDetailView {
    // MARK: - Properties

    var tvOSView: some View {
        ScrollView {
            Color.clear.focusable(true)
            VStack(alignment: .leading, spacing: theme.spacing.lg) {
                VStack(alignment: .leading, spacing: theme.spacing.lg) {
                    tvOSHeaderSection
                    tvOSStatsCard
                }
                if let issue = currentSuggestion.issue,
                   let urlImage = currentSuggestion.urlImage,
                   issue && !urlImage.isEmpty {
                    tvOSIssueImageCard
                }
                if ConfigurationManager.shared.commentIsEnabled {
                    tvOSCommentsSection
                }
            }
            .padding(.horizontal, 20)
            Color.clear.focusable(true)
        }
        .frame(width: ConfigurationManager.shared.width, height: ConfigurationManager.shared.height)
        .background(
            LinearGradient(
                colors: [
                    theme.colors.background,
                    theme.colors.background.opacity(0.95)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .task {
            await viewModel.loadInitialData(for: currentSuggestion)
        }
    }

    var tvOSHeaderSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(alignment: .top, spacing: 8) {
                if let issue = currentSuggestion.issue, issue {
                    Image(systemName: "ladybug.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(theme.colors.pending)
                }
                Text(currentSuggestion.displayText)
                    .font(theme.typography.title3)
                    .foregroundColor(theme.colors.onSurface)
                    .multilineTextAlignment(.leading)
                Spacer()
                StatusBadge(
                    status: currentSuggestion.status ?? .pending,
                    progress: currentSuggestion.progress,
                    useLiquidGlass: false)

            }
            if let description = currentSuggestion.description, description != currentSuggestion.title {
                Text(description)
                    .font(theme.typography.body)
                    .foregroundColor(theme.colors.onSurface.opacity(0.7))
                    .multilineTextAlignment(.leading)
                    .padding(.top, theme.spacing.sm)
            }
            authorInfoView
        }
        .padding(theme.spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: theme.cornerRadius.xl)
                .fill(theme.colors.surface)
                .shadow(color: .black.opacity(0.04), radius: 3, x: 0, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.cornerRadius.xl)
                .stroke(theme.colors.secondary.opacity(0.1), lineWidth: 1)
        )
    }

    var authorInfoView: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            HStack(spacing: 10) {
                Image(systemName: currentSuggestion.nickname != nil ? "person.circle.fill" : "person.circle")
                    .foregroundColor(theme.colors.secondary.opacity(0.7))
                    .font(.system(size: 18))
                if let nickname = currentSuggestion.nickname {
                    Text("\(TextManager.shared.texts.suggestedBy) \(nickname)")
                        .font(theme.typography.subheadline)
                        .foregroundColor(theme.colors.secondary.opacity(0.7))
                } else {
                    Text(TextManager.shared.texts.suggestedAnonymously)
                        .font(theme.typography.subheadline)
                        .foregroundColor(theme.colors.secondary.opacity(0.7))
                }
            }
            if let createdAt = currentSuggestion.createdAt, let date = Date.formatFromISOString(createdAt) {
                HStack(spacing: 8) {
                    Image(systemName: "clock")
                        .font(.system(size: 18))
                        .foregroundColor(theme.colors.secondary.opacity(0.7))
                    Text(date)
                        .font(theme.typography.subheadline)
                        .foregroundColor(theme.colors.secondary.opacity(0.7))
                }
            }
        }
    }

    var tvOSStatsCard: some View {
        HStack(spacing: theme.spacing.lg) {
            HStack(spacing: theme.spacing.sm) {
                Image(systemName: "hand.thumbsup.fill")
                    .font(.system(size: 24))
                    .foregroundColor(theme.colors.primary)
                Text("\(max(0, currentSuggestion.voteCount ?? 0))")
                    .font(theme.typography.title3)
                    .foregroundColor(theme.colors.onSurface)
                Text(TextManager.shared.texts.votes)
                    .font(theme.typography.subheadline)
                    .foregroundColor(theme.colors.secondary)
            }
            if ConfigurationManager.shared.commentIsEnabled {
                Divider()
                HStack(spacing: theme.spacing.sm) {
                    Image(systemName: "bubble.left.fill")
                        .font(.system(size: 24))
                        .foregroundColor(theme.colors.secondary.opacity(0.75))
                    Text("\(viewModel.comments.count)")
                        .font(theme.typography.title3)
                        .foregroundColor(theme.colors.onSurface)
                    Text(TextManager.shared.texts.comments)
                        .font(theme.typography.subheadline)
                        .foregroundColor(theme.colors.secondary)
                }
            }
            Spacer()
        }
        .padding(theme.spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: theme.cornerRadius.xl)
                .fill(theme.colors.surface)
                .shadow(color: .black.opacity(0.04), radius: 3, x: 0, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.cornerRadius.xl)
                .stroke(theme.colors.secondary.opacity(0.1), lineWidth: 1)
        )
    }

    var tvOSIssueImageCard: some View {
        customContentCard {
            VStack(alignment: .leading, spacing: theme.spacing.lg) {
                HStack(spacing: theme.spacing.md) {
                    Image(systemName: "photo")
                        .foregroundColor(theme.colors.primary)
                        .font(.system(size: 22, weight: .semibold))
                    Text(TextManager.shared.texts.titleIssueImage)
                        .font(theme.typography.title3)
                        .foregroundColor(theme.colors.onSurface)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                if let urlString = currentSuggestion.urlImage, let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        case .empty:
                            HStack {
                                Spacer()
                                VStack(spacing: theme.spacing.md) {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: theme.colors.primary))
                                    Text(TextManager.shared.texts.loadingImage)
                                        .font(.system(size: 22))
                                        .foregroundColor(theme.colors.secondary)
                                }
                                Spacer()
                            }
                        case .failure:
                            tvOSImageErrorView
                        @unknown default:
                            tvOSImageErrorView
                        }
                    }
                    .frame(height: 350)
                }
            }
            .padding(theme.spacing.lg)
        }
    }

    var tvOSCommentsSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.lg) {
            HStack(spacing: theme.spacing.md) {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .foregroundColor(theme.colors.primary)
                    .font(.system(size: 22, weight: .semibold))
                Text(TextManager.shared.texts.commentsSection)
                    .font(theme.typography.title3)
                    .foregroundColor(theme.colors.onSurface)
                Spacer()
            }
            if viewModel.isLoadingComments && viewModel.comments.isEmpty {
                tvOSCommentsLoadingView
            } else if viewModel.comments.isEmpty && !viewModel.isLoadingComments {
                tvOSCommentsEmptyState
            } else {
                tvOSCommentsList
            }
        }
    }

    var tvOSCommentsLoadingView: some View {
        VStack(spacing: theme.spacing.lg) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: theme.colors.primary))
            Text(TextManager.shared.texts.loadingComments)
                .font(theme.typography.body)
                .foregroundColor(theme.colors.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, theme.spacing.md)
    }

    var tvOSCommentsEmptyState: some View {
        VStack(spacing: theme.spacing.xl) {
            Image(systemName: "bubble.left")
                .font(.system(size: 60))
                .foregroundColor(theme.colors.secondary.opacity(0.5))
            Text(TextManager.shared.texts.noComments)
                .font(theme.typography.title3)
                .foregroundColor(theme.colors.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(theme.spacing.md)
    }

    var tvOSCommentsList: some View {
        LazyVStack(spacing: theme.spacing.lg) {
            ForEach(Array(viewModel.comments.enumerated()), id: \.element.id) { index, comment in
                tvOSCommentCard(comment: comment)
                    .onAppear {
                        if index >= viewModel.comments.count - 3 &&
                            viewModel.hasMoreComments &&
                            !viewModel.isLoadingPaginationComments {
                            Task {
                                await viewModel.loadMoreComments(for: currentSuggestion.id)
                            }
                        }
                    }
            }
            if viewModel.isLoadingPaginationComments && viewModel.comments.count > 0 {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: theme.colors.primary))
                    .padding(40)
            }
        }
    }

    // MARK: - Functions

    func tvOSCommentCard(comment: CommentEntity) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            HStack {
                HStack(spacing: 10) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(theme.colors.secondary.opacity(0.7))
                    Text(comment.displayName)
                        .font(theme.typography.subheadline)
                        .foregroundColor(theme.colors.secondary.opacity(0.7))
                }
                Spacer()
                if let createdAt = comment.createdAt, let date = Date.formatFromISOString(createdAt) {
                    HStack(spacing: 8) {
                        Image(systemName: "clock")
                            .font(.system(size: 18))
                            .foregroundColor(theme.colors.secondary.opacity(0.6))
                        Text(date)
                            .font(theme.typography.subheadline)
                            .foregroundColor(theme.colors.secondary.opacity(0.6))
                    }
                }
            }
            Text(comment.text)
                .font(theme.typography.body)
                .foregroundColor(theme.colors.onSurface)
                .multilineTextAlignment(.leading)
        }
        .padding(theme.spacing.md)
        .background(
            RoundedRectangle(cornerRadius: theme.cornerRadius.lg)
                .fill(theme.colors.surface)
                .shadow(color: .black.opacity(0.04), radius: 3, x: 0, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.cornerRadius.lg)
                .stroke(theme.colors.secondary.opacity(0.1), lineWidth: 1)
        )
    }

    @ViewBuilder
    func customContentCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content().background(
            ZStack { theme.colors.surface }
                .compositingGroup()
                .mask(RoundedRectangle(cornerRadius: theme.cornerRadius.lg, style: .continuous))
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.cornerRadius.lg, style: .continuous)
                .stroke(theme.colors.secondary.opacity(0.1), lineWidth: 1)
        )
    }

    var tvOSImageErrorView: some View {
        VStack(spacing: theme.spacing.sm) {
            Image(systemName: "photo")
                .font(.system(size: 60))
                .foregroundColor(theme.colors.secondary)
            Text(TextManager.shared.texts.genericError)
                .font(theme.typography.subheadline)
                .foregroundColor(theme.colors.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
#endif
