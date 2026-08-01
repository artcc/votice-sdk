//
//  ConfigurationManagerTests.swift
//  Votice
//
//  Created by Arturo Carretero Calvo on 28/6/25.
//  Copyright © 2025 ArtCC. All rights reserved.
//

import Testing
@testable import VoticeSDK
import Foundation

// MARK: - ConfigurationManager Tests

@Suite("ConfigurationManager Tests")
struct ConfigurationManagerTests {
    @Test("ConfigurationManager should initialize with correct defaults")
    func testConfigurationManagerInitialization() async {
        // Given
        let manager = ConfigurationManager()

        // Then
        #expect(manager.isConfigured == false)
        #expect(manager.baseURL == "https://api-svdrkzyfhq-uc.a.run.app/api")
        #expect(manager.apiKey.isEmpty)
        #expect(manager.apiSecret.isEmpty)
        #expect(manager.appId.isEmpty)
        #expect(!manager.configurationId.isEmpty)

        // Test default settings
        #expect(manager.commentIsEnabled == true)
        #expect(manager.showCompletedSeparately == false)
        #expect(manager.user.isPremium == false)
        #expect(manager.optionalVisibleStatuses == [.accepted, .blocked, .rejected])
        #expect(manager.version == "1.0.21")
        #expect(manager.buildNumber == "1")
    }

    @Test("ConfigurationManager should configure successfully with valid credentials")
    func testConfigurationManagerValidConfiguration() async throws {
        // Given
        let manager = ConfigurationManager()

        // When
        try manager.configure(apiKey: "test-api-key", apiSecret: "test-api-secret", appId: "test-appId")

        // Then
        #expect(manager.isConfigured == true)
        #expect(manager.apiKey == "test-api-key")
        #expect(manager.apiSecret == "test-api-secret")
        #expect(manager.appId == "test-appId")
    }

    @Test("ConfigurationManager should throw error for empty API key")
    func testConfigurationManagerEmptyAPIKey() async {
        // Given
        let manager = ConfigurationManager()

        // When/Then
        #expect(throws: ConfigurationError.invalidAPIKey) {
            try manager.configure(apiKey: "", apiSecret: "valid-secret", appId: "valid-appId")
        }

