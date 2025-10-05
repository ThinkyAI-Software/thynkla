//
//  RecordsView.swift
//  thynkla
//
//  Created by AI on 04.10.2025.
//

import SwiftUI
import AVFAudio

struct RecordsView: View {
    @EnvironmentObject var store: RecordingsStore

    @State private var player: AVAudioPlayer?
    @State private var currentlyPlayingId: UUID?

    var body: some View {
        List {
            ForEach(store.recordings) { item in
                NavigationLink(destination: RecordingDetailView(recording: item)) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.fileName)
                                .font(.body)
                                .lineLimit(1)
                            Text(item.createdAt, style: .date)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button(action: { play(item) }) {
                            Image(systemName: currentlyPlayingId == item.id ? "stop.circle" : "play.circle")
                                .font(.title2)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .onDelete(perform: delete)
        }
        .listStyle(.plain)
        .navigationTitle("Records")
        .onDisappear { stopPlayback() }
    }

    private func play(_ recording: Recording) {
        if currentlyPlayingId == recording.id {
            stopPlayback()
            return
        }
        do {
            player = try AVAudioPlayer(contentsOf: recording.url)
            currentlyPlayingId = recording.id
            player?.play()
        } catch {
            currentlyPlayingId = nil
            player = nil
        }
    }

    private func stopPlayback() {
        player?.stop()
        player = nil
        currentlyPlayingId = nil
    }

    private func delete(at offsets: IndexSet) {
        offsets.map { store.recordings[$0] }.forEach(store.delete)
    }
}

#Preview {
    RecordsView()
        .environmentObject(RecordingsStore())
}


