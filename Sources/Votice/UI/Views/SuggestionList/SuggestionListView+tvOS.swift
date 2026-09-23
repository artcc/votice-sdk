//
//  SuggestionListView+tvOS.swift
//  Votice
//
//  Created by Arturo Carretero Calvo on 28/10/25.
//  Copyright © 2025 ArtCC. All rights reserved.
//

import SwiftUI

// MARK: - tvOS

#if os(tvOS)
extension SuggestionListView {
    var tvOSView: some View {
        VStack(spacing: 10) {
            if viewModel.isLoading && viewModel.currentSuggestionsList.isEmpty {
                LoadingView(message: TextManager.shared.texts.loadingSuggestions)
            } else {
                tvOSHeaderView
                if viewModel.showCompletedSeparately {
                    tvOSSegmentedControl
                }
                if viewModel.currentSuggestionsList.isEmpty && !viewModel.isLoading {
                    let title = viewModel.isShowingFilteredResults ?
                    TextManager.shared.texts.noMatchingSuggestions :
                    TextManager.shared.texts.noSuggestionsYet
                    let message = viewModel.isShowingFilteredResults ?
                    TextManager.shared.texts.noMatchingSuggestionsMessage :
                    TextManager.shared.texts.noSuggestionsMessage
                    EmptyStateView(title: title, message: message, showsCreationHint: false)
                } else {
                    tvOSSuggestionsList
                }
            }
        }
        .frame(width: ConfigurationManager.shared.width, height: ConfigurationManager.shared.height)
        .task {
            await viewModel.loadSuggestions()
        }
        .voticeAlert(
            isPresented: $viewModel.isShowingAlert,
            alert: viewModel.currentAlert ?? VoticeAlertEntity.error(message: TextManager.shared.texts.genericError)
        )
        .sheet(item: $viewModel.selectedSuggestion) { suggestion in
            SuggestionDetailView(suggestion: suggestion) { updatedSuggestion in
                viewModel.updateSuggestion(updatedSuggestion)
            } onReload: {
                Task {
                    await viewModel.loadSuggestions()
                }
            }
        }
    }

    var tvOSHeaderView: some View {
        HStack {
            Text(TextManager.shared.texts.featureRequests)
                .font(theme.typography.title3)
                .fontWeight(.regular)
                .foregroundColor(theme.colors.onBackground)
            Spacer()
            if !viewModel.showCompletedSeparately {
                FilterMenuView(
                    isExpanded: $viewModel.isFilterMenuExpanded,
                    selectedFilter: viewModel.selectedFilter,
                    useLiquidGlass: viewModel.liquidGlassEnabled
                ) { status in
                    viewModel.setFilter(status)
                }
            }
        }
        .padding(theme.spacing.llg)
        .zIndex(1)
    }

    var tvOSSegmentedControl: some View {
        SegmentedControl(
            selection: $viewModel.selectedTab,
            segments: [
                .init(id: 0, title: TextManager.shared.texts.activeTab),
                .init(id: 1, title: TextManager.shared.texts.completedTab)
            ]
        )
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    var tvOSSuggestionsList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 20) {
                ForEach(Array(viewModel.currentSuggestionsList.enumerated()), id: \.element.id) { index, suggestion in
                    Button {
                        viewModel.selectSuggestion(suggestion)
                    } label: {
                        TVOSSuggestionCard(
                            suggestion: suggestion,
                            currentVote: viewModel.getCurrentVote(for: suggestion.id),
                            useLiquidGlass: viewModel.liquidGlassEnabled
                        )
                    }
                    .buttonStyle(.card)
                    .padding(.top, index == 0 ? 30 : 0)
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
                    .frame(height: 15)
            }
            .padding(.horizontal, theme.spacing.llg)
        }
    }
}
#endif
