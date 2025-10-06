//
//  EntryRepository.swift
//  thynkla
//
//  Created by AI on 04.10.2025.
//

import Foundation
import CoreData

struct TranscriptMeta: Codable {
    var localeIdentifier: String?
    var recognizer: String?
    var modelVersion: String?
    var duration: Double?
}

final class EntryRepository {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.viewContext) {
        self.context = context
    }

    func upsertEntry(audioFileName: String, createdAt: Date, rawText: String, meta: TranscriptMeta?) throws -> EntryMO {
        let request: NSFetchRequest<EntryMO> = EntryMO.fetchRequest()
        request.predicate = NSPredicate(format: "audioFileName == %@", audioFileName)
        request.fetchLimit = 1
        let existing = try context.fetch(request).first

        let entry = existing ?? EntryMO(entity: EntryMO.entity(), insertInto: context)
        if existing == nil { entry.id = UUID() }
        entry.audioFileName = audioFileName
        entry.createdAt = createdAt
        entry.rawText = rawText
        if let meta {
            entry.transcriptMeta = try JSONEncoder().encode(meta)
        }
        try context.save()
        return entry
    }

    func fetchTranscript(audioFileName: String) throws -> String? {
        let request: NSFetchRequest<EntryMO> = EntryMO.fetchRequest()
        request.predicate = NSPredicate(format: "audioFileName == %@", audioFileName)
        request.fetchLimit = 1
        return try context.fetch(request).first?.rawText
    }
}

extension EntryMO {
    @nonobjc class func fetchRequest() -> NSFetchRequest<EntryMO> {
        NSFetchRequest<EntryMO>(entityName: "Entry")
    }
}


