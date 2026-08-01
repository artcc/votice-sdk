//
//  ConfigurationManager.swift
//  Votice
//
//  Created by Arturo Carretero Calvo on 28/6/25.
//  Copyright © 2025 ArtCC. All rights reserved.
//

import Foundation

protocol ConfigurationManagerProtocol: Sendable {
    // MARK: - Properties

    var isConfigured: Bool { get }
    var baseURL: String { get }
    var apiKey: String { get }
    var apiSecret: String { get }
    var appId: String { get }
    var commentIsEnabled: Bool { get set }
    var showCompletedSeparately: Bool { get set }
    var useLiquidGlass: Bool { get set }
    var user: UserEntity { get set }
    var optionalVisibleStatuses: Set<SuggestionStatusEntity> { get }
    var version: String { get }
    var buildNumber: String { get }

    // MARK: - Public functions

    func configure(apiKey: String, apiSecret: String, appId: String) throws
    func reset()
    func validateConfiguration() throws
}

final class ConfigurationManager: ConfigurationManagerProtocol, @unchecked Sendable {
    // MARK: - Properties

    static let shared = ConfigurationManager()

    private var _apiKey = ""
    private var _apiSecret = ""
    private var _appId = ""
    private var _isConfigured = false
    private var _commentIsEnabled = true
    private var _showCompletedSeparately = false
    private var _useLiquidGlass = true
    private var _user = UserEntity(isPremium: false)
    private var _optionalVisibleStatuses: Set<SuggestionStatusEntity> = [.accepted, .blocked, .rejected]
    private var _width: CGFloat = 800
    private var _height: CGFloat = 600

    private let lock = NSLock()
    private let _baseURL = "https://api-svdrkzyfhq-uc.a.run.app/api"
    private let _configurationId = UUID().uuidString
    private let _version = "1.0.21"
    private let _buildNumber = "1"

    // MARK: - Public properties

    var isConfigured: Bool {
        lock.withLock { _isConfigured }
    }

    var baseURL: String {
        _baseURL
    }

    var configurationId: String {
        _configurationId
    }

    var apiKey: String {
        lock.withLock { _apiKey }
    }

    var apiSecret: String {
        lock.withLock { _apiSecret }
    }

    var appId: String {
        lock.withLock { _appId }
    }

    var commentIsEnabled: Bool {
        get {
            lock.withLock { _commentIsEnabled }
        }
        set {
            lock.withLock { _commentIsEnabled = newValue }
        }
    }

    var showCompletedSeparately: Bool {
        get {
            lock.withLock { _showCompletedSeparately }
        }
        set {
            lock.withLock { _showCompletedSeparately = newValue }
        }
    }

    var useLiquidGlass: Bool {
        get {
            lock.withLock { _useLiquidGlass }
        }
        set {
            lock.withLock { _useLiquidGlass = newValue }
        }
    }

    var user: UserEntity {
        get {
            lock.withLock { _user }
        }
        set {
            lock.withLock { _user = newValue }
        }
    }

    var optionalVisibleStatuses: Set<SuggestionStatusEntity> {
        lock.withLock {
            _optionalVisibleStatuses
        }
    }

    var width: CGFloat {
        get {
            lock.withLock { _width }
        }
        set {
            lock.withLock { _width = newValue }
        }
    }

    var height: CGFloat {
        get {
            lock.withLock { _height }
        }
        set {
            lock.withLock { _height = newValue }
        }
    }

    var version: String {
        _version
    }

    var buildNumber: String {
        _buildNumber
    }

    /// Shorthand to check if Liquid Glass should be used
    /// Takes into account both the configuration flag and OS availability
    var shouldUseLiquidGlass: Bool {
        if #available(iOS 26.0, macOS 26.0, tvOS 26.0, *) {
#if !os(tvOS)
            return useLiquidGlass
#else
            return false
#endif
        } else {
            return false
        }
    }

    // MARK: - Init

    internal init() {}

    // MARK: - Public functions

    func configure(apiKey: String, apiSecret: String, appId: String) throws {
        try lock.withLock {
            guard !_isConfigured else {
                LogManager.shared.devLog(.warning, "ConfigurationManager: is already configured")

                throw ConfigurationError.alreadyConfigured
            }

            // Validate API key
            guard !apiKey.isEmpty else {
                LogManager.shared.devLog(.error, "ConfigurationManager: invalid API key provided")

                throw ConfigurationError.invalidAPIKey
            }

            // Validate API secret
            guard !apiSecret.isEmpty else {
                LogManager.shared.devLog(.error, "ConfigurationManager: invalid API secret provided")

                throw ConfigurationError.invalidAPISecret
            }

            // Validate app ID
            guard !appId.isEmpty else {
                LogManager.shared.devLog(.error, "ConfigurationManager: invalid app ID provided")

                throw ConfigurationError.invalidAppId
            }

            _apiKey = apiKey
            _apiSecret = apiSecret
            _appId = appId
            _isConfigured = true

            LogManager.shared.devLog(.success, "ConfigurationManager: successfully configured")
        }
    }

    func setOptionalVisibleStatus(accepted: Bool, blocked: Bool, rejected: Bool) {
        var statuses: [SuggestionStatusEntity] = []

        if accepted {
            statuses.append(.accepted)
        }

        if blocked {
            statuses.append(.blocked)
        }

        if rejected {
            statuses.append(.rejected)
        }

        lock.withLock {
            _optionalVisibleStatuses = Set(statuses)
        }

        LogManager.shared.devLog(
            .info,
            "ConfigurationManager: updated optional visible statuses to \(_optionalVisibleStatuses)"
        )
    }

    func reset() {
        lock.withLock {
            _apiKey = ""
            _apiSecret = ""
            _appId = ""
            _isConfigured = false
            _commentIsEnabled = true
            _showCompletedSeparately = false
            _useLiquidGlass = false
            _optionalVisibleStatuses = [.accepted, .blocked, .rejected]
            _width = 800
            _height = 600

            LogManager.shared.devLog(.info, "ConfigurationManager: reset")
        }
    }

    func validateConfiguration() throws {
        guard isConfigured else {
            LogManager.shared.devLog(.error, "ConfigurationManager: is not configured")

            throw ConfigurationError.notConfigured
        }
    }
}
