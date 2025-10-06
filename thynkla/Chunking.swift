//
//  Chunking.swift
//  thynkla
//

import Foundation
import CoreData

final class TranscriptChunker {
    func chunk(text: String, maxChars: Int = 1200, overlap: Int = 200) -> [String] {
        guard !text.isEmpty else { return [] }
        let chars = Array(text)
        var i = 0
        var chunks: [String] = []
        while i < chars.count {
            let end = min(i + maxChars, chars.count)
            let slice = String(chars[i..<end])
            chunks.append(slice)
            if end >= chars.count { break }
            i = max(0, end - overlap)
        }
        return chunks
    }
}

final class ChunkIndexer {
    private let context: NSManagedObjectContext
    private let embeddings: EmbeddingsProvider

    init(context: NSManagedObjectContext = PersistenceController.shared.viewContext,
         embeddings: EmbeddingsProvider = NLEmbeddingsProvider()) {
        self.context = context
        self.embeddings = embeddings
    }

    func index(entry: EntryMO, text: String) throws {
        let chunker = TranscriptChunker()
        let parts = chunker.chunk(text: text)
        for t in parts {
            let mo = ChunkMO(entity: ChunkMO.entity(), insertInto: context)
            mo.id = UUID()
            mo.entryId = entry.id
            mo.text = t
            mo.summary = nil
            mo.tags = nil
            if let v = embeddings.embedSentence(t, language: nil) {
                mo.vector = v.asFloat32Data()
            }
            mo.tokenCount = Int32(t.count)
        }
        try context.save()
    }
}


