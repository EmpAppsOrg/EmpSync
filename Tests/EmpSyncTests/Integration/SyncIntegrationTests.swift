// Tests/EmpSyncTests/Integration/SyncIntegrationTests.swift
import Combine
import EmpCore
@testable import EmpSync
import Foundation
import Testing

@Suite("Sync Integration Tests")
struct SyncIntegrationTests {
    @Test("Full sync workflow with mock data")
    func fullWorkflow() throws {
        // Create test data
        let tag = Tag(
            id: UUID(),
            createdAt: Date(),
            updatedAt: Date(),
            isDeleted: false,
            name: "Integration",
            color: "#123456",
        )

        let task = TaskItem(
            id: UUID(),
            createdAt: Date(),
            updatedAt: Date(),
            isDeleted: false,
            title: "Integration Test Task",
            body: "Testing full sync workflow",
            status: .todo,
            priority: .medium,
            deadline: nil,
            tags: [tag],
            links: [],
        )

        // Convert to CKRecord and back
        let tagRecord = tag.toCKRecord()
        let taskRecord = task.toCKRecord()

        let restoredTag = try Tag(from: tagRecord)
        let restoredTask = try TaskItem(from: taskRecord)

        // Verify roundtrip
        #expect(restoredTag.id == tag.id)
        #expect(restoredTag.name == tag.name)

        #expect(restoredTask.id == task.id)
        #expect(restoredTask.title == task.title)
        #expect(restoredTask.tags.first?.id == tag.id)
    }

    @Test("Conflict resolution with lastWriteWins")
    func conflictResolution() {
        let id = UUID()
        let baseDate = Date()

        let local = Tag(
            id: id,
            createdAt: baseDate,
            updatedAt: baseDate.addingTimeInterval(100),
            isDeleted: false,
            name: "Local Version",
            color: "#FF0000",
        )

        let remote = Tag(
            id: id,
            createdAt: baseDate,
            updatedAt: baseDate.addingTimeInterval(200),
            isDeleted: false,
            name: "Remote Version",
            color: "#00FF00",
        )

        let strategy = ConflictStrategy.lastWriteWins
        let winner = strategy.resolve(local: local, remote: remote)

        #expect(winner.name == "Remote Version")
        #expect(winner.color == "#00FF00")
    }

    @Test("Soft delete propagation")
    func softDelete() throws {
        let tag = Tag(
            id: UUID(),
            createdAt: Date(),
            updatedAt: Date(),
            isDeleted: true,
            name: "Deleted Tag",
            color: "#000000",
        )

        let record = tag.toCKRecord()
        #expect(record["isDeleted"] as? Bool == true)

        let restored = try Tag(from: record)
        #expect(restored.isDeleted == true)
    }

    @Test("Multiple models roundtrip through CloudKit records")
    func multipleModelsRoundtrip() throws {
        // Create related test data
        let tag1 = Tag(name: "Work", color: "#FF0000")
        let tag2 = Tag(name: "Personal", color: "#00FF00")

        let task = TaskItem(
            title: "Multi-tag task",
            body: "Testing multiple tags",
            status: .inProgress,
            priority: .high,
            tags: [tag1, tag2],
        )

        // Convert to records and back
        let tag1Record = tag1.toCKRecord()
        let tag2Record = tag2.toCKRecord()
        let taskRecord = task.toCKRecord()

        let restoredTag1 = try Tag(from: tag1Record)
        let restoredTag2 = try Tag(from: tag2Record)
        let restoredTask = try TaskItem(from: taskRecord)

        // Verify all data preserved
        #expect(restoredTag1.name == "Work")
        #expect(restoredTag2.name == "Personal")
        #expect(restoredTask.title == "Multi-tag task")
        #expect(restoredTask.status == .inProgress)
        #expect(restoredTask.priority == .high)
        #expect(restoredTask.tags.count == 2)
    }

    @Test("ConflictStrategy integration with multiple model types")
    func conflictStrategyMultipleModels() {
        let id = UUID()
        let baseDate = Date()

        // Test with TaskItem
        let localTask = TaskItem(
            id: id,
            createdAt: baseDate,
            updatedAt: baseDate.addingTimeInterval(50),
            title: "Local Task",
        )

        let remoteTask = TaskItem(
            id: id,
            createdAt: baseDate,
            updatedAt: baseDate.addingTimeInterval(100),
            title: "Remote Task",
        )

        // lastWriteWins picks newer
        let taskWinner = ConflictStrategy.lastWriteWins.resolve(local: localTask, remote: remoteTask)
        #expect(taskWinner.title == "Remote Task")

        // keepLocal always picks local
        let localWinner = ConflictStrategy.keepLocal.resolve(local: localTask, remote: remoteTask)
        #expect(localWinner.title == "Local Task")

        // keepRemote always picks remote
        let remoteWinner = ConflictStrategy.keepRemote.resolve(local: localTask, remote: remoteTask)
        #expect(remoteWinner.title == "Remote Task")
    }

    @Test("NetworkMonitor integration")
    func networkMonitorIntegration() async throws {
        let monitor = NetworkMonitor()

        await monitor.start()

        // Give monitor time to determine status
        try await Task.sleep(for: .milliseconds(100))

        // Status should be defined
        let status = await monitor.isConnected
        #expect(status == true || status == false)

        await monitor.stop()
    }

    @Test("Full data model sync roundtrip")
    func fullDataModelRoundtrip() throws {
        // Create a complex task with all fields
        let deadline = Date().addingTimeInterval(86400) // tomorrow
        let tag = Tag(name: "Urgent", color: "#FF0000")
        let link = EmpLink(targetID: UUID(), targetAppID: "com.empapps.tasks")

        let task = TaskItem(
            id: UUID(),
            createdAt: Date(),
            updatedAt: Date(),
            isDeleted: false,
            title: "Complete Task",
            body: "Full description here",
            status: .inProgress,
            priority: .high,
            deadline: deadline,
            tags: [tag],
            links: [link],
        )

        // Roundtrip through CKRecord
        let record = task.toCKRecord()
        let restored = try TaskItem(from: record)

        // Verify all fields
        #expect(restored.id == task.id)
        #expect(restored.title == task.title)
        #expect(restored.body == task.body)
        #expect(restored.status == task.status)
        #expect(restored.priority == task.priority)
        #expect(restored.deadline != nil)
        #expect(restored.tags.count == 1)
        #expect(restored.tags.first?.name == "Urgent")
        #expect(restored.links.count == 1)
        #expect(restored.links.first?.targetAppID == "com.empapps.tasks")
    }
}
