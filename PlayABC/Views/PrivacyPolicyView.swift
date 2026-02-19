//
//  PrivacyPolicyView.swift
//  PlayABC
//

import SwiftUI

/// Displays the app's privacy policy. Required to be accessible from within the app for App Store compliance.
struct PrivacyPolicyView: View {
    var onDismiss: (() -> Void)?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Layout.spacingL) {
                    Text("Privacy Policy for PlayABC")
                        .font(.system(size: Layout.fontTitle1, weight: .bold, design: .rounded))
                        .foregroundColor(ColorManager.textOnCard())

                    section("Introduction") {
                        "PlayABC is an educational app that helps children learn the alphabet through letters, pictures, and games. This privacy policy explains how we handle information when you use the app."
                    }

                    section("Data We Do Not Collect") {
                        "• No personal information. We do not collect names, emails, or any other information that identifies you or your child.\n\n" +
                        "• No account required. The app does not require sign-in or account creation.\n\n" +
                        "• No usage or analytics data. We do not collect how the app is used or any analytics for tracking.\n\n" +
                        "• No data shared with third parties. We do not send any user data to third parties for advertising or any other purpose."
                    }

                    section("How the App Works") {
                        "All learning content runs on your device. Text-to-speech uses the device's built-in voice and does not send any data to us. The app may play sounds and speak letters and words; no voice or audio is recorded or sent. The app works offline for learning and games."
                    }

                    section("Children's Privacy") {
                        "PlayABC is designed for young children. We do not collect any personal information from anyone, including children. The app does not have user accounts, social features, or advertising."
                    }

                    section("Changes to This Policy") {
                        "We may update this privacy policy from time to time. Continued use of the app after changes means you accept the updated policy."
                    }

                    section("Contact") {
                        "If you have questions about this privacy policy or the app, please contact us via the support link provided in the App Store listing."
                    }
                }
                .padding(Layout.paddingCard)
                .padding(.bottom, Layout.spacingXXL)
            }
            .background(ColorManager.accentWhite)
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        onDismiss?()
                    }
                    .font(.system(size: Layout.fontBody, weight: .semibold, design: .rounded))
                    .foregroundColor(ColorManager.letterSkyBlue)
                }
            }
        }
    }

    private func section(_ title: String, content: () -> String) -> some View {
        VStack(alignment: .leading, spacing: Layout.spacingS) {
            Text(title)
                .font(.system(size: Layout.fontTitle3, weight: .bold, design: .rounded))
                .foregroundColor(ColorManager.textOnCard())

            Text(content())
                .font(.system(size: Layout.fontBody, weight: .regular, design: .rounded))
                .foregroundColor(ColorManager.textSecondaryOnLight)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    PrivacyPolicyView(onDismiss: {})
}
