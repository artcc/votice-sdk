//
//  SuggestionListView.swift
//  Votice
//
//  Created by Arturo Carretero Calvo on 28/6/25.
//  Copyright © 2025 ArtCC. All rights reserved.
//

import SwiftUI

struct SuggestionListView: View {
    // MARK: - Properties

    @Environment(\.dismiss) var dismiss
    @Environment(\.voticeTheme) var theme

    @StateObject var viewModel = SuggestionListViewModel()

    @State private var showCreateButton = true

    let isNavigation: Bool

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

private extension SuggestionListView {
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
            .ignoresSafeArea(.all)
            if viewModel.isLoading && viewModel.currentSuggestionsList.isEmpty {
                LoadingView(message: TextManager.shared.texts.loadingSuggestions)
            } else {
                VStack(spacing: 0) {
#if os(iOS)
                    if !viewModel.liquidGlassEnabled {
                        headerView
                    }
#elseif os(macOS)
                    headerView
#endif
                    if viewModel.showCompletedSeparately {
                        if viewModel.liquidGlassEnabled {
#if os(iOS)
                            tabView
#else
                            segmentedControl
                            standardContentView
#endif
                        } else {
                            segmentedControl
                            standardContentView
                        }
                    } else {
                        standardContentView
                    }
                }
                floatingActionButton
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
            await viewModel.loadSuggestions()
        }
        .voticeAlert(
            isPresented: $viewModel.isShowingAlert,
            alert: viewModel.currentAlert ?? VoticeAlertEntity.error(message: TextManager.shared.texts.genericError)
        )
        .sheet(isPresented: $viewModel.showingCreateSuggestion) {
            NavigationStack {
                CreateSuggestionView { suggestion in
                    viewModel.addSuggestion(suggestion)
                }
#if os(macOS)
                .frame(width: ConfigurationManager.shared.width, height: ConfigurationManager.shared.height)
#endif
            }
        }
        .sheet(item: $viewModel.selectedSuggestion) { suggestion in
            NavigationStack {
                SuggestionDetailView(suggestion: suggestion) { updatedSuggestion in
                    viewModel.updateSuggestion(updatedSuggestion)
                } onReload: {
                    Task {
                        await viewModel.loadSuggestions()
                    }
                }
#if os(macOS)
                .frame(width: ConfigurationManager.shared.width, height: ConfigurationManager.shared.height)
#endif
            }
        }
    }

    var headerView: some View {
        ZStack {
            HStack {
                CloseButton(isNavigation: isNavigation, useLiquidGlass: viewModel.liquidGlassEnabled) {
                    dismiss()
                }
                Spacer()
                if viewModel.selectedTab == 0 {
                    filterMenuButton
                }
            }
            HStack {
                Spacer()
                Text(TextManager.shared.texts.featureRequests)
                    .font(theme.typography.title3)
                    .fontWeight(.regular)
                    .foregroundColor(theme.colors.onBackground)
                Spacer()
            }
        }
        .padding(theme.spacing.md)
        .background(
            theme.colors.background
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
        .zIndex(1)
    }

#if os(iOS)
    var headerGlassView: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarLeading) {
                CloseButton(isNavigation: isNavigation, useLiquidGlass: viewModel.liquidGlassEnabled) {
                    dismiss()
                }
            }
            ToolbarItem(placement: .principal) {
                Text(TextManager.shared.texts.featureRequests)
                    .font(theme.typography.title3)
                    .fontWeight(.regular)
                    .foregroundColor(theme.colors.onBackground)
            }
            if viewModel.selectedTab == 0 {
                ToolbarItem(placement: .navigationBarTrailing) {
                    filterMenuButton
                }
            }
        }
    }
