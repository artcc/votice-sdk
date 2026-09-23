//
//  SuggestionListViewModel.swift
//  Votice
//
//  Created by Arturo Carretero Calvo on 28/6/25.
//  Copyright © 2025 ArtCC. All rights reserved.

import Foundation

@MainActor
final class SuggestionListViewModel: ObservableObject {
    // MARK: - Properties

    // Published projections for UI consumption
    @Published var suggestions: [SuggestionEntity] = []
    @Published var completedSuggestions: [SuggestionEntity] = []
    @Published var selectedTab = 0
    @Published var isLoading = true
    @Published var isLoadingPagination = false
    @Published var isFilterMenuExpanded = false
    @Published var selectedFilter: SuggestionStatusEntity?
    @Published var hasMoreSuggestions = true
    @Published var currentVotes: [String: VoteType] = [:]
    @Published var showingCreateSuggestion = false
    @Published var selectedSuggestion: SuggestionEntity?
    @Published var currentAlert: VoticeAlertEntity?
    @Published var isShowingAlert = false

    // Single-feed buffer used when showCompletedSeparately == false
    private var singleFeed: [SuggestionEntity] = []
    // Active feed buffer used when showCompletedSeparately == true
    private var activeFeed: [SuggestionEntity] = []
    // Completed feed buffer used when showCompletedSeparately == true
    private var completedFeed: [SuggestionEntity] = []
    private var loadingTask: Task<Void, Never>?

    private var currentGeneration = 0
    private var hasMoreActive = true
    private var hasMoreCompleted = true

    private let pageSize = 20
    private let suggestionUseCase: SuggestionUseCaseProtocol
    private let versionUseCase: VersionUseCaseProtocol

    var showCompletedSeparately: Bool {
        ConfigurationManager.shared.showCompletedSeparately
    }
    var liquidGlassEnabled: Bool {
        ConfigurationManager.shared.shouldUseLiquidGlass
    }
    var suggestionsIsEmpty: Bool {
        suggestions.isEmpty
    }
    var isShowingFilteredResults: Bool {
        selectedFilter != nil || (showCompletedSeparately && selectedTab != 0)
    }
    var currentSuggestionsList: [SuggestionEntity] {
        if showCompletedSeparately {
            return selectedTab == 0 ? suggestions : completedSuggestions
        } else {
            return suggestions
        }
    }

    // MARK: - Init

    init(suggestionUseCase: SuggestionUseCaseProtocol = SuggestionUseCase(),
         versionUseCase: VersionUseCaseProtocol = VersionUseCase()) {
        self.suggestionUseCase = suggestionUseCase
        self.versionUseCase = versionUseCase

        fetchFilterApplied()
    }

    // MARK: - Functions

    func selectTab(_ tab: Int) {
        selectedTab = tab

        isFilterMenuExpanded = false
    }

    func loadSuggestions() async {
        loadingTask?.cancel()

        isLoading = true
        // Clear projections so loading is visible immediately
        suggestions = []
        completedSuggestions = []

        currentGeneration &+= 1

        let generation = currentGeneration

        isLoadingPagination = false

        loadingTask = Task { @MainActor in
            resetLoadingState()

            do {
                if !showCompletedSeparately {
                    try await fetchSingleFeed(generation: generation)
                } else {
                    try await fetchSeparatedFeeds(generation: generation)
                }

                // Fire-and-forget version reporting
                reportVersionUsage()
            } catch {
                guard !Task.isCancelled else {
                    isLoading = false

                    return
                }

                LogManager.shared.devLog(.error, "SuggestionListViewModel: failed to load suggestions: \(error)")

                showError()
            }

            isLoading = false
        }

        await loadingTask?.value
    }

    func loadMoreSuggestions() async {
        if showCompletedSeparately {
            let isCompletedTab = (selectedTab != 0)

            await paginateSeparatedFeed(isCompletedTab: isCompletedTab)

            return
        }

        await paginateSingleFeed()
    }
}

extension SuggestionListViewModel {
    func refresh() async {
        isFilterMenuExpanded = false

        await loadSuggestions()
    }

