// Sources/EmpSync/Types/SyncableRecord.swift
import CloudKit
import EmpCore
import Foundation

/// Protocol for models that can be synced via CloudKit
public protocol SyncableRecord: EmpModel {
    /// CloudKit record type name
    static var recordType: String { get }

    /// Convert model to CloudKit record
    func toCKRecord() -> CKRecord

    /// Initialize model from CloudKit record
    init(from record: CKRecord) throws
}

/// Errors that can occur during record conversion
public enum SyncRecordError: Error {
    case missingField(String)
    case invalidData(String)
}

// MARK: - Tag + SyncableRecord

extension Tag: SyncableRecord {
    public static var recordType: String {
        "Tag"
    }

    public func toCKRecord() -> CKRecord {
        let recordID = CKRecord.ID(recordName: id.uuidString)
        let record = CKRecord(recordType: Self.recordType, recordID: recordID)

        record["id"] = id.uuidString
        record["createdAt"] = createdAt
        record["updatedAt"] = updatedAt
        record["isDeleted"] = isDeleted
        record["name"] = name
        record["color"] = color

        return record
    }

    public init(from record: CKRecord) throws {
        guard let idString = record["id"] as? String,
              let id = UUID(uuidString: idString)
        else {
            throw SyncRecordError.missingField("id")
        }
        guard let createdAt = record["createdAt"] as? Date else {
            throw SyncRecordError.missingField("createdAt")
        }
        guard let updatedAt = record["updatedAt"] as? Date else {
            throw SyncRecordError.missingField("updatedAt")
        }
        guard let isDeleted = record["isDeleted"] as? Bool else {
            throw SyncRecordError.missingField("isDeleted")
        }
        guard let name = record["name"] as? String else {
            throw SyncRecordError.missingField("name")
        }
        guard let color = record["color"] as? String else {
            throw SyncRecordError.missingField("color")
        }

        self.init(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            name: name,
            color: color,
        )
    }
}

// MARK: - TaskItem + SyncableRecord

extension TaskItem: SyncableRecord {
    public static var recordType: String {
        "TaskItem"
    }

    public func toCKRecord() -> CKRecord {
        let recordID = CKRecord.ID(recordName: id.uuidString)
        let record = CKRecord(recordType: Self.recordType, recordID: recordID)

        record["id"] = id.uuidString
        record["createdAt"] = createdAt
        record["updatedAt"] = updatedAt
        record["isDeleted"] = isDeleted
        record["title"] = title
        record["body"] = body
        record["status"] = status.rawValue
        record["priority"] = priority.rawValue
        record["deadline"] = deadline

        // Encode tags and links as JSON data
        if let tagsData = try? JSONEncoder().encode(tags) {
            record["tags"] = tagsData
        }
        if let linksData = try? JSONEncoder().encode(links) {
            record["links"] = linksData
        }

        return record
    }

    public init(from record: CKRecord) throws {
        guard let idString = record["id"] as? String,
              let id = UUID(uuidString: idString)
        else {
            throw SyncRecordError.missingField("id")
        }
        guard let createdAt = record["createdAt"] as? Date else {
            throw SyncRecordError.missingField("createdAt")
        }
        guard let updatedAt = record["updatedAt"] as? Date else {
            throw SyncRecordError.missingField("updatedAt")
        }
        guard let isDeleted = record["isDeleted"] as? Bool else {
            throw SyncRecordError.missingField("isDeleted")
        }
        guard let title = record["title"] as? String else {
            throw SyncRecordError.missingField("title")
        }
        guard let body = record["body"] as? String else {
            throw SyncRecordError.missingField("body")
        }
        guard let statusRaw = record["status"] as? String,
              let status = TaskStatus(rawValue: statusRaw)
        else {
            throw SyncRecordError.missingField("status")
        }
        guard let priorityRaw = record["priority"] as? Int,
              let priority = TaskPriority(rawValue: priorityRaw)
        else {
            throw SyncRecordError.missingField("priority")
        }

        let deadline = record["deadline"] as? Date

        var tags: [Tag] = []
        if let tagsData = record["tags"] as? Data {
            tags = (try? JSONDecoder().decode([Tag].self, from: tagsData)) ?? []
        }

        var links: [EmpLink] = []
        if let linksData = record["links"] as? Data {
            links = (try? JSONDecoder().decode([EmpLink].self, from: linksData)) ?? []
        }

        self.init(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            title: title,
            body: body,
            status: status,
            priority: priority,
            deadline: deadline,
            tags: tags,
            links: links,
        )
    }
}

// MARK: - DiaryEntry + SyncableRecord

extension DiaryEntry: SyncableRecord {
    public static var recordType: String {
        "DiaryEntry"
    }

    public func toCKRecord() -> CKRecord {
        let recordID = CKRecord.ID(recordName: id.uuidString)
        let record = CKRecord(recordType: Self.recordType, recordID: recordID)

        record["id"] = id.uuidString
        record["createdAt"] = createdAt
        record["updatedAt"] = updatedAt
        record["isDeleted"] = isDeleted
        record["title"] = title

        // Store AttributedString as plain text for CloudKit
        // Full formatting preserved in local storage
        record["body"] = String(body.characters)

        // Encode tags and links as JSON data
        if let tagsData = try? JSONEncoder().encode(tags) {
            record["tags"] = tagsData
        }
        if let linksData = try? JSONEncoder().encode(links) {
            record["links"] = linksData
        }

        return record
    }

    public init(from record: CKRecord) throws {
        guard let idString = record["id"] as? String,
              let id = UUID(uuidString: idString)
        else {
            throw SyncRecordError.missingField("id")
        }
        guard let createdAt = record["createdAt"] as? Date else {
            throw SyncRecordError.missingField("createdAt")
        }
        guard let updatedAt = record["updatedAt"] as? Date else {
            throw SyncRecordError.missingField("updatedAt")
        }
        guard let isDeleted = record["isDeleted"] as? Bool else {
            throw SyncRecordError.missingField("isDeleted")
        }
        guard let title = record["title"] as? String else {
            throw SyncRecordError.missingField("title")
        }
        guard let bodyString = record["body"] as? String else {
            throw SyncRecordError.missingField("body")
        }

        var tags: [Tag] = []
        if let tagsData = record["tags"] as? Data {
            tags = (try? JSONDecoder().decode([Tag].self, from: tagsData)) ?? []
        }

        var links: [EmpLink] = []
        if let linksData = record["links"] as? Data {
            links = (try? JSONDecoder().decode([EmpLink].self, from: linksData)) ?? []
        }

        self.init(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            title: title,
            body: AttributedString(bodyString),
            tags: tags,
            links: links,
        )
    }
}
