//
//  TextManagerTests.swift
//  Votice
//
//  Created by Arturo Carretero Calvo on 31/12/25.
//  Copyright © 2025 ArtCC. All rights reserved.
//

import Testing
@testable import VoticeSDK
import Foundation

// MARK: - Mock Texts Implementation

struct MockVoticeTexts: VoticeTextsProtocol {
    // MARK: - General

    let cancel = "Test Cancel"
    let error = "Test Error"
    let ok = "Test OK"
    let submit = "Test Submit"
    let optional = "Test Optional"
    let success = "Test Success"
    let warning = "Test Warning"
    let info = "Test Info"
    let genericError = "Test Generic Error"
    let anonymous = "Anonymous"

    // MARK: - Suggestion List

    let loadingSuggestions = "Test Loading"
    let noSuggestionsYet = "Test No Suggestions"
    let beFirstToSuggest = "Test Be First"
    let noMatchingSuggestions = "Test No Matching Suggestions"
    let noMatchingSuggestionsMessage = "Test No Suggestions For Selected Status"
    let noSuggestionsMessage = "Test Suggestions Will Appear Here"
    let featureRequests = "Test Feature Requests"
    let all = "Test All"
    let activeTab = "Test Active"
    let completedTab = "Test Completed"
    let pending = "Test Pending"
    let accepted = "Test Accepted"
    let blocked = "Test Blocked"
    let inProgress = "Test In Progress"
    let completed = "Test Completed"
    let rejected = "Test Rejected"
    let tapPlusToGetStarted = "Test Tap Plus"
    let loadingMore = "Test Loading More"

    // MARK: - Suggestion Detail

    let suggestionTitle = "Test Suggestion"
    let issueTitle = "Test Issue"
    let close = "Test Close"
    let deleteSuggestionTitle = "Test Delete Suggestion"
    let deleteSuggestionMessage = "Test Delete Message"
    let delete = "Test Delete"
    let suggestedBy = "Test Suggested By"
    let suggestedAnonymously = "Test Suggested Anonymously"
    let votes = "test votes"
    let comments = "test comments"
    let commentsSection = "Test Comments"
    let loadingComments = "Test Loading Comments"
    let noComments = "Test No Comments"
    let addComment = "Test Add Comment"
    let yourComment = "Test Your Comment"
    let shareYourThoughts = "Test Share Thoughts"
    let yourNameOptional = "Test Your Name"
    let enterYourName = "Test Enter Name"
    let newComment = "Test New Comment"
    let post = "Test Post"
    let deleteCommentTitle = "Test Delete Comment"
    let deleteCommentMessage = "Test Delete Comment Message"
    let deleteCommentPrimary = "Test Delete"

    // MARK: - Create Suggestion

    let newSuggestion = "Test New Suggestion"
    let shareYourIdea = "Test Share Idea"
    let helpUsImprove = "Test Help Improve"
    let title = "Test Title"
    let titlePlaceholder = "Test Title Placeholder"
    let keepItShort = "Test Keep Short"
    let descriptionOptional = "Test Description"
    let descriptionPlaceholder = "Test Description Placeholder"
    let explainWhyUseful = "Test Explain Useful"
    let yourNameOptionalCreate = "Test Your Name Create"
    let enterYourNameCreate = "Test Enter Name Create"
    let leaveEmptyAnonymous = "Test Leave Empty"

    // MARK: - Create Issue (optional feature)

    let reportIssue = "Test Report Issue"
    let reportIssueSubtitle = "Test Report Issue Subtitle"
    let titleIssuePlaceholder = "Test Title Issue Placeholder"
    let descriptionIssuePlaceholder = "Test Description Issue Placeholder"
    let attachImage = "Test Attach Image"
    let titleIssueImage = "Test Issue Image"
    let loadingImage = "Test Loading image..."
    let dragAndDropImage = "Test Drag image here"
    let or = "Test or"
}

// MARK: - TextManager Tests