    func setFilter(_ status: SuggestionStatusEntity?) {
        do {
            if let status {
                try suggestionUseCase.setFilterApplied(status)

                LogManager.shared.devLog(.info, "SuggestionListViewModel: filter set to \(String(describing: status))")
            } else {
                try suggestionUseCase.clearFilterApplied()

                LogManager.shared.devLog(.info, "SuggestionListViewModel: filter cleared")
            }
        } catch {
            LogManager.shared.devLog(.error, "SuggestionListViewModel: failed to set filter: \(error)")
        }

        selectedFilter = status

        // Force loading state and clear current projections so the UI always shows loading on filter change
        isLoading = true
        isLoadingPagination = false
        suggestions = []

        // Reload suggestions with the new filter.
        Task {
            await loadSuggestions()
        }
    }

    func vote(on suggestionId: String, type: VoteType) async {
        do {
            let hasCurrentVote = currentVotes[suggestionId] != nil
            let voteTypeToSend: VoteType = hasCurrentVote ? .downvote : .upvote
            let response = try await suggestionUseCase.vote(suggestionId: suggestionId, voteType: voteTypeToSend)

            currentVotes[suggestionId] = response.vote != nil ? type : nil

            if let updatedSuggestion = response.suggestion,
               let index = singleFeed.firstIndex(where: { $0.id == suggestionId }) {

                singleFeed[index] = updatedSuggestion

                applyVisibilityFilter()
            }
        } catch {
            LogManager.shared.devLog(.error, "SuggestionListViewModel: failed to vote on \(suggestionId): \(error)")

            showError()
        }
    }

    func addSuggestion(_ suggestion: SuggestionEntity) {
        selectedFilter = nil

        Task {
            await loadSuggestions()
        }
    }

    func updateSuggestion(_ suggestion: SuggestionEntity) {
        if let allIndex = singleFeed.firstIndex(where: { $0.id == suggestion.id }) {
            singleFeed[allIndex] = suggestion
        }

        if let filteredIndex = suggestions.firstIndex(where: { $0.id == suggestion.id }) {
            suggestions[filteredIndex] = suggestion
        }

        if !showCompletedSeparately {
            applyVisibilityFilter()
        }

        Task {
            await loadVoteStatus(for: suggestion.id)
        }
    }

    func getCurrentVote(for suggestionId: String) -> VoteType? {
        currentVotes[suggestionId]
    }

    func presentCreateSuggestionSheet() {
        isFilterMenuExpanded = false

        showingCreateSuggestion = true
    }

    func dismissCreateSuggestionSheet() {
        showingCreateSuggestion = false
    }

    func selectSuggestion(_ suggestion: SuggestionEntity) {
        isFilterMenuExpanded = false

        selectedSuggestion = suggestion
    }

    func deselectSuggestion() {
        selectedSuggestion = nil
    }
}

// MARK: - Private

private extension SuggestionListViewModel {
    func resetLoadingState() {
        isLoading = true
        isLoadingPagination = false
        hasMoreSuggestions = true
    }

    func fetchSingleFeed(generation: Int = 0) async throws {
        let gen = generation == 0 ? currentGeneration : generation
        let pagination = PaginationRequest(startAfter: nil, pageLimit: pageSize)
        let response = try await suggestionUseCase.fetchSuggestions(
            status: selectedFilter,
            excludeCompleted: selectedFilter == nil,
            pagination: pagination
        )

        guard !Task.isCancelled else {
            isLoading = false

            return
        }

        // Drop results if a new load has started
        guard gen == currentGeneration else {
            return
        }

        singleFeed = response.suggestions

        await loadVoteStatusForSuggestions(response.suggestions)

        applyVisibilityFilter()

        hasMoreSuggestions = response.suggestions.count == pageSize
    }

