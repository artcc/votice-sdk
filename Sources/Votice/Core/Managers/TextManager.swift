//
//  TextManager.swift
//  Votice
//
//  Created by Arturo Carretero Calvo on 30/6/25.
//  Copyright © 2025 ArtCC. All rights reserved.
//

import Foundation

// MARK: - VoticeTextsProtocol

/// Protocol that defines all the texts used in the Votice SDK UI.
/// Users can implement this protocol to provide custom translations.
public protocol VoticeTextsProtocol: Sendable {
    // MARK: - General

    var cancel: String { get }
    var error: String { get }
    var ok: String { get }
    var submit: String { get }
    var optional: String { get }
    var success: String { get }
    var warning: String { get }
    var info: String { get }
    var genericError: String { get }
    var anonymous: String { get }

    // MARK: - Suggestion List

    var loadingSuggestions: String { get }
    var noSuggestionsYet: String { get }
    var beFirstToSuggest: String { get }
    var noMatchingSuggestions: String { get }
    var noMatchingSuggestionsMessage: String { get }
    var noSuggestionsMessage: String { get }
    var featureRequests: String { get }
    var all: String { get }
    var activeTab: String { get }
    var completedTab: String { get }
    var pending: String { get }
    var accepted: String { get }
    var blocked: String { get }
    var inProgress: String { get }
    var completed: String { get }
    var rejected: String { get }
    var tapPlusToGetStarted: String { get }
    var loadingMore: String { get }

    // MARK: - Suggestion Detail

    var suggestionTitle: String { get }
    var issueTitle: String { get }
    var close: String { get }
    var deleteSuggestionTitle: String { get }
    var deleteSuggestionMessage: String { get }
    var delete: String { get }
    var suggestedBy: String { get }
    var suggestedAnonymously: String { get }
    var votes: String { get }
    var comments: String { get }
    var commentsSection: String { get }
    var loadingComments: String { get }
    var noComments: String { get }
    var addComment: String { get }
    var yourComment: String { get }
    var shareYourThoughts: String { get }
    var yourNameOptional: String { get }
    var enterYourName: String { get }
    var newComment: String { get }
    var post: String { get }
    var deleteCommentTitle: String { get }
    var deleteCommentMessage: String { get }
    var deleteCommentPrimary: String { get }

    // MARK: - Create Suggestion

    var newSuggestion: String { get }
    var shareYourIdea: String { get }
    var helpUsImprove: String { get }
    var title: String { get }
    var titlePlaceholder: String { get }
    var keepItShort: String { get }
    var descriptionOptional: String { get }
    var descriptionPlaceholder: String { get }
    var explainWhyUseful: String { get }
    var yourNameOptionalCreate: String { get }
    var enterYourNameCreate: String { get }
    var leaveEmptyAnonymous: String { get }

    // MARK: - Create Issue (optional feature)

    var reportIssue: String { get }
    var reportIssueSubtitle: String { get }
    var titleIssuePlaceholder: String { get }
    var descriptionIssuePlaceholder: String { get }
    var attachImage: String { get }
    var titleIssueImage: String { get }
    var loadingImage: String { get }
    var dragAndDropImage: String { get }
    var or: String { get }
}

// MARK: - DefaultVoticeTexts

/// Default English implementation of VoticeTextsProtocol
public struct DefaultVoticeTexts: VoticeTextsProtocol {
    public init() {}

    // MARK: - General

    public let cancel = "Cancel"
    public let error = "Error"
    public let ok = "Ok"
    public let submit = "Submit"
    public let optional = "Optional"
    public let success = "Success"
    public let warning = "Warning"
    public let info = "Info"
    public let genericError = "Something went wrong. Please try again."
    public let anonymous = "Anonymous"

    // MARK: - Suggestion List

