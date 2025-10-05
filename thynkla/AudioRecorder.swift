import Combine
//
//  AudioRecorder.swift
//  thynkla
//
//  Created by AI on 04.10.2025.
//

import Foundation

public extension Notification.Name {
    static let recordingSaved = Notification.Name("RecordingSaved")
}

#if os(macOS)
import Combine

final class AudioRecorder: ObservableObject {
    @Published var isRecording: Bool = false

    func startRecording() {
        isRecording = true
    }

    func stopRecording() {
        isRecording = false
        // No-op on macOS stub
    }
}

#else
import AVFAudio

final class AudioRecorder: ObservableObject {
    @Published var isRecording: Bool = false

    private var audioRecorder: AVAudioRecorder?

    func startRecording() {
        AVAudioApplication.requestRecordPermission { [weak self] granted in
            DispatchQueue.main.async {
                guard granted else { return }
                self?.beginRecording()
            }
        }
    }

    private func beginRecording() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true, options: [])

            let url = Self.generateRecordingURL()
            let settings: [String: Any] = [
                AVFormatIDKey: kAudioFormatMPEG4AAC,
                AVSampleRateKey: 44_100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]

            let recorder = try AVAudioRecorder(url: url, settings: settings)
            recorder.prepareToRecord()
            recorder.record()

            self.audioRecorder = recorder
            self.isRecording = true
        } catch {
            self.isRecording = false
        }
    }

    func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        isRecording = false

        do {
            try AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
        } catch { }

        NotificationCenter.default.post(name: .recordingSaved, object: nil)
    }

    private static func generateRecordingURL() -> URL {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        let fileName = "Recording_\(formatter.string(from: Date())).m4a"
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docs.appendingPathComponent(fileName)
    }
}
#endif



