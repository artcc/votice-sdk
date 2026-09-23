//
//  SuggestionDetailViewModel.swift
//  Votice
//
//  Created by Arturo Carretero Calvo on 28/6/25.
//  Copyright © 2025 ArtCC. All rights reserved.
//

import Foundation

@MainActor
final class SuggestionDetailViewModel: ObservableObject {
    // MARK: - Properties

    @Published var comments: [CommentEntity] = []
    @Published var isLoadingComments = true
    @Published var isLoadingPaginationComments = false
    @Published var isSubmittingComment = false
    @Published var currentVote: VoteType?
    @Published var suggestionEntity: SuggestionEntity?
    @Published var reload = false
    @Published var hasMoreComments = true
    @Published var newComment = ""
    @Published var commentNickname = ""
    @Published var currentAlert: VoticeAlertEntity?
    @Published var isShowingAlert = false

    private var lastLoadedCreatedAt: String?

    private let pageSize = 20
    private let commentUseCase: CommentUseCaseProtocol
    private let suggestionUseCase: SuggestionUseCaseProtocol

    var isCommentFormValid: Bool {
        !newComment.isEmpty
    }
    var liquidGlassEnabled: Bool {
        ConfigurationManager.shared.shouldUseLiquidGlass
    }

    // MARK: - Init

    init(commentUseCase: CommentUseCaseProtocol = CommentUseCase(),
         suggestionUseCase: SuggestionUseCaseProtocol = SuggestionUseCase()) {
        self.commentUseCase = commentUseCase
        self.suggestionUseCase = suggestionUseCase
    }

    // MARK: - Functions

    func loadInitialData(for suggestion: SuggestionEntity) async {
        self.suggestionEntity = suggestion

        await loadComments(for: suggestion.id)
        await loadVoteStatus(for: suggestion.id)
    }

    func loadComments(for suggestionId: String) async {
        isLoadingComments = true

        do {
            let pagination = PaginationRequest(startAfter: nil, pageLimit: pageSize)
            let response = try await commentUseCase.fetchComments(suggestionId: suggestionId, pagination: pagination)

            comments = response.comments.sorted { $0.createdAt! < $1.createdAt! }

            lastLoadedCreatedAt = response.nextPageTokenString

            hasMoreComments = response.comments.count == pageSize
        } catch {
            LogManager.shared.devLog(
                .error, "SuggestionDetailViewModel: failed to load comments for suggestion \(suggestionId): \(error)"
            )

            showError()
        }

        isLoadingComments = false
    }

    func loadMoreComments(for suggestionId: String) async {
        guard !isLoadingPaginationComments && hasMoreComments else {
            return
        }

        isLoadingPaginationComments = true

        do {
            let startAfter = lastLoadedCreatedAt != nil ?
            StartAfterRequest(voteCount: nil, createdAt: lastLoadedCreatedAt!) :
            nil
            let pagination = PaginationRequest(startAfter: startAfter, pageLimit: pageSize)
            let response = try await commentUseCase.fetchComments(suggestionId: suggestionId, pagination: pagination)
            let newComments = response.comments.sorted { $0.createdAt! < $1.createdAt! }

            comments.append(contentsOf: newComments)

            lastLoadedCreatedAt = comments.last?.createdAt

            hasMoreComments = newComments.count == pageSize
        } catch {
            LogManager.shared.devLog(
                .error, "SuggestionDetailViewModel: failed to load more comments for \(suggestionId): \(error)"
            )

            showError()
        }

        isLoadingPaginationComments = false
    }

    func loadVoteStatus(for suggestionId: String) async {
        do {
            let voteStatus = try await suggestionUseCase.fetchVoteStatus(suggestionId: suggestionId)

            if voteStatus.hasVoted {
                currentVote = .upvote
            } else {
                currentVote = nil
            }
        } catch {
            LogManager.shared.devLog(.error, "SuggestionDetailViewModel: failed to load vote status: \(error)")
        }
    }

    func addComment(to suggestionId: String, text: String, nickname: String?) async {
        guard !isSubmittingComment else {
            return
        }

        isSubmittingComment = true

        defer {
            isSubmittingComment = false
        }

        do {
            let response = try await commentUseCase.createComment(
                suggestionId: suggestionId,
                text: text,
                nickname: nickname
            )

            comments.append(response.comment)

            suggestionEntity?.commentCount = (suggestionEntity?.commentCount ?? 0) + 1

            reload = true
        } catch {
            LogManager.shared.devLog(
                .error, "SuggestionDetailViewModel: failed to add comment to \(suggestionId): \(error)"
            )

            showError()
        }
    }

    func deleteComment(_ comment: CommentEntity) async {
        do {
            try await commentUseCase.deleteComment(commentId: comment.id)

            comments.removeAll { $0.id == comment.id }

            suggestionEntity?.commentCount = max((suggestionEntity?.commentCount ?? 1) - 1, 0)

            reload = true
        } catch {
            LogManager.shared.devLog(
                .error, "SuggestionDetailViewModel: failed to delete comment \(comment.id): \(error)"
            )

            showError()
        }
    }

    func vote(on suggestionId: String, type: VoteType) async {
        do {
            let hasCurrentVote = currentVote != nil
            let voteTypeToSend: VoteType = hasCurrentVote ? .downvote : .upvote
            let response = try await suggestionUseCase.vote(suggestionId: suggestionId, voteType: voteTypeToSend)

            currentVote = response.vote != nil ? type : nil

            if let updatedSuggestion = response.suggestion {
                self.suggestionEntity = updatedSuggestion
            }

            reload = true
        } catch {
            LogManager.shared.devLog(.error, "SuggestionDetailViewModel: failed to vote on \(suggestionId): \(error)")

            showError()
        }
    }

    func deleteSuggestion(_ suggestion: SuggestionEntity) async {
        do {
            _ = try await SuggestionUseCase().deleteSuggestion(suggestionId: suggestion.id)
        } catch {
            LogManager.shared.devLog(
                .error, "SuggestionDetailViewModel: failed to delete suggestion \(suggestion.id): \(error)"
            )

            showError()
        }
    }

    func submitComment(for suggestionId: String, onSuccess: @escaping () -> Void) async {
        await addComment(to: suggestionId, text: newComment, nickname: commentNickname.isEmpty ? nil : commentNickname)

        if !isShowingAlert {
            resetCommentForm()

            onSuccess()
        }
    }

    func resetCommentForm() {
        newComment = ""
        commentNickname = ""
    }

    func showDeleteCommentConfirmation(for comment: CommentEntity) {
        showAlert(VoticeAlertEntity.warning(
            title: TextManager.shared.texts.deleteCommentTitle,
            message: TextManager.shared.texts.deleteCommentMessage,
            okAction: {
                Task {
                    await self.deleteComment(comment)
                }
            }
        ))
    }

    func showDeleteSuggestionConfirmation(for suggestion: SuggestionEntity, onConfirm: @escaping () -> Void) {
        showAlert(VoticeAlertEntity.warning(
            title: TextManager.shared.texts.deleteSuggestionTitle,
            message: TextManager.shared.texts.deleteSuggestionMessage,
            okAction: {
                Task {
                    await self.deleteSuggestion(suggestion)

                    onConfirm()
                }
            }
        ))
    }
}

// MARK: - Private

private extension SuggestionDetailViewModel {
    func showAlert(_ alert: VoticeAlertEntity) {
        currentAlert = alert

        isShowingAlert = true
    }

    func showError() {
        showAlert(VoticeAlertEntity.error(message: TextManager.shared.texts.genericError))
    }
}
