//
//  thynklaApp.swift
//  thynkla
//
//  Created by Roman Y on 04.10.2025.
//

import SwiftUI

@main
struct thynklaApp: App {
    @StateObject private var recorder = AudioRecorder()
    @StateObject private var store = RecordingsStore()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(recorder)
                .environmentObject(store)
        }
    }
}
