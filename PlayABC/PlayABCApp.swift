//  PlayABCApp.swift
//  PlayABC
//
//  Created by Uday on 19/02/26.
//
import SwiftUI

@main
struct PlayABCApp: App {

    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .background:
                SoundManager.shared.stopBackgroundMusic()

            case .active:
                SoundManager.shared.startBackgroundMusic()

            default:
                break
            }
        }
    }
}
