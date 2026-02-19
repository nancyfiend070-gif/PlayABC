//
//  ContentView.swift
//  PlayABC
//
//  Created by Uday on 19/02/26.
//

import SwiftUI

/// Small wrapper view that hosts navigation and the main home screen.
struct ContentView: View {
    /// Controls whether the Learn ABC (letter PageView) screen is visible.
    @State private var isShowingLearnABC: Bool = false

    /// Controls whether the games menu is visible.
    @State private var isShowingGameMenu: Bool = false

    /// Which game is currently shown (set from game menu).
    @State private var selectedGameType: GameType?
    /// Presents the in-app privacy policy (required for App Store).
    @State private var showPrivacyPolicy = false

    var body: some View {
        NavigationStack {
            HomeView(
                onLearnABCTapped: {
                    var t = Transaction()
                    t.disablesAnimations = true
                    withTransaction(t) { isShowingLearnABC = true }
                },
                onPlayGames: { isShowingGameMenu = true },
                onPrivacyTapped: { showPrivacyPolicy = true }
            )
            .navigationDestination(isPresented: $isShowingLearnABC) {
                LearnABCView()
                    .transaction { $0.disablesAnimations = true }
            }
            .navigationDestination(isPresented: $isShowingGameMenu) {
                GameMenuView(selectedGameType: $selectedGameType, onBack: { isShowingGameMenu = false })
            }
        }
        .onAppear {
            SoundManager.shared.startBackgroundMusic()
        }
        .onDisappear {
            SoundManager.shared.stopBackgroundMusic()
        }
        .dynamicTypeSize(.xSmall ... .accessibility1)
        .sheet(isPresented: $showPrivacyPolicy) {
            PrivacyPolicyView(onDismiss: { showPrivacyPolicy = false })
        }
    }
}

#Preview {
    ContentView()
}
