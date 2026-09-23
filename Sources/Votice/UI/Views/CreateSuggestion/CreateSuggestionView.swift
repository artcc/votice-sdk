//
//  CreateSuggestionView.swift
//  Votice
//
//  Created by Arturo Carretero Calvo on 28/6/25.
//  Copyright © 2025 ArtCC. All rights reserved.
//

#if os(iOS)
import PhotosUI
#endif
import SwiftUI

struct CreateSuggestionView: View {
    // MARK: - Properties

    @Environment(\.dismiss) private var dismiss
    @Environment(\.voticeTheme) private var theme

    @StateObject var viewModel = CreateSuggestionViewModel()

#if os(iOS)
    @State private var selectedPhotoItem: PhotosPickerItem?
#endif

    @FocusState private var focusedField: Field?

    private enum Field {
        case title, description, nickname
    }

    let onSuggestionCreated: (SuggestionEntity) -> Void

    // MARK: - View

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    theme.colors.background,
                    theme.colors.background.opacity(0.95)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            if viewModel.isSubmitting {
                LoadingView(message: TextManager.shared.texts.submit)
            } else {
                VStack(spacing: 0) {
#if os(iOS)
                    if !viewModel.liquidGlassEnabled {
                        headerView
                    }
#elseif os(macOS)
                    headerView
#endif
                    mainContent
                }
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
        .voticeAlert(
            isPresented: $viewModel.isShowingAlert,
            alert: viewModel.currentAlert ?? VoticeAlertEntity.error(message: TextManager.shared.texts.genericError)
        )
    }
}

// MARK: - Private

private extension CreateSuggestionView {
    var headerView: some View {
        ZStack {
            HStack {
                closeButton
                Spacer()
                submitButton
            }
            HStack(alignment: .center) {
                Spacer()
                title
                Spacer()
            }
        }
        .padding(theme.spacing.md)
        .background(
            theme.colors.background
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }

#if os(iOS)
    var headerGlassView: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarLeading) {
                closeButton
            }
            ToolbarItem(placement: .principal) {
                title
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                submitButton
            }
        }
    }
