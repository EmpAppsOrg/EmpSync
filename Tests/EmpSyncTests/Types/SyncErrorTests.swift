// Tests/EmpSyncTests/Types/SyncErrorTests.swift
@testable import EmpSync
import Foundation
import Testing

@Suite("SyncError Tests")
struct SyncErrorTests {
    @Test("SyncError has all required cases")
    func allCases() {
        let network = SyncError.networkUnavailable
        let quota = SyncError.quotaExceeded
        let mismatch = SyncError.modelMismatch("TaskItem version conflict")
        let unauthorized = SyncError.unauthorized
        let unknown = SyncError.unknown(NSError(domain: "test", code: 1))

        #expect(network == .networkUnavailable)
        #expect(quota == .quotaExceeded)
        #expect(unauthorized == .unauthorized)

        if case let .modelMismatch(message) = mismatch {
            #expect(message == "TaskItem version conflict")
        } else {
            Issue.record("Expected modelMismatch case")
        }

        if case let .unknown(error) = unknown {
            #expect((error as NSError).domain == "test")
        } else {
            Issue.record("Expected unknown case")
        }
    }

    @Test("SyncError conforms to Error")
    func conformsToError() {
        let error: Error = SyncError.networkUnavailable
        #expect(error is SyncError)
    }

    @Test("SyncError is Sendable")
    func sendable() async {
        let error: SyncError = .quotaExceeded
        await Task {
            #expect(error == .quotaExceeded)
        }.value
    }
}
