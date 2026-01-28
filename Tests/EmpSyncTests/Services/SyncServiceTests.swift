// Tests/EmpSyncTests/Services/SyncServiceTests.swift
import Combine
@testable import EmpSync
import Testing

@Suite("SyncService Protocol Tests")
struct SyncServiceTests {
    /// Mock implementation to verify protocol requirements
    /// Using @unchecked Sendable since this is only for testing and used on a single thread
    final class MockSyncService: SyncService, @unchecked Sendable {
        var conflictStrategy: ConflictStrategy = .lastWriteWins
        var state: SyncState = .idle
        var statePublisher: AnyPublisher<SyncState, Never> {
            Just(state).eraseToAnyPublisher()
        }

        var syncCalled = false
        var startObservingCalled = false
        var stopObservingCalled = false

        func sync() async throws -> SyncResult {
            syncCalled = true
            return SyncResult(pushed: 0, pulled: 0, conflicts: 0, errors: [])
        }

        func startObserving() async throws {
            startObservingCalled = true
        }

        func stopObserving() {
            stopObservingCalled = true
        }
    }

    @Test("SyncService has required methods")
    func protocolRequirements() async throws {
        let service = MockSyncService()

        _ = try await service.sync()
        #expect(service.syncCalled)

        try await service.startObserving()
        #expect(service.startObservingCalled)

        service.stopObserving()
        #expect(service.stopObservingCalled)
    }

    @Test("SyncService has state property")
    func stateProperty() {
        let service = MockSyncService()
        #expect(service.state == .idle)

        service.state = .syncing
        #expect(service.state == .syncing)
    }

    @Test("SyncService has conflictStrategy property")
    func conflictStrategyProperty() {
        let service = MockSyncService()

        // Default strategy
        #expect(service.conflictStrategy != nil)

        // Can be changed
        service.conflictStrategy = .keepLocal
        #expect(service.conflictStrategy != nil)
    }

    @Test("SyncService provides state publisher")
    func statePublisher() async {
        let service = MockSyncService()
        var receivedStates: [SyncState] = []

        let cancellable = service.statePublisher.sink { state in
            receivedStates.append(state)
        }

        // Give publisher time to emit
        try? await Task.sleep(for: .milliseconds(10))

        #expect(receivedStates.contains(.idle))
        _ = cancellable
    }
}
