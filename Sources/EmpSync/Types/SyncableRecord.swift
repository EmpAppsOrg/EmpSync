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

// MARK: - CKRecord Helpers

private extension CKRecord {
    func requiredString(_ key: String) throws -> String {
        guard let value = self[key] as? String else {
            throw SyncRecordError.missingField(key)
        }
        return value
    }

    func requiredUUID(_ key: String) throws -> UUID {
        let string = try requiredString(key)
        guard let uuid = UUID(uuidString: string) else {
            throw SyncRecordError.invalidData(key)
        }
        return uuid
    }

    func requiredDate(_ key: String) throws -> Date {
        guard let value = self[key] as? Date else {
            throw SyncRecordError.missingField(key)
        }
        return value
    }

    func requiredBool(_ key: String) throws -> Bool {
        guard let value = self[key] as? Bool else {
            throw SyncRecordError.missingField(key)
        }
        return value
    }

    func decodedArray<T: Decodable>(_ key: String) -> [T] {
        guard let data = self[key] as? Data else { return [] }
        return (try? JSONDecoder().decode([T].self, from: data)) ?? []
    }
}

// MARK: - Tag + SyncableRecord

extension Tag: SyncableRecord {
    public static var recordType: String { "Tag" }

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
        self.init(
            id: try record.requiredUUID("id"),
            createdAt: try record.requiredDate("createdAt"),
            updatedAt: try record.requiredDate("updatedAt"),
            isDeleted: try record.requiredBool("isDeleted"),
            name: try record.requiredString("name"),
            color: try record.requiredString("color")
        )
    }
}

// MARK: - TaskItem + SyncableRecord

extension TaskItem: SyncableRecord {
    public static var recordType: String { "TaskItem" }

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
        if let tagsData = try? JSONEncoder().encode(tags) {
            record["tags"] = tagsData
        }
        if let linksData = try? JSONEncoder().encode(links) {
            record["links"] = linksData
        }
        return record
    }

    public init(from record: CKRecord) throws {
        let statusRaw = try record.requiredString("status")
        guard let status = TaskStatus(rawValue: statusRaw) else {
            throw SyncRecordError.invalidData("status")
        }
        guard let priorityRaw = record["priority"] as? Int,
              let priority = TaskPriority(rawValue: priorityRaw) else {
            throw SyncRecordError.missingField("priority")
        }
        self.init(
            id: try record.requiredUUID("id"),
            createdAt: try record.requiredDate("createdAt"),
            updatedAt: try record.requiredDate("updatedAt"),
            isDeleted: try record.requiredBool("isDeleted"),
            title: try record.requiredString("title"),
            body: try record.requiredString("body"),
            status: status,
            priority: priority,
            deadline: record["deadline"] as? Date,
            tags: record.decodedArray("tags"),
            links: record.decodedArray("links")
        )
    }
}

// MARK: - DiaryEntry + SyncableRecord

extension DiaryEntry: SyncableRecord {
    public static var recordType: String { "DiaryEntry" }

    public func toCKRecord() -> CKRecord {
        let recordID = CKRecord.ID(recordName: id.uuidString)
        let record = CKRecord(recordType: Self.recordType, recordID: recordID)
        record["id"] = id.uuidString
        record["createdAt"] = createdAt
        record["updatedAt"] = updatedAt
        record["isDeleted"] = isDeleted
        record["title"] = title
        record["body"] = String(body.characters)
        if let tagsData = try? JSONEncoder().encode(tags) {
            record["tags"] = tagsData
        }
        if let linksData = try? JSONEncoder().encode(links) {
            record["links"] = linksData
        }
        return record
    }

    public init(from record: CKRecord) throws {
        self.init(
            id: try record.requiredUUID("id"),
            createdAt: try record.requiredDate("createdAt"),
            updatedAt: try record.requiredDate("updatedAt"),
            isDeleted: try record.requiredBool("isDeleted"),
            title: try record.requiredString("title"),
            body: AttributedString(try record.requiredString("body")),
            tags: record.decodedArray("tags"),
            links: record.decodedArray("links")
        )
    }
}
