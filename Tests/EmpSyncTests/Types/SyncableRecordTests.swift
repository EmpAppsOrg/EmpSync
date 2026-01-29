// Tests/EmpSyncTests/Types/SyncableRecordTests.swift
import CloudKit
import EmpCore
@testable import EmpSync
import Testing

@Suite("SyncableRecord Tests")
struct SyncableRecordTests {
    @Test("Tag conforms to SyncableRecord")
    func tagConformance() throws {
        let tag = Tag(
            id: UUID(),
            createdAt: Date(),
            updatedAt: Date(),
            isDeleted: false,
            name: "Work",
            color: "#FF5733"
        )

        // Convert to CKRecord
        let record = tag.toCKRecord()
        #expect(record.recordType == Tag.recordType)
        #expect(record["name"] as? String == "Work")
        #expect(record["color"] as? String == "#FF5733")
        #expect(record["isDeleted"] as? Bool == false)

        // Convert back from CKRecord
        let restored = try Tag(from: record)
        #expect(restored.id == tag.id)
        #expect(restored.name == tag.name)
        #expect(restored.color == tag.color)
        #expect(restored.isDeleted == tag.isDeleted)
    }

    @Test("TaskItem conforms to SyncableRecord")
    func taskItemConformance() throws {
        let task = TaskItem(
            id: UUID(),
            createdAt: Date(),
            updatedAt: Date(),
            isDeleted: false,
            title: "Buy groceries",
            body: "Milk, eggs, bread",
            status: .inProgress,
            priority: .high,
            deadline: Date().addingTimeInterval(86400),
            tags: [],
            links: []
        )

        let record = task.toCKRecord()
        #expect(record.recordType == TaskItem.recordType)
        #expect(record["title"] as? String == "Buy groceries")
        #expect(record["status"] as? String == "inProgress")
        #expect(record["priority"] as? Int == 2)

        let restored = try TaskItem(from: record)
        #expect(restored.id == task.id)
        #expect(restored.title == task.title)
        #expect(restored.status == .inProgress)
        #expect(restored.priority == .high)
    }

    @Test("DiaryEntry conforms to SyncableRecord")
    func diaryEntryConformance() throws {
        let entry = DiaryEntry(
            id: UUID(),
            createdAt: Date(),
            updatedAt: Date(),
            isDeleted: false,
            title: "My Day",
            body: AttributedString("Had a great day!"),
            tags: [],
            links: []
        )

        let record = entry.toCKRecord()
        #expect(record.recordType == DiaryEntry.recordType)
        #expect(record["title"] as? String == "My Day")

        let restored = try DiaryEntry(from: record)
        #expect(restored.id == entry.id)
        #expect(restored.title == entry.title)
    }

    @Test("ContactItem conforms to SyncableRecord")
    func contactItemConformance() throws {
        let tag = Tag(name: "Work", color: "#FF0000")
        let field = ContactField(label: "Telegram", type: .text, value: "@ivan")
        let contact = ContactItem(
            firstName: "Ivan",
            lastName: "Petrov",
            nickname: "ivanko",
            phone: "+79991234567",
            email: "ivan@mail.com",
            tags: [tag],
            customFields: [field]
        )

        let record = contact.toCKRecord()
        #expect(record.recordType == ContactItem.recordType)
        #expect(record["firstName"] as? String == "Ivan")
        #expect(record["lastName"] as? String == "Petrov")
        #expect(record["nickname"] as? String == "ivanko")
        #expect(record["phone"] as? String == "+79991234567")
        #expect(record["email"] as? String == "ivan@mail.com")

        let restored = try ContactItem(from: record)
        #expect(restored.id == contact.id)
        #expect(restored.firstName == "Ivan")
        #expect(restored.lastName == "Petrov")
        #expect(restored.nickname == "ivanko")
        #expect(restored.phone == "+79991234567")
        #expect(restored.tags.count == 1)
        #expect(restored.customFields.count == 1)
    }

    @Test("ContactItem with notes round-trips via CKRecord")
    func contactItemNotes() throws {
        let contact = ContactItem(
            firstName: "Maria",
            lastName: "Sidorova",
            notes: AttributedString("Some notes about Maria")
        )

        let record = contact.toCKRecord()
        #expect(record["notes"] as? String == "Some notes about Maria")

        let restored = try ContactItem(from: record)
        #expect(String(restored.notes!.characters) == "Some notes about Maria")
    }

    @Test("SyncableRecord recordID uses model UUID")
    func recordIDFromUUID() {
        let id = UUID()
        let tag = Tag(
            id: id,
            createdAt: Date(),
            updatedAt: Date(),
            isDeleted: false,
            name: "Test",
            color: "#000000"
        )

        let record = tag.toCKRecord()
        #expect(record.recordID.recordName == id.uuidString)
    }
}
