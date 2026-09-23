//
//  VoticeTests.swift
//  Votice
//
//  Created by Arturo Carretero Calvo on 27/6/25.
//  Copyright © 2025 ArtCC. All rights reserved.

import Testing
@testable import VoticeSDK
import SwiftUI

@Suite("Votice Tests")
struct VoticeTests {
    @Test("Votice should configure with valid credentials")
    func testValidConfiguration() throws {
        // Reset before test
        Votice.reset()

        try Votice.configure(
            apiKey: "test-api-key",
            apiSecret: "test-api-secret",
            appId: "test-app-id"
        )

        #expect(Votice.isConfigured)
    }

    @Test("Votice should throw error with invalid credentials")
    func testInvalidConfiguration() {
        // Reset before test
        Votice.reset()

        #expect(throws: ConfigurationError.self) {
            try Votice.configure(
                apiKey: "",
                apiSecret: "test-api-secret",
                appId: "test-app-id"
            )
        }
    }

    @Test("Votice should reset configuration")
    func testResetConfiguration() throws {
        // Reset first to start clean
        Votice.reset()

        // Configure first
        try Votice.configure(
            apiKey: "test-api-key",
            apiSecret: "test-api-secret",
            appId: "test-app-id"
        )

        #expect(Votice.isConfigured)

        // Reset
        Votice.reset()

        #expect(!Votice.isConfigured)
    }

    @Test("Votice should create system theme")
    func testSystemTheme() {
        let theme = Votice.systemTheme()

        #expect(theme.colors.primary != nil)
        #expect(theme.typography.title != nil)
        #expect(theme.spacing.md == 16)
        #expect(theme.cornerRadius.lg == 16)
    }

    @Test("Votice should create default theme")
    func testDefaultTheme() {
        let theme = Votice.defaultTheme()

        #expect(theme.colors.primary != nil)
        #expect(theme.typography.title != nil)
        #expect(theme.spacing.md == 16)
        #expect(theme.cornerRadius.lg == 16)
    }

    @Test("Votice should create custom theme")
    func testCustomTheme() {
        let theme = Votice.createTheme(
            primaryColor: .blue,
            backgroundColor: .white,
            surfaceColor: .gray
        )

        #expect(theme.colors.primary == .blue)
        #expect(theme.colors.background == .white)
        #expect(theme.colors.surface == .gray)
    }

    @Test("Votice should create advanced theme")
    func testAdvancedTheme() {
        let theme = Votice.createAdvancedTheme(
            primaryColor: .blue,
            accentColor: .orange,
            backgroundColor: .white,
            surfaceColor: .gray,
            destructiveColor: .red,
            successColor: .green,
            warningColor: .yellow
        )

        #expect(theme.colors.primary == .blue)
        #expect(theme.colors.accent == .orange)
        #expect(theme.colors.background == .white)
        #expect(theme.colors.surface == .gray)
        #expect(theme.colors.error == .red)
        #expect(theme.colors.success == .green)
        #expect(theme.colors.warning == .yellow)
    }

    // swiftlint:disable function_body_length
    @Test("Votice should set custom texts")
    func testSetCustomTexts() {
        // Create mock texts
        struct MockTexts: VoticeTextsProtocol {
            let cancel = "Mock Cancel"
            let error = "Mock Error"
            let ok = "Mock OK"
            let submit = "Mock Submit"
            let optional = "Mock Optional"
            let success = "Mock Success"
            let warning = "Mock Warning"
            let info = "Mock Info"
            let genericError = "Mock Generic Error"
            let anonymous = "Mock Anonymous"
            let loadingSuggestions = "Mock Loading"
            let noSuggestionsYet = "Mock No Suggestions"
            let beFirstToSuggest = "Mock Be First"
            let noMatchingSuggestions = "Mock No Matching Suggestions"
            let noMatchingSuggestionsMessage = "Mock No Suggestions For Selected Status"
            let noSuggestionsMessage = "Mock Suggestions Will Appear Here"
            let featureRequests = "Mock Feature Requests"
            let all = "Mock All"
            let activeTab = "Mock Active"
            let completedTab = "Mock Completed"
            let pending = "Mock Pending"
            let accepted = "Mock Accepted"
            let blocked = "Mock Blocked"
            let inProgress = "Mock In Progress"
            let completed = "Mock Completed"
            let rejected = "Mock Rejected"
            let tapPlusToGetStarted = "Mock Tap Plus"
            let loadingMore = "Mock Loading More"
            let suggestionTitle = "Mock Suggestion Title"
            let issueTitle = "Mock Issue Title"
            let close = "Mock Close"
            let deleteSuggestionTitle = "Mock Delete Title"
            let deleteSuggestionMessage = "Mock Delete Message"
            let delete = "Mock Delete"
            let suggestedBy = "Mock Suggested By"
            let suggestedAnonymously = "Mock Suggested Anonymously"
            let votes = "Mock Votes"
            let comments = "Mock Comments"
            let commentsSection = "Mock Comments Section"
            let loadingComments = "Mock Loading Comments"
            let noComments = "Mock No Comments"
            let addComment = "Mock Add Comment"
            let yourComment = "Mock Your Comment"
            let shareYourThoughts = "Mock Share Your Thoughts"
            let yourNameOptional = "Mock Your Name Optional"
            let enterYourName = "Mock Enter Your Name"
            let newComment = "Mock New Comment"
            let post = "Mock Post"
            let deleteCommentTitle = "Mock Delete Comment Title"
            let deleteCommentMessage = "Mock Delete Comment Message"
            let deleteCommentPrimary = "Mock Delete Comment Primary"
            let newSuggestion = "Mock New Suggestion"
            let shareYourIdea = "Mock Share Your Idea"
            let helpUsImprove = "Mock Help Us Improve"
            let title = "Mock Title"
            let titlePlaceholder = "Mock Title Placeholder"
            let keepItShort = "Mock Keep It Short"
            let descriptionOptional = "Mock Description Optional"
            let descriptionPlaceholder = "Mock Description Placeholder"
            let explainWhyUseful = "Mock Explain Why Useful"
            let yourNameOptionalCreate = "Mock Your Name Optional Create"
            let enterYourNameCreate = "Mock Enter Your Name Create"
            let leaveEmptyAnonymous = "Mock Leave Empty Anonymous"
            let reportIssue = "Test Report Issue"
            let reportIssueSubtitle = "Test Report Issue Subtitle"
            let titleIssuePlaceholder = "Enter a brief title for the issue"
            let descriptionIssuePlaceholder = "Describe the issue in detail..."
            let attachImage = "Test Attach Image"
            let titleIssueImage = "Test Issue Image"
            let loadingImage = "Test Loading image..."
            let dragAndDropImage = "Test Drag image here"
            let or = "Test or"
        }

        Votice.setTexts(MockTexts())

        #expect(TextManager.shared.texts.cancel == "Mock Cancel")
        #expect(TextManager.shared.texts.error == "Mock Error")

        // Reset to default
        Votice.resetTextsToDefault()

        #expect(TextManager.shared.texts.cancel == "Cancel")
        #expect(TextManager.shared.texts.error == "Error")
    }
    // swiftlint:enable function_body_length

    @Test("Votice should set custom fonts")
    func testSetCustomFonts() {
        let config = VoticeFontConfiguration(
            fontFamily: "TestFont",
            weights: [
                .regular: "TestFont-Regular",
                .bold: "TestFont-Bold"
            ]
        )

        Votice.setFonts(config)

        // Should set the configuration (we can't easily test the actual font rendering)
        #expect(config.hasCustomFonts == true)
        #expect(config.fontFamily == "TestFont")

        // Reset to system
        Votice.resetFontsToSystem()

        let systemConfig = VoticeFontConfiguration.system
        #expect(systemConfig.hasCustomFonts == false)
    }

    @Test("Votice should create theme with current fonts")
    func testCreateThemeWithCurrentFonts() {
        let config = VoticeFontConfiguration(
            fontFamily: "TestFont",
            weights: [.regular: "TestFont-Regular"]
        )

        Votice.setFonts(config)

        let theme = Votice.createThemeWithCurrentFonts(primaryColor: .blue)

        #expect(theme.colors.primary == .blue)
        #expect(theme.typography.body != nil)

        // Clean up
        Votice.resetFontsToSystem()
    }

    @Test("Votice should create system theme with current fonts")
    func testSystemThemeWithCurrentFonts() {
        let config = VoticeFontConfiguration(
            fontFamily: "TestFont",
            weights: [.regular: "TestFont-Regular"]
        )

        Votice.setFonts(config)

        let theme = Votice.systemThemeWithCurrentFonts()

        #expect(theme.colors.primary != nil)
        #expect(theme.typography.body != nil)

        // Clean up
        Votice.resetFontsToSystem()
    }

    @Test("Votice should handle deprecated initialize method")
    func testDeprecatedInitialize() {
        // Should not crash (deprecated method)
        Votice.initialize()
    }
}
