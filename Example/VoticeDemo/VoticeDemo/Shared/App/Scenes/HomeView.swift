//
//  HomeView.swift
//  VoticeDemo
//
//  Created by Arturo Carretero Calvo on 27/6/25.
//  Copyright © 2025 ArtCC. All rights reserved.
//

import SwiftUI
import VoticeSDK

struct HomeView: View {
    // MARK: - Properties

    @State private var showingFeedbackSheet = false
    @State private var showingFeedbackSheetWithCustomTheme = false
    @State private var isConfigured = false

    // MARK: - View

    var body: some View {
#if os(iOS)
        mobile
#elseif os(macOS)
        desktop
#elseif os(tvOS)
        television
#endif
    }
}

// MARK: - Private

private extension HomeView {
#if os(iOS)
    var mobile: some View {
        NavigationView {
            GeometryReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 30) {
                        HeaderView()
                        Divider()
                        VStack(spacing: 20) {
                            VStack(spacing: 10) {
                                Text("Option 1: Modal Presentation")
                                    .font(.poppins(.semiBold, size: 18))
                                Button {
                                    showingFeedbackSheet = true
                                } label: {
                                    Text("Show Feedback Sheet")
                                        .font(.poppins(.medium, size: 16))
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(.brand)
                                        .cornerRadius(15)
                                }
                            }
                            VStack(spacing: 10) {
                                Text("Option 2: Navigation Push")
                                    .font(.poppins(.semiBold, size: 18))
                                NavigationLink {
                                    Votice.feedbackNavigationView(theme: Votice.systemThemeWithCurrentFonts())
                                } label: {
                                    Text("Navigate to Feedback")
                                        .font(.poppins(.medium, size: 16))
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(.brand)
                                        .cornerRadius(15)
                                }
                            }
                            VStack(spacing: 10) {
                                Text("Option 3: Custom Theme")
                                    .font(.poppins(.semiBold, size: 18))
                                Button {
                                    showingFeedbackSheetWithCustomTheme = true
                                } label: {
                                    Text("Feedback with Custom Theme")
                                        .font(.poppins(.medium, size: 16))
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(.brand)
                                        .cornerRadius(15)
                                }
                            }
                        }
                        Spacer()
                        ReadyView(isConfigured: $isConfigured)
                            .padding(.bottom, 20)
                    }
                    .frame(minHeight: proxy.size.height)
                    .navigationTitle("Votice Demo")
                    .navigationBarTitleDisplayMode(.inline)
                }
                .scrollBounceBehavior(.basedOnSize)
                .scrollDismissesKeyboard(.immediately)
            }
        }
        .onAppear {
            configureVotice()
        }
        .sheet(isPresented: $showingFeedbackSheet) {
            Votice.feedbackView(theme: Votice.systemThemeWithCurrentFonts())
        }
        .sheet(isPresented: $showingFeedbackSheetWithCustomTheme) {
            // Custom theme example
            let colors: VoticeColors = .init(
                primary: .red, // Red
                secondary: Color(red: 0.56, green: 0.56, blue: 0.58), // Modern Gray
                accent: Color(red: 1.0, green: 0.58, blue: 0.0), // Vibrant Orange
                background: Color(UIColor.systemBackground),
                surface: Color(UIColor.secondarySystemBackground),
                onSurface: Color.primary,
                onBackground: Color.primary,
                success: Color(red: 0.20, green: 0.78, blue: 0.35), // Modern Green
                warning: Color(red: 1.0, green: 0.58, blue: 0.0), // Warm Orange
                error: Color(red: 1.0, green: 0.23, blue: 0.19), // Modern Red
                upvote: Color(red: 0.20, green: 0.78, blue: 0.35), // Success Green
                downvote: Color(red: 1.0, green: 0.23, blue: 0.19), // Error Red
                pending: Color(red: 1.0, green: 0.58, blue: 0.0), // Warning Orange
                accepted: Color(red: 0.0, green: 0.48, blue: 1.0), // Primary Blue
                inProgress: Color(red: 0.48, green: 0.40, blue: 0.93), // Modern Purple
                completed: Color(red: 0.20, green: 0.78, blue: 0.35), // Success Green
                rejected: Color(red: 1.0, green: 0.23, blue: 0.19) // Error Red
            )
            let customTheme: VoticeTheme = .init(colors: colors, typography: .withCurrentFonts())

            Votice.feedbackView(theme: customTheme)
        }
    }
#endif

#if os(macOS)
    var desktop: some View {
        VStack(spacing: 30) {
            Spacer()
            HeaderView()
            Divider()
            Button {
                showingFeedbackSheet = true
            } label: {
                Text("Open Feedback")
                    .font(.poppins(.medium, size: 16))
                    .foregroundColor(.white)
                    .padding()
                    .background(.brand)
                    .cornerRadius(15)
            }
            .buttonStyle(.plain)
            Spacer()
            ReadyView(isConfigured: $isConfigured)
                .padding(.bottom, 20)
        }
        .onAppear {
            configureVotice()
        }
        .sheet(isPresented: $showingFeedbackSheet) {
            Votice.feedbackView(theme: Votice.systemThemeWithCurrentFonts())
        }
    }
#endif

#if os(tvOS)
    var television: some View {
        VStack(spacing: 30) {
            Spacer()
            HeaderView()
            Divider()
            Button {
                showingFeedbackSheet = true
            } label: {
                Text("Show Feedback Sheet")
                    .font(.poppins(.medium, size: 16))
                    .foregroundColor(.white)
                    .padding()
                    .background(.brand)
                    .cornerRadius(15)
            }
            .buttonStyle(.card)
            Spacer()
            ReadyView(isConfigured: $isConfigured)
        }
        .onAppear {
            configureVotice()
        }
        .sheet(isPresented: $showingFeedbackSheet) {
            Votice.feedbackView(theme: Votice.systemThemeWithCurrentFonts())
        }
    }
#endif
}

private extension HomeView {
    func configureVotice() {
        do {
            try Votice.configure(
                apiKey: Constants.Votice.apiKey,
                apiSecret: Constants.Votice.apiSecret,
                appId: Constants.Votice.appId
            )

            let customFonts = VoticeFontConfiguration(
                fontFamily: "Poppins",
                weights: [
                    .regular: "Poppins-Regular",
                    .medium: "Poppins-Medium",
                    .semiBold: "Poppins-SemiBold",
                    .bold: "Poppins-Bold"
                ]
            )
            Votice.setTexts(Texts())
            Votice.setFonts(customFonts)
            Votice.setDebugLogging(enabled: true)
            Votice.setCommentIsEnabled(enabled: true)
            Votice.setShowCompletedSeparately(enabled: false)
            Votice.setVisibleOptionalStatuses(accepted: true, blocked: true, rejected: true)
            Votice.setUserIsPremium(isPremium: true)
            Votice.setLiquidGlassEnabled(true)

            isConfigured = Votice.isConfigured

            debugPrint("Votice SDK configured successfully!")
        } catch {
            isConfigured = false

            debugPrint("Configuration failed: \(error)")
        }
    }
}