@Test("TextManager should initialize with default texts")
func testTextManagerInitialization() async {
    // Given
    let manager = TextManager.shared

    // Ensure clean state first
    manager.resetToDefault()

    // When
    let texts = manager.texts

    // Then
    #expect(texts.cancel == "Cancel")
    #expect(texts.error == "Error")
    #expect(texts.ok == "Ok")
    #expect(texts.submit == "Submit")
    #expect(texts.optional == "Optional")
    #expect(texts.success == "Success")
    #expect(texts.warning == "Warning")
    #expect(texts.info == "Info")
    #expect(texts.genericError == "Something went wrong. Please try again.")
    #expect(texts.anonymous == "Anonymous")
    #expect(texts.loadingSuggestions == "Loading suggestions...")
    #expect(texts.featureRequests == "Feature Requests")
    #expect(texts.newSuggestion == "New Suggestion")
}

@Test("TextManager should update texts correctly")
func testTextManagerUpdateTexts() async {
    // Given
    let manager = TextManager.shared
    let mockTexts = MockVoticeTexts()

    // When
    manager.setTexts(mockTexts)
    let updatedTexts = manager.texts

    // Then
    #expect(updatedTexts.cancel == "Test Cancel")
    #expect(updatedTexts.error == "Test Error")
    #expect(updatedTexts.ok == "Test OK")
    #expect(updatedTexts.submit == "Test Submit")
    #expect(updatedTexts.optional == "Test Optional")
    #expect(updatedTexts.loadingSuggestions == "Test Loading")
    #expect(updatedTexts.featureRequests == "Test Feature Requests")
    #expect(updatedTexts.newSuggestion == "Test New Suggestion")

    // Reset for other tests
    manager.resetToDefault()
}

@Test("TextManager should reset to default texts")
func testTextManagerResetToDefault() async {
    // Given
    let manager = TextManager.shared
    let mockTexts = MockVoticeTexts()
    manager.setTexts(mockTexts)

    // Verify it's changed
    #expect(manager.texts.cancel == "Test Cancel")

    // When
    manager.resetToDefault()
    let resetTexts = manager.texts

    // Then
    #expect(resetTexts.cancel == "Cancel")
    #expect(resetTexts.error == "Error")
    #expect(resetTexts.ok == "Ok")
    #expect(resetTexts.submit == "Submit")
    #expect(resetTexts.optional == "Optional")
    #expect(resetTexts.loadingSuggestions == "Loading suggestions...")
    #expect(resetTexts.featureRequests == "Feature Requests")
    #expect(resetTexts.newSuggestion == "New Suggestion")
}

@Test("TextManager should be thread-safe")
func testTextManagerThreadSafety() async {
    // Given
    let manager = TextManager.shared
    let mockTexts = MockVoticeTexts()
    var results: [String] = []
    let lock = NSLock()

    // When - Access and modify from multiple threads
    await withTaskGroup(of: Void.self) { group in
        // Reader tasks
        for i in 0..<5 {
            group.addTask {
                let text = manager.texts.cancel
                lock.withLock {
                    results.append("read-\(i)-\(text)")
                }
            }
        }

        // Writer tasks
        for i in 0..<3 {
            group.addTask {
                if i % 2 == 0 {
                    manager.setTexts(mockTexts)
                } else {
                    manager.resetToDefault()
                }
                lock.withLock {
                    results.append("write-\(i)")
                }
            }
        }
    }

    // Then - Should not crash and should have all results
    #expect(results.count == 8)
    #expect(results.filter { $0.hasPrefix("read-") }.count == 5)
    #expect(results.filter { $0.hasPrefix("write-") }.count == 3)

    // Final state should be valid
    let finalTexts = manager.texts
    #expect(!finalTexts.cancel.isEmpty)
    #expect(!finalTexts.error.isEmpty)

    // Reset for other tests
    manager.resetToDefault()
}

@Test("TextManager should maintain singleton behavior")
func testTextManagerSingleton() async {
    // Given/When
    let manager1 = TextManager.shared
    let manager2 = TextManager.shared

    // Then
    #expect(manager1 === manager2) // Same instance
}

