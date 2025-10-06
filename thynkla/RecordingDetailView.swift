//
//  RecordingDetailView.swift
//  thynkla
//
//  Created by AI on 04.10.2025.
//

import SwiftUI
import AVFAudio
import Combine
import CoreData

struct RecordingDetailView: View {
    let recording: Recording

    @StateObject private var transcriber = SpeechTranscriber()
    @State private var player: AVAudioPlayer?
    @State private var isPlaying: Bool = false
    @Environment(\.managedObjectContext) private var context
    private var entryRepo: EntryRepository { EntryRepository(context: context) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(recording.fileName)
                            .font(.headline)
                            .lineLimit(2)
                        Text(recording.createdAt, format: .dateTime)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button(action: togglePlayback) {
                        Image(systemName: isPlaying ? "stop.circle.fill" : "play.circle.fill")
                            .font(.largeTitle)
                    }
                    .buttonStyle(.plain)
                }

                GroupBox("Transcription") {
                    if transcriber.isTranscribing {
                        ProgressView("Transcribing…")
                            .progressViewStyle(.circular)
                    } else if transcriber.transcript.isEmpty {
                        Text("No transcription yet.")
                            .foregroundStyle(.secondary)
                    } else {
                        Text(transcriber.transcript)
                            .textSelection(.enabled)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Record")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            transcriber.requestAuthorization()
            // Try to load cached transcript first
            if let cached = try? entryRepo.fetchTranscript(audioFileName: recording.url.lastPathComponent), !cached.isEmpty {
                transcriber.transcript = cached
            } else {
                transcriber.transcribe(url: recording.url)
            }
        }
        .onDisappear {
            stopPlayback()
        }
        .onReceive(transcriber.$transcript.dropFirst().debounce(for: .seconds(0.8), scheduler: RunLoop.main)) { text in
            guard !text.isEmpty else { return }
            let meta = TranscriptMeta(localeIdentifier: Locale.current.identifier, recognizer: "SFSpeechRecognizer", modelVersion: nil, duration: nil)
            if let entry = try? entryRepo.upsertEntry(audioFileName: recording.url.lastPathComponent, createdAt: recording.createdAt, rawText: text, meta: meta) {
                // Index chunks and embeddings
                let indexer = ChunkIndexer(context: context)
                try? indexer.index(entry: entry, text: text)
            }
        }
    }

    private func togglePlayback() {
        if isPlaying {
            stopPlayback()
        } else {
            play()
        }
    }

    private func play() {
        do {
            player = try AVAudioPlayer(contentsOf: recording.url)
            isPlaying = true
            player?.play()
        } catch {
            isPlaying = false
            player = nil
        }
    }

    private func stopPlayback() {
        player?.stop()
        player = nil
        isPlaying = false
    }
}

#Preview {
    let sample = Recording(id: UUID(), url: URL(fileURLWithPath: "/dev/null"), createdAt: Date())
    RecordingDetailView(recording: sample)
}