#endif

    var closeButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(theme.colors.secondary)
                .padding(8)
                .background(
                    Circle()
                        .fill(viewModel.liquidGlassEnabled ? .clear : theme.colors.secondary.opacity(0.1))
                )
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    var title: some View {
        Text(viewModel.isIssue ? TextManager.shared.texts.reportIssue : TextManager.shared.texts.newSuggestion)
            .font(theme.typography.headline)
            .fontWeight(.medium)
            .foregroundColor(theme.colors.onBackground)
    }

    var submitButton: some View {
        Button {
            HapticManager.shared.mediumImpact()

            Task {
                await viewModel.submitSuggestion { suggestion in
                    HapticManager.shared.success()

                    onSuggestionCreated(suggestion)

                    dismiss()
                }
            }
        } label: {
            Image(systemName: "paperplane.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(submitButtonForegroundColor)
                .padding(8)
                .background(
                    Circle()
                        .fill(
                            viewModel.liquidGlassEnabled ? .clear : viewModel.isFormValid && !viewModel.isSubmitting
                            ? theme.colors.primary
                            : theme.colors.secondary.opacity(0.1)
                        )
                )
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(Rectangle())
        }
        .disabled(!viewModel.isFormValid || viewModel.isSubmitting)
        .buttonStyle(.plain)
    }

    var submitButtonForegroundColor: Color {
        if viewModel.liquidGlassEnabled {
            if viewModel.isFormValid && !viewModel.isSubmitting {
                return theme.colors.primary
            } else {
                return theme.colors.secondary
            }
        } else {
            if viewModel.isFormValid && !viewModel.isSubmitting {
                return .white
            } else {
                return theme.colors.secondary
            }
        }
    }

    var mainContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: theme.spacing.lg) {
                headerCard
                formCard
                Spacer(minLength: theme.spacing.md)
            }
            .padding(theme.spacing.md)
        }
        .scrollBounceBehavior(.basedOnSize)
        .scrollDismissesKeyboard(.immediately)
    }

    var headerCard: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            HStack {
                ZStack {
                    Circle()
                        .fill(theme.colors.primary.opacity(0.1))
                        .frame(width: 44, height: 44)
                    Image(systemName: viewModel.isIssue ? "exclamationmark.triangle.fill" : "lightbulb.fill")
                        .font(.system(size: 20))
                        .foregroundColor(viewModel.isIssue ? theme.colors.warning : theme.colors.primary)
                }
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    Text(
                        viewModel.isIssue ?
                        TextManager.shared.texts.reportIssue : TextManager.shared.texts.shareYourIdea
                    )
                    .font(theme.typography.headline)
                    .foregroundColor(theme.colors.onSurface)
                    Text(
                        viewModel.isIssue ?
                        TextManager.shared.texts.reportIssueSubtitle : TextManager.shared.texts.helpUsImprove
                    )
                    .font(theme.typography.callout)
                    .foregroundColor(theme.colors.secondary)
                }

                Spacer()
            }
        }
        .padding(theme.spacing.md)
        .background(
            RoundedRectangle(cornerRadius: theme.cornerRadius.lg)
                .fill(theme.colors.surface)
                .shadow(color: .black.opacity(0.04), radius: 3, x: 0, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.cornerRadius.lg)
                .stroke(theme.colors.secondary.opacity(0.1), lineWidth: 1)
        )
    }

    var formCard: some View {
        VStack(alignment: .leading, spacing: theme.spacing.lg) {
            titleSection
            descriptionSection
            nicknameSection
            issueSection
        }
        .padding(theme.spacing.md)
        .background(
            RoundedRectangle(cornerRadius: theme.cornerRadius.lg)
                .fill(theme.colors.surface)
                .shadow(color: .black.opacity(0.04), radius: 3, x: 0, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.cornerRadius.lg)
                .stroke(theme.colors.secondary.opacity(0.1), lineWidth: 1)
        )
    }

    var titleSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack {
                Image(systemName: "text.alignleft")
                    .foregroundColor(theme.colors.primary)
                    .font(.headline)
                Text(TextManager.shared.texts.title)
                    .font(theme.typography.headline)
                    .foregroundColor(theme.colors.onSurface)
            }
            TextField(
                viewModel.isIssue ?
                TextManager.shared.texts.titleIssuePlaceholder : TextManager.shared.texts.titlePlaceholder,
                text: $viewModel.title
            )
            .textFieldStyle(VoticeTextFieldStyle())
            .focused($focusedField, equals: .title)
            .onAppear {
                focusedField = .title
            }
            HStack {
                Image(systemName: "info.circle")
                    .foregroundColor(theme.colors.secondary)
                    .font(.caption)
                Text(TextManager.shared.texts.keepItShort)
                    .font(theme.typography.caption)
                    .foregroundColor(theme.colors.secondary)
            }
        }
    }

    var descriptionSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack {
                Image(systemName: "text.alignleft")
                    .foregroundColor(theme.colors.accent)
                    .font(.headline)
                Text(TextManager.shared.texts.descriptionOptional)
                    .font(theme.typography.headline)
                    .foregroundColor(theme.colors.onSurface)
                Spacer()
                Text(TextManager.shared.texts.optional)
                    .font(theme.typography.caption)
                    .foregroundColor(theme.colors.secondary.opacity(0.7))
                    .padding(.horizontal, theme.spacing.sm)
                    .padding(.vertical, theme.spacing.xs)
                    .background(theme.colors.secondary.opacity(0.1))
                    .cornerRadius(theme.cornerRadius.sm)
            }
            TextField(
                viewModel.isIssue ?
                TextManager.shared.texts.descriptionIssuePlaceholder : TextManager.shared.texts.descriptionPlaceholder,
                text: $viewModel.description,
                axis: .vertical
            )
            .textFieldStyle(VoticeTextFieldStyle())
            .lineLimit(3...8)
            .focused($focusedField, equals: .description)
            if !viewModel.isIssue {
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundColor(theme.colors.secondary)
                        .font(.caption)
                    Text(TextManager.shared.texts.explainWhyUseful)
                        .font(theme.typography.caption)
                        .foregroundColor(theme.colors.secondary)
                }
            }
        }
    }

    var issueSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            Toggle(isOn: $viewModel.isIssue) {
                HStack(spacing: theme.spacing.sm) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(theme.colors.warning)
                        .font(.headline)
                    Text(TextManager.shared.texts.reportIssue)
                        .font(theme.typography.headline)
                        .foregroundColor(theme.colors.onSurface)
                }
            }
#if os(iOS) || os(macOS)
            .toggleStyle(SwitchToggleStyle(tint: theme.colors.primary))
