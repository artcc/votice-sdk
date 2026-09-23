//
//  Texts.swift
//  VoticeDemo
//
//  Created by Arturo Carretero Calvo on 9/7/25.
//  Copyright © 2025 ArtCC. All rights reserved.
//

import Foundation
import VoticeSDK

struct Texts: VoticeTextsProtocol {
    // MARK: - General

    let cancel = String(localized: "Cancel")
    let error = String(localized: "Error")
    let ok = String(localized: "OK")
    let submit = String(localized: "Submit")
    let optional = String(localized: "Optional")
    let success = String(localized: "Success")
    let warning = String(localized: "Warning")
    let info = String(localized: "Info")
    let genericError = String(localized: "Something went wrong. Please try again.")
    let anonymous = String(localized: "Anonymous")

    // MARK: - Suggestion List

    let loadingSuggestions = String(localized: "Loading suggestions...")
    let noSuggestionsYet = String(localized: "No suggestions yet.")
    let beFirstToSuggest = String(localized: "Be the first to suggest something!")
    let noMatchingSuggestions = String(localized: "No matching suggestions")
    let noMatchingSuggestionsMessage = String(localized: "There are no suggestions for the selected status.")
    let noSuggestionsMessage = String(localized: "Suggestions will appear here when available.")
    let featureRequests = String(localized: "Suggestions")
    let all = String(localized: "All")
    let activeTab = String(localized: "Active")
    let completedTab = String(localized: "Completed")
    let pending = String(localized: "Pending")
    let accepted = String(localized: "Accepted")
    let blocked = String(localized: "Blocked")
    let inProgress = String(localized: "In progress")
    let completed = String(localized: "Completed")
    let rejected = String(localized: "Rejected")
    let tapPlusToGetStarted = String(localized: "Tap + to get started")
    let loadingMore = String(localized: "Loading more...")

    // MARK: - Suggestion Detail

    let suggestionTitle = String(localized: "Suggestion")
    let issueTitle = String(localized: "Issue")
    let close = String(localized: "Close")
    let deleteSuggestionTitle = String(localized: "Delete suggestion")
    let deleteSuggestionMessage = String(localized: "Are you sure you want to delete this suggestion?")
    let delete = String(localized: "Delete")
    let suggestedBy = String(localized: "Suggested by")
    let suggestedAnonymously = String(localized: "Suggested anonymously")
    let votes = String(localized: "votes")
    let comments = String(localized: "comments")
    let commentsSection = String(localized: "Comments")
    let loadingComments = String(localized: "Loading comments...")
    let noComments = String(localized: "No comments yet. Be the first to comment!")
    let addComment = String(localized: "Add a comment")
    let yourComment = String(localized: "Your comment")
    let shareYourThoughts = String(localized: "Share your thoughts...")
    let yourNameOptional = String(localized: "Your name (optional)")
    let enterYourName = String(localized: "Enter your name")
    let newComment = String(localized: "New comment")
    let post = String(localized: "Post")
    let deleteCommentTitle = String(localized: "Delete comment")
    let deleteCommentMessage = String(localized: "Are you sure you want to delete this comment?")
    let deleteCommentPrimary = String(localized: "Delete")

    // MARK: - Create Suggestion

    let newSuggestion = String(localized: "New suggestion")
    let shareYourIdea = String(localized: "Share your idea")
    let helpUsImprove = String(localized: "Help us improve by suggesting new features or enhancements.")
    let title = String(localized: "Title (Minimum 3 characters)")
    let titlePlaceholder = String(localized: "Enter a short title for your suggestion")
    let keepItShort = String(localized: "Keep it short and descriptive")
    let descriptionOptional = String(localized: "Description (optional)")
    let descriptionPlaceholder = String(localized: "Describe your suggestion in detail...")
    let explainWhyUseful = String(localized: "Explain why this feature would be useful")
    let yourNameOptionalCreate = String(localized: "Your name (optional)")
    let enterYourNameCreate = String(localized: "Enter your name")
    let leaveEmptyAnonymous = String(localized: "Leave empty to send anonymously")

    // MARK: - Create Issue (optional feature)

    let reportIssue = String(localized: "Report an issue")
    let reportIssueSubtitle = String(localized: "Found a bug or problem?")
    let titleIssuePlaceholder = String(localized: "Enter a short title for the issue")
    let descriptionIssuePlaceholder = String(localized: "Describe the issue in detail...")
    let attachImage = String(localized: "Attach image (optional)")
    let titleIssueImage = String(localized: "Issue image")
    let loadingImage = String(localized: "Loading image...")
    let dragAndDropImage = String(localized: "Drag and drop an image here")
    let or = String(localized: "or")
}
