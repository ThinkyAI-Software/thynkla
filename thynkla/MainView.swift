//
//  MainView.swift
//  thynkla
//
//  Created by AI on 04.10.2025.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var recorder: AudioRecorder

    var body: some View {
        VStack(spacing: 24) {
            Text("Talk to capture a thought")
                .font(.headline)

            Button(action: toggleRecording) {
                Text(recorder.isRecording ? "Stop" : "Talk")
                    .font(.title2)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(recorder.isRecording ? Color.red : Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)

            if recorder.isRecording {
                Text("Recording…")
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Thynkla")
    }

    private func toggleRecording() {
        if recorder.isRecording {
            recorder.stopRecording()
        } else {
            recorder.startRecording()
        }
    }
}

#Preview {
    MainView()
        .environmentObject(AudioRecorder())
}