    public let loadingSuggestions = "Loading suggestions..."
    public let noSuggestionsYet = "No suggestions yet."
    public let beFirstToSuggest = "Be the first to suggest something!"
    public let noMatchingSuggestions = "No matching suggestions"
    public let noMatchingSuggestionsMessage = "There are no suggestions for the selected status."
    public let noSuggestionsMessage = "Suggestions will appear here when available."
    public let featureRequests = "Feature Requests"
    public let all = "All"
    public let activeTab = "Active"
    public let completedTab = "Completed"
    public let pending = "Pending"
    public let accepted = "Accepted"
    public let blocked = "Blocked"
    public let inProgress = "In Progress"
    public let completed = "Completed"
    public let rejected = "Rejected"
    public let tapPlusToGetStarted = "Tap + to get started"
    public let loadingMore = "Loading more..."

    // MARK: - Suggestion Detail

    public let suggestionTitle = "Suggestion"
    public let issueTitle = "Issue"
    public let close = "Close"
    public let deleteSuggestionTitle = "Delete Suggestion"
    public let deleteSuggestionMessage = "Are you sure you want to delete this suggestion?"
    public let delete = "Delete"
    public let suggestedBy = "Suggested by"
    public let suggestedAnonymously = "Suggested anonymously"
    public let votes = "votes"
    public let comments = "comments"
    public let commentsSection = "Comments"
    public let loadingComments = "Loading comments..."
    public let noComments = "No comments yet. Be the first to comment!"
    public let addComment = "Add a comment"
    public let yourComment = "Your Comment"
    public let shareYourThoughts = "Share your thoughts..."
    public let yourNameOptional = "Your Name (Optional)"
    public let enterYourName = "Enter your name"
    public let newComment = "New Comment"
    public let post = "Post"
    public let deleteCommentTitle = "Delete Comment"
    public let deleteCommentMessage = "Are you sure you want to delete this comment?"
    public let deleteCommentPrimary = "Delete"

    // MARK: - Create Suggestion

    public let newSuggestion = "New Suggestion"
    public let shareYourIdea = "Share your idea"
    public let helpUsImprove = "Help us improve by suggesting new features or improvements."
    public let title = "Title (Min. 3 characters)"
    public let titlePlaceholder = "Enter a brief title for your suggestion"
    public let keepItShort = "Keep it short and descriptive"
    public let descriptionOptional = "Description (Optional)"
    public let descriptionPlaceholder = "Describe your suggestion in detail..."
    public let explainWhyUseful = "Explain why this feature would be useful"
    public let yourNameOptionalCreate = "Your Name (Optional)"
    public let enterYourNameCreate = "Enter your name"
    public let leaveEmptyAnonymous = "Leave empty to submit anonymously"

    // MARK: - Create Issue (optional feature)

    public let reportIssue = "Report Issue"
    public let reportIssueSubtitle = "Help us fix it by describing the issue you encountered."
    public let titleIssuePlaceholder = "Enter a brief title for the issue"
    public let descriptionIssuePlaceholder = "Describe the issue in detail..."
    public let attachImage = "Attach Image"
    public let titleIssueImage = "Issue Image"
    public let loadingImage = "Loading image..."
    public let dragAndDropImage = "Drag image here"
    public let or = "or"
}

// MARK: - TextManager

/// Centralized manager for handling texts in the Votice SDK
final class TextManager: @unchecked Sendable {
    // MARK: - Properties

    static let shared = TextManager()

    private var _texts: VoticeTextsProtocol
    private let lock = NSLock()

    // MARK: - Public properties

    var texts: VoticeTextsProtocol {
        lock.withLock { _texts }
    }

    // MARK: - Init

    private init() {
        _texts = DefaultVoticeTexts()
    }

    // MARK: - Public functions

    func setTexts(_ texts: VoticeTextsProtocol) {
        lock.withLock {
            _texts = texts

            LogManager.shared.devLog(.info, "TextManager: updated with custom texts")
        }
    }

    func resetToDefault() {
        lock.withLock {
            _texts = DefaultVoticeTexts()

            LogManager.shared.devLog(.info, "TextManager: reset to default texts")
        }
    }
}
