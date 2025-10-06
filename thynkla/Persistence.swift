//
//  Persistence.swift
//  thynkla
//
//  Programmatic Core Data stack and model.
//

import Foundation
import CoreData

final class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer
    var viewContext: NSManagedObjectContext { container.viewContext }

    private init() {
        let model = Self.makeModel()
        container = NSPersistentContainer(name: "thynkla", managedObjectModel: model)

        let storeURL: URL = {
            let urls = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
            let dir = urls.first!.appendingPathComponent("thynkla", isDirectory: true)
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            return dir.appendingPathComponent("thynkla.sqlite")
        }()

        let description = NSPersistentStoreDescription(url: storeURL)
        description.type = NSSQLiteStoreType
        description.setOption(FileProtectionType.completeUntilFirstUserAuthentication as NSObject,
                              forKey: NSPersistentStoreFileProtectionKey)
        container.persistentStoreDescriptions = [description]

        container.loadPersistentStores { _, error in
            if let error { fatalError("Unresolved Core Data error: \(error)") }
        }

        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    func saveContext() {
        let context = container.viewContext
        guard context.hasChanges else { return }
        do { try context.save() } catch { print("Core Data save error: \(error)") }
    }

    private static func makeModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        // Entry entity
        let entry = NSEntityDescription()
        entry.name = "Entry"
        entry.managedObjectClassName = String(describing: EntryMO.self)

        let entryId = NSAttributeDescription()
        entryId.name = "id"
        entryId.attributeType = .UUIDAttributeType
        entryId.isOptional = false

        let entryCreatedAt = NSAttributeDescription()
        entryCreatedAt.name = "createdAt"
        entryCreatedAt.attributeType = .dateAttributeType
        entryCreatedAt.isOptional = false

        let entryRawText = NSAttributeDescription()
        entryRawText.name = "rawText"
        entryRawText.attributeType = .stringAttributeType
        entryRawText.isOptional = true
        entryRawText.allowsExternalBinaryDataStorage = false

        let entryTranscriptMeta = NSAttributeDescription()
        entryTranscriptMeta.name = "transcriptMeta"
        entryTranscriptMeta.attributeType = .binaryDataAttributeType
        entryTranscriptMeta.isOptional = true
        entryTranscriptMeta.allowsExternalBinaryDataStorage = true

        let entryAudioFileName = NSAttributeDescription()
        entryAudioFileName.name = "audioFileName"
        entryAudioFileName.attributeType = .stringAttributeType
        entryAudioFileName.isOptional = false

        entry.properties = [entryId, entryCreatedAt, entryRawText, entryTranscriptMeta, entryAudioFileName]

        // Chunk entity
        let chunk = NSEntityDescription()
        chunk.name = "Chunk"
        chunk.managedObjectClassName = String(describing: ChunkMO.self)

        let chunkId = NSAttributeDescription()
        chunkId.name = "id"
        chunkId.attributeType = .UUIDAttributeType
        chunkId.isOptional = false

        let chunkEntryId = NSAttributeDescription()
        chunkEntryId.name = "entryId"
        chunkEntryId.attributeType = .UUIDAttributeType
        chunkEntryId.isOptional = false

        let chunkText = NSAttributeDescription()
        chunkText.name = "text"
        chunkText.attributeType = .stringAttributeType
        chunkText.isOptional = false

        let chunkSummary = NSAttributeDescription()
        chunkSummary.name = "summary"
        chunkSummary.attributeType = .stringAttributeType
        chunkSummary.isOptional = true

        let chunkTags = NSAttributeDescription()
        chunkTags.name = "tags"
        chunkTags.attributeType = .transformableAttributeType
        chunkTags.valueTransformerName = NSValueTransformerName.secureUnarchiveFromDataTransformerName.rawValue
        chunkTags.isOptional = true

        let chunkVector = NSAttributeDescription()
        chunkVector.name = "vector"
        chunkVector.attributeType = .binaryDataAttributeType
        chunkVector.isOptional = true
        chunkVector.allowsExternalBinaryDataStorage = true

        let chunkTokenCount = NSAttributeDescription()
        chunkTokenCount.name = "tokenCount"
        chunkTokenCount.attributeType = .integer32AttributeType
        chunkTokenCount.isOptional = true

        chunk.properties = [chunkId, chunkEntryId, chunkText, chunkSummary, chunkTags, chunkVector, chunkTokenCount]

        // IndexMeta entity
        let meta = NSEntityDescription()
        meta.name = "IndexMeta"
        meta.managedObjectClassName = String(describing: IndexMetaMO.self)

        let metaSchema = NSAttributeDescription()
        metaSchema.name = "schemaVersion"
        metaSchema.attributeType = .integer16AttributeType
        metaSchema.isOptional = false

        let metaLanguage = NSAttributeDescription()
        metaLanguage.name = "language"
        metaLanguage.attributeType = .stringAttributeType
        metaLanguage.isOptional = true

        let metaDim = NSAttributeDescription()
        metaDim.name = "embeddingDim"
        metaDim.attributeType = .integer16AttributeType
        metaDim.isOptional = true

        meta.properties = [metaSchema, metaLanguage, metaDim]

        model.entities = [entry, chunk, meta]
        return model
    }
}

// MARK: - NSManagedObject subclasses

@objc(EntryMO)
final class EntryMO: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var createdAt: Date
    @NSManaged var rawText: String?
    @NSManaged var transcriptMeta: Data?
    @NSManaged var audioFileName: String
}

@objc(ChunkMO)
final class ChunkMO: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var entryId: UUID
    @NSManaged var text: String
    @NSManaged var summary: String?
    @NSManaged var tags: [String]?
    @NSManaged var vector: Data?
    @NSManaged var tokenCount: Int32
}

@objc(IndexMetaMO)
final class IndexMetaMO: NSManagedObject {
    @NSManaged var schemaVersion: Int16
    @NSManaged var language: String?
    @NSManaged var embeddingDim: Int16
}