        #expect(manager.isConfigured == false)
    }

    @Test("ConfigurationManager should throw error for empty API secret")
    func testConfigurationManagerEmptyAPISecret() async {
        // Given
        let manager = ConfigurationManager()

        // When/Then
        #expect(throws: ConfigurationError.invalidAPISecret) {
            try manager.configure(apiKey: "valid-key", apiSecret: "", appId: "valid-appId")
        }

        #expect(manager.isConfigured == false)
    }

    @Test("ConfigurationManager should throw error for empty App ID")
    func testConfigurationManagerEmptyAppId() async {
        // Given
        let manager = ConfigurationManager()

        // When/Then
        #expect(throws: ConfigurationError.invalidAppId) {
            try manager.configure(apiKey: "valid-key", apiSecret: "valid-secret", appId: "")
        }

        #expect(manager.isConfigured == false)
    }

    @Test("ConfigurationManager should throw error when already configured")
    func testConfigurationManagerAlreadyConfigured() async throws {
        // Given
        let manager = ConfigurationManager()
        try manager.configure(apiKey: "test-key", apiSecret: "test-secret", appId: "test-appId")

        // When/Then
        #expect(throws: ConfigurationError.alreadyConfigured) {
            try manager.configure(apiKey: "new-key", apiSecret: "new-secret", appId: "new-appId")
        }

        // Should maintain original configuration
        #expect(manager.apiKey == "test-key")
        #expect(manager.apiSecret == "test-secret")
        #expect(manager.appId == "test-appId")
    }

    @Test("ConfigurationManager reset should clear configuration")
    func testConfigurationManagerReset() async throws {
        // Given
        let manager = ConfigurationManager()
        try manager.configure(apiKey: "test-key", apiSecret: "test-secret", appId: "test-appId")

        // Modify some settings
        manager.commentIsEnabled = false
        manager.showCompletedSeparately = true
        manager.user = UserEntity(isPremium: true)
        manager.setOptionalVisibleStatus(accepted: true, blocked: false, rejected: false)

        #expect(manager.isConfigured == true)

        // When
        manager.reset()

        // Then
        #expect(manager.isConfigured == false)
        #expect(manager.apiKey.isEmpty)
        #expect(manager.apiSecret.isEmpty)
        #expect(manager.appId.isEmpty)
        #expect(manager.baseURL == "https://api-svdrkzyfhq-uc.a.run.app/api") // baseURL should remain

        // Settings should be reset to defaults
        #expect(manager.commentIsEnabled == true)
        #expect(manager.showCompletedSeparately == false)
        #expect(manager.optionalVisibleStatuses == [.accepted, .blocked, .rejected])

        // ConfigurationId, version, and buildNumber should remain unchanged
        #expect(!manager.configurationId.isEmpty)
        #expect(manager.version == "1.0.21")
        #expect(manager.buildNumber == "1")
    }

    @Test("ConfigurationManager validateConfiguration should succeed when configured")
    func testConfigurationManagerValidateConfigurationSuccess() async throws {
        // Given
        let manager = ConfigurationManager()
        try manager.configure(apiKey: "test-key", apiSecret: "test-secret", appId: "test-appId")

        // When/Then - Should not throw
        try manager.validateConfiguration()
    }

    @Test("ConfigurationManager validateConfiguration should throw when not configured")
    func testConfigurationManagerValidateConfigurationFailure() async {
        // Given
        let manager = ConfigurationManager()

        // When/Then
        #expect(throws: ConfigurationError.notConfigured) {
            try manager.validateConfiguration()
        }
    }

    @Test("ConfigurationManager should be thread-safe")
    func testConfigurationManagerThreadSafety() async throws {
        // Given
        let manager = ConfigurationManager()

        // When - Configure from multiple threads concurrently
        await withTaskGroup(of: Void.self) { group in
            for index in 0..<10 {
                group.addTask {
                    do {
                        try manager.configure(
                            apiKey: "key-\(index)",
                            apiSecret: "secret-\(index)",
                            appId: "app-\(index)"
                        )
                    } catch {
                        // Expected - only one should succeed
                    }
                }
            }
        }

        // Then - Should be configured with one of the values
        #expect(manager.isConfigured == true)
        #expect(!manager.apiKey.isEmpty)
        #expect(!manager.apiSecret.isEmpty)
        #expect(!manager.appId.isEmpty)
    }

    @Test("ConfigurationManager should have unique configuration ID")
    func testConfigurationManagerUniqueID() async {
        // Given
        let manager1 = ConfigurationManager()
        let manager2 = ConfigurationManager()

        // When
        let configId1 = manager1.configurationId
        let configId2 = manager2.configurationId

        // Then
        #expect(!configId1.isEmpty)
        #expect(!configId2.isEmpty)
        #expect(configId1.count == 36) // UUID format
        #expect(configId2.count == 36) // UUID format
        #expect(configId1 != configId2) // Each instance should have unique ID

        // Should be consistent across calls on same instance
        #expect(manager1.configurationId == configId1)
        #expect(manager2.configurationId == configId2)
    }

    // MARK: - Settings Tests

    @Test("ConfigurationManager should handle commentIsEnabled setting")
    func testCommentIsEnabledSetting() async {
        // Given
        let manager = ConfigurationManager()

        // Initial state
        #expect(manager.commentIsEnabled == true)

        // When
        manager.commentIsEnabled = false

        // Then
        #expect(manager.commentIsEnabled == false)

        // When
        manager.commentIsEnabled = true

        // Then
        #expect(manager.commentIsEnabled == true)
    }

    @Test("ConfigurationManager should handle showCompletedSeparately setting")
    func testShowCompletedSeparatelySetting() async {
        // Given
        let manager = ConfigurationManager()

        // Initial state
        #expect(manager.showCompletedSeparately == false)

        // When
        manager.showCompletedSeparately = true

        // Then
        #expect(manager.showCompletedSeparately == true)

        // When
        manager.showCompletedSeparately = false

        // Then
        #expect(manager.showCompletedSeparately == false)
    }

    @Test("ConfigurationManager should handle user setting")
    func testUserSetting() async {
        // Given
        let manager = ConfigurationManager()

        // Initial state
        #expect(manager.user.isPremium == false)

        // When
        manager.user = UserEntity(isPremium: true)

        // Then
        #expect(manager.user.isPremium == true)

        // When
        manager.user = UserEntity(isPremium: false)

        // Then
        #expect(manager.user.isPremium == false)
    }

    @Test("ConfigurationManager should handle optional visible statuses")
    func testOptionalVisibleStatuses() async {
        // Given
        let manager = ConfigurationManager()

        // Initial state
        #expect(manager.optionalVisibleStatuses == [.accepted, .blocked, .rejected])

        // When - Set only accepted
        manager.setOptionalVisibleStatus(accepted: true, blocked: false, rejected: false)

        // Then
        #expect(manager.optionalVisibleStatuses == [.accepted])

        // When - Set accepted and rejected
        manager.setOptionalVisibleStatus(accepted: true, blocked: false, rejected: true)

        // Then
        #expect(manager.optionalVisibleStatuses == [.accepted, .rejected])

        // When - Set all
        manager.setOptionalVisibleStatus(accepted: true, blocked: true, rejected: true)

        // Then
        #expect(manager.optionalVisibleStatuses == [.accepted, .blocked, .rejected])

        // When - Set none
        manager.setOptionalVisibleStatus(accepted: false, blocked: false, rejected: false)

        // Then
        #expect(manager.optionalVisibleStatuses.isEmpty)

        // When - Set only blocked
        manager.setOptionalVisibleStatus(accepted: false, blocked: true, rejected: false)

        // Then
        #expect(manager.optionalVisibleStatuses == [.blocked])
    }

    @Test("ConfigurationManager should maintain constant properties")
    func testConstantProperties() async {
        // Given
        let manager = ConfigurationManager()

        // Test immutable properties
        #expect(manager.baseURL == "https://api-svdrkzyfhq-uc.a.run.app/api")
        #expect(manager.version == "1.0.21")
        #expect(manager.buildNumber == "1")

        // Configuration ID should be consistent for same instance
        let configId = manager.configurationId
        #expect(manager.configurationId == configId)
        #expect(manager.configurationId == configId) // Test multiple calls
    }

    // MARK: - Thread Safety Tests for Settings

    @Test("ConfigurationManager settings should be thread-safe")
    func testSettingsThreadSafety() async {
        // Given
        let manager = ConfigurationManager()

        // When - Modify settings from multiple threads concurrently
        await withTaskGroup(of: Void.self) { group in
            // Test commentIsEnabled
            for _ in 0..<10 {
                group.addTask {
                    manager.commentIsEnabled = Bool.random()
                }
            }

            // Test showCompletedSeparately
            for _ in 0..<10 {
                group.addTask {
                    manager.showCompletedSeparately = Bool.random()
                }
            }

            // Test user
            for _ in 0..<10 {
                group.addTask {
                    manager.user = UserEntity(isPremium: Bool.random())
                }
            }

            // Test optionalVisibleStatuses
            for _ in 0..<10 {
                group.addTask {
                    manager.setOptionalVisibleStatus(
                        accepted: Bool.random(),
                        blocked: Bool.random(),
                        rejected: Bool.random()
                    )
                }
            }
        }

        // Then - Should not crash and properties should be accessible
        _ = manager.commentIsEnabled
        _ = manager.showCompletedSeparately
        _ = manager.user
        _ = manager.optionalVisibleStatuses
    }
}

