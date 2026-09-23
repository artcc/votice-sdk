//
//  SuggestionDetailView.swift
//  Votice
//
//  Created by Arturo Carretero Calvo on 28/6/25.
//  Copyright © 2025 ArtCC. All rights reserved.
//

import SwiftUI

struct SuggestionDetailView: View {
    // MARK: - Properties

    @Environment(\.dismiss) var dismiss
    @Environment(\.voticeTheme) var theme

    @StateObject var viewModel = SuggestionDetailViewModel()

    @State var showingAddComment = false

    @FocusState var isCommentFocused: Bool

    var currentSuggestion: SuggestionEntity {
        viewModel.suggestionEntity ?? suggestion
    }

    let suggestion: SuggestionEntity
    let onSuggestionUpdated: (SuggestionEntity) -> Void
    let onReload: () -> Void

    // MARK: - View

    var body: some View {
#if os(tvOS)
        tvOSView
#else
        standardView
#endif
    }
}

// MARK: - Private
// MARK: - Standard Platforms (iOS, iPadOS, macOS)

private extension SuggestionDetailView {
    var standardView: some View {
        ZStack {
            LinearGradient(
                colors: [
                    theme.colors.background,
                    theme.colors.background.opacity(0.95)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            VStack(spacing: 0) {
#if os(iOS)
                if !viewModel.liquidGlassEnabled {
                    headerView
                }
#elseif os(macOS)
                headerView
#endif
                mainContent
            }
        }
#if os(iOS)
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(viewModel.liquidGlassEnabled ? .hidden : .automatic, for: .navigationBar)
        .toolbar {
            if viewModel.liquidGlassEnabled {
                headerGlassView
            }
        }
#endif
        .task {
            await viewModel.loadInitialData(for: currentSuggestion)
        }
        .onDisappear {
            if viewModel.reload, let suggestionEntity = viewModel.suggestionEntity {
                onSuggestionUpdated(suggestionEntity)
            }
        }
        .sheet(isPresented: $showingAddComment) {
            NavigationStack {
                addCommentSheet
            }
        }
        .voticeAlert(
            isPresented: $viewModel.isShowingAlert,
            alert: viewModel.currentAlert ?? VoticeAlertEntity.error(message: TextManager.shared.texts.genericError)
        )
    }

    var headerView: some View {
        ZStack {
            HStack {
                closeButton
                Spacer()
                HStack(spacing: theme.spacing.sm) {
                    if currentSuggestion.deviceId == DeviceManager.shared.deviceId {
                        deleteButton
                    }
                }
            }
            HStack {
                Spacer()
                title
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
    var headerGlassView: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarLeading) {
                closeButton
            }
            ToolbarItem(placement: .principal) {
                title
            }
            if currentSuggestion.deviceId == DeviceManager.shared.deviceId {
                ToolbarItem(placement: .navigationBarTrailing) {
                    deleteButton
                }
            }
        }
    }
#endif

    var closeButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(theme.colors.secondary)
                .padding(8)
                .background(
                    Circle()
                        .fill(viewModel.liquidGlassEnabled ? .clear : theme.colors.secondary.opacity(0.1))
                )
        }
        .buttonStyle(.plain)
    }

    var title: some View {
        Text(
            currentSuggestion.issue ?? false ?
            TextManager.shared.texts.issueTitle :
                TextManager.shared.texts.suggestionTitle
        )
        .font(theme.typography.title3)
        .fontWeight(.regular)
        .foregroundColor(theme.colors.onBackground)
    }

