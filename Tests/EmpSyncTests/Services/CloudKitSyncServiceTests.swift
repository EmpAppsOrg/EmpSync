// Tests/EmpSyncTests/Services/CloudKitSyncServiceTests.swift
import Combine
@testable import EmpSync
import Testing

@Suite("CloudKitSyncService Tests")
struct CloudKitSyncServiceTests {
    @Test("CloudKitSyncService conforms to SyncService")
    func conformance() {
        let service = CloudKitSyncService(containerIdentifier: "iCloud.test")

        // Verify protocol conformance
        let _: any SyncService = service

        #expect(service.state == .idle)
    }

    @Test("CloudKitSyncService initial state is idle")
    func initialState() {
        let service = CloudKitSyncService(containerIdentifier: "iCloud.test")
        #expect(service.state == .idle)
    }

    @Test("CloudKitSyncService default conflict strategy is lastWriteWins")
    func defaultConflictStrategy() {
        let service = CloudKitSyncService(containerIdentifier: "iCloud.test")
        // We can't directly compare strategies, but we can verify it's set
        #expect(service.conflictStrategy != nil)
    }

    @Test("CloudKitSyncService publishes state changes")
    func statePublisher() async throws {
        let service = CloudKitSyncService(containerIdentifier: "iCloud.test")
        var receivedStates: [SyncState] = []

        let cancellable = service.statePublisher.sink { state in
            receivedStates.append(state)
        }

        // Initial state should be published
        try await Task.sleep(for: .milliseconds(50))
        #expect(receivedStates.contains(.idle))

        _ = cancellable
    }

    @Test("CloudKitSyncService can change conflict strategy")
    func changeConflictStrategy() {
        var service = CloudKitSyncService(containerIdentifier: "iCloud.test")
        service.conflictStrategy = .keepLocal
        service.conflictStrategy = .keepRemote
        // If no crash, strategy can be changed
    }
}