// swiftlint:disable function_body_length
@Test("TextManager should handle multiple text updates")
func testTextManagerMultipleUpdates() async {
    // Given
    let manager = TextManager.shared
    let mockTexts1 = MockVoticeTexts()

    struct AnotherMockTexts: VoticeTextsProtocol {
        let cancel = "Annuler"
        let error = "Erreur"
        let ok = "D'accord"
        let submit = "Soumettre"
        let optional = "Optionnel"
        let success = "Success"
        let warning = "Warning"
        let info = "Info"
        let genericError = "Something went wrong. Please try again."
        let anonymous = "Anonyme"
        let loadingSuggestions = "Chargement des suggestions..."
        let noSuggestionsYet = "Pas encore de suggestions."
        let beFirstToSuggest = "Soyez le premier à suggérer quelque chose!"
        let noMatchingSuggestions = "Aucune suggestion correspondante"
        let noMatchingSuggestionsMessage = "Aucune suggestion pour le statut sélectionné."
        let noSuggestionsMessage = "Les suggestions apparaîtront ici lorsqu'elles seront disponibles."
        let featureRequests = "Demandes de fonctionnalités"
        let all = "Toutes"
        let activeTab = "Actif"
        let completedTab = "Terminé"
        let pending = "En attente"
        let accepted = "Acceptée"
        let blocked = "Bloquée"
        let inProgress = "En cours"
        let completed = "Terminée"
        let rejected = "Rejetée"
        let tapPlusToGetStarted = "Appuyez sur + pour commencer"
        let loadingMore = "Charger plus..."
        let suggestionTitle = "Suggestion"
        let issueTitle = "Problème"
        let close = "Fermer"
        let deleteSuggestionTitle = "Supprimer la suggestion"
        let deleteSuggestionMessage = "Êtes-vous sûr de vouloir supprimer cette suggestion?"
        let delete = "Supprimer"
        let suggestedBy = "Suggéré par"
        let suggestedAnonymously = "Suggéré anonymement"
        let votes = "votes"
        let comments = "commentaires"
        let commentsSection = "Commentaires"
        let loadingComments = "Chargement des commentaires..."
        let noComments = "Pas encore de commentaires. Soyez le premier à commenter!"
        let addComment = "Ajouter un commentaire"
        let yourComment = "Votre commentaire"
        let shareYourThoughts = "Partagez vos pensées..."
        let yourNameOptional = "Votre nom (optionnel)"
        let enterYourName = "Entrez votre nom"
        let newComment = "Nouveau commentaire"
        let post = "Publier"
        let deleteCommentTitle = "Supprimer le commentaire"
        let deleteCommentMessage = "Êtes-vous sûr de vouloir supprimer ce commentaire?"
        let deleteCommentPrimary = "Supprimer"
        let newSuggestion = "Nouvelle suggestion"
        let shareYourIdea = "Partagez votre idée"
        let helpUsImprove = "Aidez-nous à améliorer en suggérant de nouvelles fonctionnalités ou améliorations."
        let title = "Titre"
        let titlePlaceholder = "Entrez un titre bref pour votre suggestion"
        let keepItShort = "Gardez-le court et descriptif"
        let descriptionOptional = "Description (optionnelle)"
        let descriptionPlaceholder = "Décrivez votre suggestion en détail..."
        let explainWhyUseful = "Expliquez pourquoi cette fonctionnalité serait utile"
        let yourNameOptionalCreate = "Votre nom (optionnel)"
        let enterYourNameCreate = "Entrez votre nom"
        let leaveEmptyAnonymous = "Laissez vide pour soumettre anonymement"
        let reportIssue = "Signaler un problème"
        let reportIssueSubtitle = "Aidez-nous à le corriger en décrivant le problème rencontré."
        let titleIssuePlaceholder = "Entrez un titre bref pour le problème"
        let descriptionIssuePlaceholder = "Décrivez le problème en détail..."
        let attachImage = "Joindre une image"
        let titleIssueImage = "Image du problème"
        let loadingImage = "Chargement de l'image..."
        let dragAndDropImage = "Faites glisser l'image ici"
        let or = "ou"
    }

    let mockTexts2 = AnotherMockTexts()

    // When - Multiple updates
    manager.setTexts(mockTexts1)
    #expect(manager.texts.cancel == "Test Cancel")

    manager.setTexts(mockTexts2)
    #expect(manager.texts.cancel == "Annuler")

    manager.resetToDefault()
    #expect(manager.texts.cancel == "Cancel")

    // Then - Final state should be default
    let finalTexts = manager.texts
    #expect(finalTexts.cancel == "Cancel")
    #expect(finalTexts.error == "Error")
}
// swiftlint:enable function_body_length

