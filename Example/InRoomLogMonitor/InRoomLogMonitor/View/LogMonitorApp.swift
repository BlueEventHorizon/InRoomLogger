//
//  LogMonitorApp.swift
//  InRoomLogMonitor
//
//  Created by Katsuhiko Terada on 2022/10/26.
//

import SwiftUI

@main
struct LogMonitorApp: App {

// @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject private var nearPeerMonitor: NearPeerMonitor = NearPeerMonitor()
    @StateObject private var appState = AppState.default

    var body: some Scene {
        WindowGroup {
            switch appState.viewState {
                case .splash:
                    SplashView()
                        .environmentObject(appState)

                case .main:
                LogMonitorMainView()
                    .onAppear {
                        nearPeerMonitor.start()
                    }
                    .environmentObject(nearPeerMonitor)
            }
        }
    }
}