// MARK: - Additional Configuration Tests

extension ConfigurationManagerTests {

    @Test("ConfigurationManager should handle all optional visible status combinations")
    func testOptionalVisibleStatusCombinations() async {
        // Given
        let manager = ConfigurationManager()

        // Test all possible combinations
        // swiftlint:disable large_tuple
        let combinations: [(accepted: Bool, blocked: Bool, rejected: Bool, expected: Set<SuggestionStatusEntity>)] = [
            (true, true, true, [.accepted, .blocked, .rejected]),
            (true, true, false, [.accepted, .blocked]),
            (true, false, true, [.accepted, .rejected]),
            (false, true, true, [.blocked, .rejected]),
            (true, false, false, [.accepted]),
            (false, true, false, [.blocked]),
            (false, false, true, [.rejected]),
            (false, false, false, [])
        ]
        // swiftlint:enable large_tuple

        for (accepted, blocked, rejected, expected) in combinations {
            // When
            manager.setOptionalVisibleStatus(accepted: accepted, blocked: blocked, rejected: rejected)

            // Then
            // swiftlint:disable line_length
            #expect(manager.optionalVisibleStatuses == expected, "Failed for combination: accepted=\(accepted), blocked=\(blocked), rejected=\(rejected)")
            // swiftlint:enable line_length
        }
    }