    func fetchSeparatedFeeds(generation: Int = 0) async throws {
        let gen = generation == 0 ? currentGeneration : generation

        // Reset pagination flags for both feeds
        hasMoreActive = true
        hasMoreCompleted = true

        let activePagination = PaginationRequest(startAfter: nil, pageLimit: pageSize)
        let completedPagination = PaginationRequest(startAfter: nil, pageLimit: pageSize)

        async let activeResp = suggestionUseCase.fetchSuggestions(
            status: selectedFilter,
            excludeCompleted: true,
            pagination: activePagination
        )
        async let completedResp = suggestionUseCase.fetchSuggestions(
            status: .some(.completed),
            excludeCompleted: false,
            pagination: completedPagination
        )

        let activeResponse = try await activeResp
        let completedResponse = try await completedResp

        guard !Task.isCancelled else {
            isLoading = false

            return
        }

        // Drop results if a new load has started
        guard gen == currentGeneration else {
            return
        }

        activeFeed = activeResponse.suggestions
        completedFeed = completedResponse.suggestions

        await loadVoteStatusForSuggestions(activeFeed)
        await loadVoteStatusForSuggestions(completedFeed)

        // Projection
        suggestions = activeFeed
        completedSuggestions = completedFeed

        // Update pagination flags
        hasMoreActive = activeFeed.count == pageSize
        hasMoreCompleted = completedFeed.count == pageSize
    }

    func reportVersionUsage() {
        Task.detached { [versionUseCase] in
            do { _ = try await versionUseCase.report() } catch {
                LogManager.shared.devLog(
                    .error,
                    "SuggestionListViewModel: failed to report version usage: \(error)"
                )
            }
        }
    }

    func canPaginate(forCompleted: Bool) -> Bool {
        if forCompleted {
            return !isLoadingPagination && hasMoreCompleted
        } else {
            return !isLoadingPagination && hasMoreActive
        }
    }

    func startAfter(for feed: [SuggestionEntity]) -> StartAfterRequest? {
        guard let last = feed.last, let createdAt = last.createdAt else {
            return nil
        }

        return StartAfterRequest(voteCount: last.voteCount, createdAt: createdAt)
    }

    func paginateSingleFeed() async {
        let generation = currentGeneration

        guard !isLoadingPagination && hasMoreSuggestions else {
            return
        }

        isLoadingPagination = true

        do {
            let pagination = PaginationRequest(startAfter: startAfter(for: singleFeed), pageLimit: pageSize)
            let response = try await suggestionUseCase.fetchSuggestions(
                status: selectedFilter,
                excludeCompleted: selectedFilter == nil,
                pagination: pagination
            )

            guard !Task.isCancelled else {
                isLoadingPagination = false

                return
            }

            // Abort if a new load has started
            guard generation == currentGeneration else {
                isLoadingPagination = false

                return
            }

            singleFeed.append(contentsOf: response.suggestions)

            await loadVoteStatusForSuggestions(response.suggestions)

            applyVisibilityFilter()

            hasMoreSuggestions = response.suggestions.count == pageSize
        } catch {
            guard !Task.isCancelled else {
                isLoadingPagination = false

                return
            }

            LogManager.shared.devLog(.error, "SuggestionListViewModel: failed to load more suggestions: \(error)")

            showError()
        }

        isLoadingPagination = false
    }