#endif

    var filterMenuButton: some View {
        FilterMenuView(
            isExpanded: $viewModel.isFilterMenuExpanded,
            selectedFilter: viewModel.selectedFilter,
            useLiquidGlass: viewModel.liquidGlassEnabled
        ) { filter in
            viewModel.setFilter(filter)
        }
    }

    var segmentedControl: some View {
        SegmentedControl(
            selection: $viewModel.selectedTab,
            segments: [
                .init(id: 0, title: TextManager.shared.texts.activeTab),
                .init(id: 1, title: TextManager.shared.texts.completedTab)
            ]
        )
        .animation(.easeInOut, value: viewModel.selectedTab)
    }

    var tabView: some View {
        TabView(selection: $viewModel.selectedTab) {
            VStack {
                standardContentView
            }
            .tabItem {
                Label(TextManager.shared.texts.activeTab, systemImage: "list.bullet")
            }
            .tag(0)
            VStack {
                standardContentView
            }
            .tabItem {
                Label(TextManager.shared.texts.completedTab, systemImage: "checkmark.circle")
            }
            .tag(1)
        }
    }

    @ViewBuilder
    var standardContentView: some View {
        if viewModel.currentSuggestionsList.isEmpty && !viewModel.isLoading {
            EmptyStateView(
                title: viewModel.isShowingFilteredResults ?
                    TextManager.shared.texts.noMatchingSuggestions : TextManager.shared.texts.noSuggestionsYet,
                message: viewModel.isShowingFilteredResults ?
                    TextManager.shared.texts.noMatchingSuggestionsMessage : TextManager.shared.texts.beFirstToSuggest,
                showsCreationHint: !viewModel.isShowingFilteredResults
            )
        } else {
            suggestionsList
        }
    }

    var suggestionsList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: theme.spacing.md) {
                ForEach(Array(viewModel.currentSuggestionsList.enumerated()), id: \.element.id) { index, suggestion in
                    SuggestionCard(
                        suggestion: suggestion,
                        currentVote: viewModel.getCurrentVote(for: suggestion.id),
                        useLiquidGlass: viewModel.liquidGlassEnabled,
                        onVote: { voteType in
                            Task {
                                await viewModel.vote(on: suggestion.id, type: voteType)
                            }
                        },
                        onTap: {
                            viewModel.selectSuggestion(suggestion)
                        }
                    )
                    .onAppear {
                        if index >= viewModel.currentSuggestionsList.count - 3
                            && viewModel.hasMoreSuggestions &&
                            !viewModel.isLoadingPagination {
                            Task {
                                await viewModel.loadMoreSuggestions()
                            }
                        }
                    }
                }
                if viewModel.isLoadingPagination && viewModel.currentSuggestionsList.count > 0 {
                    LoadingPaginationView()
                }
                Spacer()
                    .frame(height: viewModel.liquidGlassEnabled ? 10 : 30)
            }
            .padding(.top, theme.spacing.md)
            .padding(.horizontal, theme.spacing.md)
        }
        .scrollBounceBehavior(.basedOnSize)
        .scrollDismissesKeyboard(.immediately)
        .refreshable {
            await viewModel.refresh()
        }
    }

    var floatingActionButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button {
                    HapticManager.shared.lightImpact()

                    viewModel.presentCreateSuggestionSheet()
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.white)
                        .padding()
                        .adaptiveCircularGlassBackground(
                            useLiquidGlass: viewModel.liquidGlassEnabled,
                            fillColor: theme.colors.primary,
                            shadowColor: .black.opacity(0.1),
                            shadowRadius: 2,
                            shadowX: 0,
                            shadowY: 1,
                            isInteractive: true
                        )
                }
                .scaleEffect(showCreateButton ? 1.0 : 0.9)
                .opacity(showCreateButton ? 1.0 : 0.7)
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: showCreateButton)
                .buttonStyle(.plain)
            }
            .padding(.trailing, theme.spacing.md)
#if os(iOS)
            .padding(.bottom, hasNotchOrDynamicIsland ? -10 : theme.spacing.lg)
#elseif os(macOS)
            .padding(.bottom, theme.spacing.md)
#endif
        }
    }
}
