//
//  thynklaApp.swift
//  thynkla
//
//  Created by Roman Y on 04.10.2025.
//

import SwiftUI
import CoreData

@main
struct thynklaApp: App {
    @StateObject private var recorder = AudioRecorder()
    @StateObject private var store = RecordingsStore()
    private let persistence = PersistenceController.shared
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(recorder)
                .environmentObject(store)
                .environment(\.managedObjectContext, persistence.viewContext)
        }
    }
}