    // swiftlint:disable function_body_length
    func paginateSeparatedFeed(isCompletedTab: Bool) async {
        let generation = currentGeneration
        guard canPaginate(forCompleted: isCompletedTab) else {
            return
        }

        isLoadingPagination = true

        do {
            if isCompletedTab {
                let pagination = PaginationRequest(startAfter: startAfter(for: completedFeed), pageLimit: pageSize)
                let response = try await suggestionUseCase.fetchSuggestions(
                    status: .some(.completed),
                    excludeCompleted: false,
                    pagination: pagination
                )

                guard !Task.isCancelled else {
                    isLoadingPagination = false

                    return
                }

                // Abort if a new load has started
                guard generation == currentGeneration else {
                    isLoadingPagination = false

                    return
                }

                completedFeed.append(contentsOf: response.suggestions)

                await loadVoteStatusForSuggestions(response.suggestions)

                completedSuggestions = completedFeed

                hasMoreCompleted = response.suggestions.count == pageSize
            } else {
                let pagination = PaginationRequest(startAfter: startAfter(for: activeFeed), pageLimit: pageSize)
                let response = try await suggestionUseCase.fetchSuggestions(
                    status: selectedFilter,
                    excludeCompleted: true,
                    pagination: pagination
                )

                guard !Task.isCancelled else {
                    isLoadingPagination = false

                    return
                }

                // Abort if a new load has started
                guard generation == currentGeneration else {
                    isLoadingPagination = false

                    return
                }

                activeFeed.append(contentsOf: response.suggestions)

                await loadVoteStatusForSuggestions(response.suggestions)

                suggestions = activeFeed

                hasMoreActive = response.suggestions.count == pageSize
            }
        } catch {
            guard !Task.isCancelled else {
                isLoadingPagination = false

                return
            }

            let scope = isCompletedTab ? "completed" : "active"
            LogManager.shared.devLog(
                .error,
                "SuggestionListViewModel: failed to load more \(scope) suggestions: \(error)"
            )

            showError()
        }

        isLoadingPagination = false
    }
    // swiftlint:enable function_body_length
}

private extension SuggestionListViewModel {
    func fetchFilterApplied() {
        do {
            if let selectedFilter = try suggestionUseCase.fetchFilterApplied() {
                self.selectedFilter = selectedFilter

                LogManager.shared.devLog(
                    .info, "SuggestionListViewModel: fetched applied filter: \(String(describing: selectedFilter))"
                )
            } else {
                LogManager.shared.devLog(.info, "SuggestionListViewModel: no filter applied")
            }
        } catch {
            LogManager.shared.devLog(.error, "SuggestionListViewModel: failed to fetch applied filter: \(error)")
        }
    }

    func applyVisibilityFilter() {
        if showCompletedSeparately {
            // Direct projection from separated feeds
            suggestions = activeFeed
            completedSuggestions = completedFeed

            return
        }

        // Single-feed mode: trust backend filtering when a filter is selected
        if selectedFilter != nil {
            suggestions = singleFeed

            return
        }

        // No filter selected: apply visibility based on configuration
        let visibleOptional = ConfigurationManager.shared.optionalVisibleStatuses
        let mandatory: Set<SuggestionStatusEntity> = [.inProgress, .pending]
        let allowed: Set<SuggestionStatusEntity> = visibleOptional.union(mandatory)

        suggestions = singleFeed.filter { allowed.contains($0.status ?? .pending) }
    }

    func loadVoteStatusForSuggestions(_ suggestions: [SuggestionEntity]) async {
        // Bounded concurrency using a worker pool and an index cursor actor
        actor IndexCursor {
            private var i = 0

            func next(max: Int) -> Int? {
                guard i < max else {
                    return nil
                }

                defer {
                    i += 1
                }

                return i
            }
        }

        let ids = suggestions.map { $0.id }
        let maxWorkers = min(pageSize, max(1, 6))
        let cursor = IndexCursor()

        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<min(maxWorkers, ids.count) {
                group.addTask { [weak self] in
                    while let idx = await cursor.next(max: ids.count) {
                        await self?.loadVoteStatus(for: ids[idx])
                    }
                }
            }

            await group.waitForAll()
        }
    }

    func loadVoteStatus(for suggestionId: String) async {
        do {
            let voteStatus = try await suggestionUseCase.fetchVoteStatus(suggestionId: suggestionId)

            await MainActor.run {
                if voteStatus.hasVoted {
                    currentVotes[suggestionId] = .upvote
                } else {
                    currentVotes.removeValue(forKey: suggestionId)
                }
            }
        } catch {
            LogManager.shared.devLog(
                .error,
                "SuggestionListViewModel: failed to load vote status for \(suggestionId): \(error)"
            )
        }
    }

    func showAlert(_ alert: VoticeAlertEntity) {
        currentAlert = alert

        isShowingAlert = true
    }

    func showError() {
        showAlert(VoticeAlertEntity.error(message: TextManager.shared.texts.genericError))
    }
}