#endif
            if viewModel.isIssue {
#if os(iOS)
                photosPicker
#elseif os(macOS)
                VStack {
                    if let imageData = viewModel.issueImageData, let nsImage = NSImage(data: imageData) {
                        Image(nsImage: nsImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.sm))
                            .overlay(
                                RoundedRectangle(cornerRadius: theme.cornerRadius.sm)
                                    .stroke(theme.colors.primary.opacity(0.3), lineWidth: 1)
                            )
                            .overlay(alignment: .topTrailing) {
                                Button {
                                    viewModel.issueImageData = nil
                                } label: {
                                    Image(systemName: "trash.circle.fill")
                                        .font(.system(size: 25, weight: .semibold))
                                        .foregroundColor(theme.colors.error)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .offset(x: 7.5, y: -6.5)
                            }
                    } else {
                        createMacOSImageSelector()
                    }
                }
                .padding(.vertical, theme.spacing.sm)
#endif
            }
        }
    }

#if os(iOS)
    var photosPicker: some View {
        PhotosPicker(selection: $selectedPhotoItem, matching: .images) { [imageData = viewModel.issueImageData] in
            HStack {
                Image(systemName: "paperclip")
                    .foregroundColor(theme.colors.primary)
                Text(TextManager.shared.texts.attachImage)
                    .font(theme.typography.callout)
                    .foregroundColor(theme.colors.onSurface)
                Spacer()
                if let imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.sm))
                        .overlay(
                            RoundedRectangle(cornerRadius: theme.cornerRadius.sm)
                                .stroke(theme.colors.primary.opacity(0.3), lineWidth: 1)
                        )
                }
            }
            .padding(.vertical, theme.spacing.sm)
            .padding(.horizontal, theme.spacing.md)
            .background(theme.colors.primary.opacity(0.08))
            .cornerRadius(theme.cornerRadius.sm)
        }
        .onChange(of: selectedPhotoItem) { _, newValue in
            guard let newValue else {
                return
            }

            Task {
                if let data = try? await newValue.loadTransferable(type: Data.self),
                   let imageData = compressImageData(data) {
                    viewModel.setIssueImage(imageData)
                }
            }
        }
    }
#endif

    var nicknameSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack {
                Image(systemName: "person.circle")
                    .foregroundColor(theme.colors.secondary)
                    .font(.headline)
                Text(TextManager.shared.texts.yourNameOptionalCreate)
                    .font(theme.typography.headline)
                    .foregroundColor(theme.colors.onSurface)
                Spacer()
                Text(TextManager.shared.texts.optional)
                    .font(theme.typography.caption)
                    .foregroundColor(theme.colors.secondary.opacity(0.7))
                    .padding(.horizontal, theme.spacing.sm)
                    .padding(.vertical, theme.spacing.xs)
                    .background(theme.colors.secondary.opacity(0.1))
                    .cornerRadius(theme.cornerRadius.sm)
            }
            TextField(TextManager.shared.texts.enterYourNameCreate, text: $viewModel.nickname)
                .textFieldStyle(VoticeTextFieldStyle())
                .focused($focusedField, equals: .nickname)
            HStack {
                Image(systemName: "eye.slash")
                    .foregroundColor(theme.colors.secondary)
                    .font(.caption)
                Text(TextManager.shared.texts.leaveEmptyAnonymous)
                    .font(theme.typography.caption)
                    .foregroundColor(theme.colors.secondary)
            }
        }
    }
}

private extension CreateSuggestionView {
#if os(macOS)
    func createMacOSImageSelector() -> some View {
        VStack(spacing: 15) {
            RoundedRectangle(cornerRadius: theme.cornerRadius.md)
                .stroke(theme.colors.primary.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [5]))
                .frame(height: 100)
                .overlay(
                    VStack(spacing: 10) {
                        Image(systemName: "arrow.down.circle")
                            .font(.system(size: 24))
                            .foregroundColor(theme.colors.primary)
                        Text(TextManager.shared.texts.dragAndDropImage)
                            .font(theme.typography.callout)
                            .foregroundColor(.secondary)
                    }
                )
                .onDrop(of: ["public.image"], isTargeted: nil) { providers in
                    handleImageDrop(providers: providers)
                }
            Text(TextManager.shared.texts.or)
                .font(theme.typography.callout)
                .foregroundColor(.secondary)
            Button {
                openImagePicker()
            } label: {
                HStack {
                    Image(systemName: "photo")
                    Text(TextManager.shared.texts.attachImage)
                        .font(theme.typography.callout)
                }
                .foregroundColor(theme.colors.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(theme.colors.primary.opacity(0.08))
                .cornerRadius(theme.cornerRadius.md)
            }
            .buttonStyle(.plain)
        }
    }
#endif
}
