//
//  RecordingDetailView.swift
//  thynkla
//
//  Created by AI on 04.10.2025.
//

import SwiftUI
import AVFAudio
import Combine

struct RecordingDetailView: View {
    let recording: Recording

    @StateObject private var transcriber = SpeechTranscriber()
    @State private var player: AVAudioPlayer?
    @State private var isPlaying: Bool = false

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
            transcriber.transcribe(url: recording.url)
        }
        .onDisappear {
            stopPlayback()
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

