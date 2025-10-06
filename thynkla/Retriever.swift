//
//  Retriever.swift
//  thynkla
//

import Foundation
import CoreData

struct RetrievedChunk: Identifiable {
    let id: UUID
    let entryId: UUID
    let text: String
    let score: Float
}

final class Retriever {
    private let context: NSManagedObjectContext
    private let embeddings: EmbeddingsProvider

    init(context: NSManagedObjectContext = PersistenceController.shared.viewContext,
         embeddings: EmbeddingsProvider = NLEmbeddingsProvider()) {
        self.context = context
        self.embeddings = embeddings
    }

    func topChunks(for query: String, limit: Int = 5) -> [RetrievedChunk] {
        guard let qv = embeddings.embedSentence(query, language: nil), embeddings.dimension > 0 else { return [] }
        let request: NSFetchRequest<ChunkMO> = NSFetchRequest(entityName: "Chunk")
        request.fetchBatchSize = 200
        do {
            let chunks = try context.fetch(request)
            let scored: [RetrievedChunk] = chunks.compactMap { mo in
                if let vector = mo.vector?.toFloatArray(), vector.count == embeddings.dimension {
                    let score = cosineSimilarity(qv, vector)
                    return RetrievedChunk(id: mo.id, entryId: mo.entryId, text: mo.text, score: score)
                } else {
                    // Fallback: score with quick embedding
                    if let tv = embeddings.embedSentence(mo.text, language: nil), tv.count == qv.count {
                        let score = cosineSimilarity(qv, tv)
                        return RetrievedChunk(id: mo.id, entryId: mo.entryId, text: mo.text, score: score)
                    }
                }
                return nil
            }
            return scored.sorted(by: { $0.score > $1.score }).prefix(limit).map { $0 }
        } catch {
            return []
        }
    }
}