    var deleteButton: some View {
        Button(role: .destructive) {
            HapticManager.shared.warning()

            viewModel.showDeleteSuggestionConfirmation(for: currentSuggestion) {
                HapticManager.shared.heavyImpact()

                onReload()

                dismiss()
            }
        } label: {
            ZStack {
                Circle()
                    .fill(viewModel.liquidGlassEnabled ? .clear : theme.colors.error.opacity(0.1))
                    .frame(width: 32, height: 32)
                Image(systemName: "trash.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(theme.colors.error)
            }
        }
        .buttonStyle(.plain)
    }

    var mainContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: theme.spacing.lg) {
                suggestionHeaderCard
                if let issue = currentSuggestion.issue,
                   let urlImage = currentSuggestion.urlImage,
                   issue,
                   !urlImage.isEmpty {
                    issueImageCard
                }
                votingAndStatsCard
                if ConfigurationManager.shared.commentIsEnabled {
                    commentsSection
                }
                Spacer(minLength: theme.spacing.xl)
            }
            .padding(theme.spacing.md)
        }
        .scrollBounceBehavior(.basedOnSize)
        .scrollDismissesKeyboard(.immediately)
    }

    var suggestionHeaderCard: some View {
        VStack(spacing: theme.spacing.xs) {
            HStack {
                Spacer()
                StatusBadge(
                    status: currentSuggestion.status ?? .pending,
                    progress: suggestion.progress,
                    useLiquidGlass: viewModel.liquidGlassEnabled
                )
                .padding(.top, theme.spacing.sm)
                .padding(.trailing, theme.spacing.sm)
            }
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                VStack(spacing: theme.spacing.sm) {
                    HStack(spacing: 5) {
                        if let issue = suggestion.issue, issue {
                            Image(systemName: "ladybug.fill")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(theme.colors.pending)
                        }
                        Text(currentSuggestion.displayText)
                            .font(theme.typography.headline)
                            .foregroundColor(theme.colors.onSurface)
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                    .padding(.top, theme.spacing.md)
                    .padding(.horizontal, theme.spacing.md)
                    if let description = currentSuggestion.description, description != currentSuggestion.title {
                        HStack {
                            Text(description)
                                .font(theme.typography.callout)
                                .foregroundColor(theme.colors.onSurface.opacity(0.7))
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                        .padding(.horizontal, theme.spacing.md)
                        .padding(.bottom, theme.spacing.md)
                    }
                }
                authorInfoSection
            }
        }
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

    var authorInfoSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(spacing: 6) {
                Image(systemName: currentSuggestion.nickname != nil ? "person.circle.fill" : "person.circle")
                    .foregroundColor(theme.colors.secondary.opacity(0.7))
                    .font(.subheadline)
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
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.subheadline)
                        .foregroundColor(theme.colors.secondary.opacity(0.7))
                    Text(date)
                        .font(theme.typography.subheadline)
                        .foregroundColor(theme.colors.secondary.opacity(0.7))
                }
            }
        }
        .padding(.horizontal, theme.spacing.md)
        .padding(.bottom, theme.spacing.md)
    }

    var votingAndStatsCard: some View {
        HStack {
            VotingButtons(
                upvotes: max(0, currentSuggestion.voteCount ?? 0),
                downvotes: 0,
                currentVote: viewModel.currentVote,
                onVote: { voteType in
                    Task {
                        await viewModel.vote(on: currentSuggestion.id, type: voteType)
                    }
                }
            )
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: currentSuggestion.voteCount ?? 0 > 0 ? "hand.thumbsup.fill" : "hand.thumbsup")
                        .font(.caption)
                        .foregroundColor(theme.colors.primary)
                    Text("\(currentSuggestion.voteCount ?? 0) \(TextManager.shared.texts.votes)")
                        .font(theme.typography.callout)
                        .foregroundColor(theme.colors.secondary)
                }
                if ConfigurationManager.shared.commentIsEnabled {
                    HStack(spacing: 4) {
                        Image(systemName: viewModel.comments.count > 0 ? "bubble.left.fill" : "bubble.left")
                            .font(.caption)
                            .foregroundColor(theme.colors.secondary.opacity(0.75))
                        Text("\(viewModel.comments.count) \(TextManager.shared.texts.comments)")
                            .font(theme.typography.callout)
                            .foregroundColor(theme.colors.secondary)
                    }
                }
            }
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

    var commentsSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            HStack {
                Text(TextManager.shared.texts.commentsSection)
                    .font(theme.typography.title3)
                    .fontWeight(.regular)
                    .foregroundColor(theme.colors.onBackground)
                Spacer()
                Button {
                    showingAddComment = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                        Text(TextManager.shared.texts.addComment)
                    }
                    .font(theme.typography.caption)
                    .foregroundColor(theme.colors.primary)
                }
                .buttonStyle(.plain)
            }
            if viewModel.isLoadingComments && viewModel.comments.isEmpty {
                commentsLoadingView
            } else if viewModel.comments.isEmpty && !viewModel.isLoadingComments {
                commentsEmptyState
            } else {
                commentsListView
            }
        }
    }

    var commentsLoadingView: some View {
        VStack(spacing: theme.spacing.md) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: theme.colors.primary))
            Text(TextManager.shared.texts.loadingComments)
                .font(theme.typography.caption)
                .foregroundColor(theme.colors.secondary)
        }
        .padding(theme.spacing.md)
        .frame(maxWidth: .infinity)
    }

    var commentsEmptyState: some View {
        VStack(spacing: theme.spacing.sm) {
            Image(systemName: "bubble.left")
                .font(.system(size: 32))
                .foregroundColor(theme.colors.secondary.opacity(0.5))
            Text(TextManager.shared.texts.noComments)
                .font(theme.typography.body)
                .foregroundColor(theme.colors.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(theme.spacing.lg)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: theme.cornerRadius.lg)
                .fill(theme.colors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: theme.cornerRadius.lg)
                        .stroke(theme.colors.secondary.opacity(0.1), lineWidth: 1)
                )
        )
    }

    var commentsListView: some View {
        LazyVStack(alignment: .leading, spacing: theme.spacing.md) {
            ForEach(Array(viewModel.comments.enumerated()), id: \.element.id) { index, comment in
                CommentCard(
                    comment: comment,
                    currentDeviceId: DeviceManager.shared.deviceId,
                    onDeleteConfirmation: {
                        viewModel.showDeleteCommentConfirmation(for: comment)
                    }
                )
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
                LoadingPaginationView()
            }
        }
    }

    var issueImageCard: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack {
                Image(systemName: "photo")
                    .foregroundColor(theme.colors.primary)
                    .font(.headline)
                Text(TextManager.shared.texts.titleIssueImage)
                    .font(theme.typography.headline)
                    .foregroundColor(theme.colors.onSurface)
                Spacer()
            }
            .padding(.top, theme.spacing.md)
            .padding(.horizontal, theme.spacing.md)
            AsyncImage(url: URL(string: currentSuggestion.urlImage ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: 600)
                        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.md))
                case .empty:
                    issueImagePlaceholder(isLoading: true)
                case .failure:
                    issueImagePlaceholder(isLoading: false)
                @unknown default:
                    issueImagePlaceholder(isLoading: false)
                }
            }
            .padding(.horizontal, theme.spacing.md)
            .padding(.bottom, theme.spacing.md)
        }
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

    func issueImagePlaceholder(isLoading: Bool) -> some View {
        RoundedRectangle(cornerRadius: theme.cornerRadius.md)
            .fill(theme.colors.secondary.opacity(0.08))
            .frame(height: 250)
            .overlay {
                VStack(spacing: theme.spacing.sm) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: theme.colors.primary))
                    } else {
                        Image(systemName: "photo")
                            .font(.title2)
                            .foregroundColor(theme.colors.secondary)
                    }
                    Text(isLoading ? TextManager.shared.texts.loadingImage : TextManager.shared.texts.genericError)
                        .font(theme.typography.caption)
                        .foregroundColor(theme.colors.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(theme.spacing.md)
            }
    }
}
