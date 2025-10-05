//
//  RecordingsStore.swift
//  thynkla
//
//  Created by AI on 04.10.2025.
//

import Foundation
import Combine

struct Recording: Identifiable, Equatable {
    let id: UUID
    let url: URL
    let createdAt: Date

    var fileName: String { url.lastPathComponent }
}

final class RecordingsStore: ObservableObject {
    @Published private(set) var recordings: [Recording] = []

    init() {
        reload()
        NotificationCenter.default.addObserver(self, selector: #selector(onRecordingSaved), name: .recordingSaved, object: nil)
    }

    @objc private func onRecordingSaved() {
        reload()
    }

    func reload() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        guard let docs else { return }
        do {
            let urls = try FileManager.default.contentsOfDirectory(at: docs, includingPropertiesForKeys: [.creationDateKey], options: [.skipsHiddenFiles])
                .filter { $0.pathExtension.lowercased() == "m4a" }
            let items: [Recording] = urls.compactMap { url in
                let values = try? url.resourceValues(forKeys: [.creationDateKey])
                return Recording(id: UUID(), url: url, createdAt: values?.creationDate ?? Date())
            }
            recordings = items.sorted(by: { $0.createdAt > $1.createdAt })
        } catch {
            recordings = []
        }
    }

    func delete(_ recording: Recording) {
        do {
            try FileManager.default.removeItem(at: recording.url)
            reload()
        } catch { }
    }
}

