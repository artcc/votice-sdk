//
//  VotingButtons.swift
//  Votice
//
//  Created by Arturo Carretero Calvo on 28/6/25.
//  Copyright © 2025 ArtCC. All rights reserved.
//

import SwiftUI

struct VotingButtons: View {
    // MARK: - Properties

    @State private var isAnimating = false
    @State private var showHeartAnimation = false

    @Environment(\.voticeTheme) private var theme

    private var hasVoted: Bool {
        currentVote != nil
    }
    private var voteColor: Color {
        hasVoted ? theme.colors.primary : theme.colors.secondary.opacity(0.6)
    }

    let upvotes: Int
    let downvotes: Int
    let currentVote: VoteType?
    let onVote: (VoteType) -> Void

    // MARK: - View

    var body: some View {
        VStack(spacing: theme.spacing.xs) {
            Button(action: handleVote) {
                VStack(spacing: 4) {
                    ZStack {
                        Image(systemName: hasVoted ? "hand.thumbsup.fill" : "hand.thumbsup")
                            .font(.title2)
                            .foregroundColor(voteColor)
                            .scaleEffect(isAnimating ? 1.3 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isAnimating)
                        if showHeartAnimation {
                            Image(systemName: "heart.fill")
                                .font(.caption)
                                .foregroundColor(theme.colors.error)
                                .offset(y: -20)
                                .opacity(showHeartAnimation ? 0 : 1)
                                .scaleEffect(showHeartAnimation ? 1.5 : 0.5)
                                .animation(.easeOut(duration: 0.8), value: showHeartAnimation)
                        }
                    }
                    Text("\(upvotes)")
                        .font(theme.typography.caption)
                        .foregroundColor(voteColor)
                        .fontWeight(hasVoted ? .semibold : .regular)
                }
                .frame(minWidth: 44, minHeight: 44)
            }
            .buttonStyle(.plain)
            .scaleEffect(isAnimating ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isAnimating)
        }
        .frame(minWidth: 44, minHeight: 44)
    }
}

// MARK: - Private

private extension VotingButtons {
    func handleVote() {
        withAnimation(.easeInOut(duration: 0.1)) {
            isAnimating = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 0.1)) {
                isAnimating = false
            }
        }

        if hasVoted {
            onVote(currentVote!)
        } else {
            onVote(.upvote)

            withAnimation(.easeOut(duration: 0.8)) {
                showHeartAnimation = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                showHeartAnimation = false
            }
        }
    }
}