// MARK: - DefaultVoticeTexts Tests

@Test("DefaultVoticeTexts should have all required properties")
func testDefaultVoticeTexts() async {
    // Given
    let texts = DefaultVoticeTexts()

    // Then - General
    #expect(texts.cancel == "Cancel")
    #expect(texts.error == "Error")
    #expect(texts.ok == "Ok")
    #expect(texts.submit == "Submit")
    #expect(texts.optional == "Optional")
    #expect(texts.success == "Success")
    #expect(texts.warning == "Warning")
    #expect(texts.info == "Info")
    #expect(texts.genericError == "Something went wrong. Please try again.")
    #expect(texts.anonymous == "Anonymous")

    // Suggestion List
    #expect(texts.loadingSuggestions == "Loading suggestions...")
    #expect(texts.noSuggestionsYet == "No suggestions yet.")
    #expect(texts.beFirstToSuggest == "Be the first to suggest something!")
    #expect(texts.featureRequests == "Feature Requests")
    #expect(texts.all == "All")
    #expect(texts.pending == "Pending")
    #expect(texts.accepted == "Accepted")
    #expect(texts.blocked == "Blocked")
    #expect(texts.inProgress == "In Progress")
    #expect(texts.completed == "Completed")
    #expect(texts.rejected == "Rejected")
    #expect(texts.tapPlusToGetStarted == "Tap + to get started")
    #expect(texts.loadingMore == "Loading more...")

    // Suggestion Detail
    #expect(texts.suggestionTitle == "Suggestion")
    #expect(texts.issueTitle == "Issue")
    #expect(texts.close == "Close")
    #expect(texts.deleteSuggestionTitle == "Delete Suggestion")
    #expect(texts.deleteSuggestionMessage == "Are you sure you want to delete this suggestion?")
    #expect(texts.delete == "Delete")
    #expect(texts.suggestedBy == "Suggested by")
    #expect(texts.suggestedAnonymously == "Suggested anonymously")
    #expect(texts.votes == "votes")
    #expect(texts.comments == "comments")

    // Create Suggestion
    #expect(texts.newSuggestion == "New Suggestion")
    #expect(texts.shareYourIdea == "Share your idea")
    #expect(texts.title == "Title (Min. 3 characters)")
    #expect(texts.titlePlaceholder == "Enter a brief title for your suggestion")

    // Create Issue
    #expect(texts.reportIssue == "Report Issue")
    #expect(texts.reportIssueSubtitle == "Help us fix it by describing the issue you encountered.")
    #expect(texts.titleIssuePlaceholder == "Enter a brief title for the issue")
    #expect(texts.descriptionIssuePlaceholder == "Describe the issue in detail...")
    #expect(texts.attachImage == "Attach Image")
    #expect(texts.titleIssueImage == "Issue Image")
    #expect(texts.loadingImage == "Loading image...")
    #expect(texts.dragAndDropImage == "Drag image here")
    #expect(texts.or == "or")
}

@Test("DefaultVoticeTexts should be Sendable")
func testDefaultVoticeTextsSendable() async {
    // Given
    let texts = DefaultVoticeTexts()

    // When - This compiles, proving it's Sendable
    Task {
        _ = texts.cancel
        _ = texts.error
        _ = texts.newSuggestion
    }

    // Then - No assertion needed, compilation proves Sendable conformance
}