    @Test("ConfigurationManager should maintain settings after configuration")
    func testSettingsPersistenceAfterConfiguration() async throws {
        // Given
        let manager = ConfigurationManager()

        // Modify settings before configuration
        manager.commentIsEnabled = false
        manager.showCompletedSeparately = true
        manager.setOptionalVisibleStatus(accepted: true, blocked: false, rejected: false)

        // When
        try manager.configure(apiKey: "test-key", apiSecret: "test-secret", appId: "test-appId")

        // Then - Settings should be maintained after configuration
        #expect(manager.isConfigured == true)
        #expect(manager.commentIsEnabled == false)
        #expect(manager.showCompletedSeparately == true)
        #expect(manager.optionalVisibleStatuses == [.accepted])
    }
}

// MARK: - ConfigurationError Tests

@Suite("ConfigurationError Tests")
struct ConfigurationErrorTests {
    @Test("ConfigurationError should provide correct descriptions")
    func testConfigurationErrorDescriptions() async {
        // Given/When/Then
        #expect(ConfigurationError.alreadyConfigured.errorDescription == "Votice SDK is already configured")
        #expect(
            ConfigurationError
                .notConfigured
                .errorDescription == "Votice SDK is not configured. Call Votice.configure() first"
        )
        #expect(ConfigurationError.invalidAPIKey.errorDescription == "Invalid API key provided")
        #expect(ConfigurationError.invalidAPISecret.errorDescription == "Invalid API secret provided")
        #expect(ConfigurationError.invalidAppId.errorDescription == "Invalid App ID provided")
    }

    @Test("ConfigurationError should be Sendable")
    func testConfigurationErrorSendable() async {
        // Given
        let error: ConfigurationError = .invalidAPIKey

        // When - Pass error between async contexts
        let result = await withTaskGroup(of: ConfigurationError.self) { group in
            group.addTask {
                return error
            }

            return await group.next()!
        }

        // Then
        #expect(result == .invalidAPIKey)
    }

    @Test("ConfigurationError should conform to Error protocol")
    func testConfigurationErrorAsError() async {
        // Given
        let errors: [Error] = [
            ConfigurationError.alreadyConfigured,
            ConfigurationError.notConfigured,
            ConfigurationError.invalidAPIKey,
            ConfigurationError.invalidAPISecret,
            ConfigurationError.invalidAppId
        ]

        // When/Then - Should be able to cast back to ConfigurationError
        for error in errors {
            #expect(error is ConfigurationError)
        }
    }

    @Test("ConfigurationError cases should be equatable")
    func testConfigurationErrorEquality() async {
        // Given/When/Then
        #expect(ConfigurationError.alreadyConfigured == ConfigurationError.alreadyConfigured)
        #expect(ConfigurationError.notConfigured == ConfigurationError.notConfigured)
        #expect(ConfigurationError.invalidAPIKey == ConfigurationError.invalidAPIKey)
        #expect(ConfigurationError.invalidAPISecret == ConfigurationError.invalidAPISecret)
        #expect(ConfigurationError.invalidAppId == ConfigurationError.invalidAppId)

        // Different cases should not be equal
        #expect(ConfigurationError.alreadyConfigured != ConfigurationError.notConfigured)
        #expect(ConfigurationError.invalidAPIKey != ConfigurationError.invalidAPISecret)
        #expect(ConfigurationError.invalidAPISecret != ConfigurationError.invalidAppId)
    }
}
