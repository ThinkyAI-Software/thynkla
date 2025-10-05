//
//  ContentView.swift
//  thynkla
//
//  Created by Roman Y on 04.10.2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var recorder: AudioRecorder
    @EnvironmentObject var store: RecordingsStore

    var body: some View {
        TabView {
            NavigationStack {
                MainView()
            }
            .tabItem {
                Label("Main", systemImage: "mic.circle")
            }

            NavigationStack {
                RecordsView()
            }
            .tabItem {
                Label("Records", systemImage: "list.bullet")
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AudioRecorder())
        .environmentObject(RecordingsStore())
}
