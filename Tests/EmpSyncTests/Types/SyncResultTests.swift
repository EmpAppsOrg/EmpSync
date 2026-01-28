// Tests/EmpSyncTests/Types/SyncResultTests.swift
@testable import EmpSync
import Testing

@Suite("SyncResult Tests")
struct SyncResultTests {
    @Test("SyncResult stores sync statistics")
    func creation() {
        let result = SyncResult(
            pushed: 5,
            pulled: 3,
            conflicts: 1,
            errors: [.networkUnavailable]
        )

        #expect(result.pushed == 5)
        #expect(result.pulled == 3)
        #expect(result.conflicts == 1)
        #expect(result.errors.count == 1)
        #expect(result.errors.first == .networkUnavailable)
    }

    @Test("SyncResult with no errors")
    func noErrors() {
        let result = SyncResult(pushed: 10, pulled: 5, conflicts: 0, errors: [])

        #expect(result.errors.isEmpty)
        #expect(result.conflicts == 0)
    }

    @Test("SyncResult is Sendable")
    func sendable() async {
        let result = SyncResult(pushed: 1, pulled: 2, conflicts: 0, errors: [])
        await Task {
            #expect(result.pushed == 1)
        }.value
    }
}
