// Tests/EmpSyncTests/Types/SyncStateTests.swift
@testable import EmpSync
import Testing

@Suite("SyncState Tests")
struct SyncStateTests {
    @Test("SyncState has all required cases")
    func allCases() {
        let idle = SyncState.idle
        let syncing = SyncState.syncing
        let error = SyncState.error(.networkUnavailable)
        let offline = SyncState.offline

        #expect(idle == .idle)
        #expect(syncing == .syncing)
        #expect(offline == .offline)

        if case let .error(syncError) = error {
            #expect(syncError == .networkUnavailable)
        } else {
            Issue.record("Expected error case")
        }
    }

    @Test("SyncState is Equatable")
    func equatable() {
        #expect(SyncState.idle == SyncState.idle)
        #expect(SyncState.syncing == SyncState.syncing)
        #expect(SyncState.offline == SyncState.offline)
        #expect(SyncState.idle != SyncState.syncing)
        #expect(SyncState.error(.networkUnavailable) == SyncState.error(.networkUnavailable))
        #expect(SyncState.error(.networkUnavailable) != SyncState.error(.quotaExceeded))
    }

    @Test("SyncState is Sendable")
    func sendable() async {
        let state: SyncState = .syncing
        await Task {
            #expect(state == .syncing)
        }.value
    }
}
