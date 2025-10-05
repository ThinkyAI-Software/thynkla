//
//  SpeechTranscriber.swift
//  thynkla
//
//  Created by AI on 04.10.2025.
//

import Foundation
import Combine

#if canImport(Speech)
import Speech

final class SpeechTranscriber: ObservableObject {
    @Published var transcript: String = ""
    @Published var isTranscribing: Bool = false
    @Published var authorizationStatus: SFSpeechRecognizerAuthorizationStatus = .notDetermined

    private let recognizer: SFSpeechRecognizer?

    init(locale: Locale = Locale.current) {
        recognizer = SFSpeechRecognizer(locale: locale)
    }

    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                self?.authorizationStatus = status
            }
        }
    }

    func transcribe(url: URL) {
        guard let recognizer, recognizer.isAvailable else { return }
        isTranscribing = true
        transcript = ""

        let request = SFSpeechURLRecognitionRequest(url: url)
        request.shouldReportPartialResults = true

        recognizer.recognitionTask(with: request) { [weak self] result, error in
            guard let self else { return }
            if let result {
                self.transcript = result.bestTranscription.formattedString
                if result.isFinal {
                    self.isTranscribing = false
                }
            }
            if error != nil {
                self.isTranscribing = false
            }
        }
    }
}
#else
final class SpeechTranscriber: ObservableObject {
    @Published var transcript: String = ""
    @Published var isTranscribing: Bool = false
    func requestAuthorization() {}
    func transcribe(url: URL) {}
}
#endif



