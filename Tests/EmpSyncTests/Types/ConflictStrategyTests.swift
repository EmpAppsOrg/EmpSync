// Tests/EmpSyncTests/Types/ConflictStrategyTests.swift
import EmpCore
@testable import EmpSync
import Foundation
import Testing

@Suite("ConflictStrategy Tests")
struct ConflictStrategyTests {
    @Test("ConflictStrategy has preset strategies")
    func presetStrategies() {
        let lastWriteWins = ConflictStrategy.lastWriteWins
        let keepLocal = ConflictStrategy.keepLocal
        let keepRemote = ConflictStrategy.keepRemote

        // Verify strategies exist (compile-time check)
        #expect(lastWriteWins != nil)
        #expect(keepLocal != nil)
        #expect(keepRemote != nil)
    }

    @Test("lastWriteWins picks newer record")
    func lastWriteWinsLogic() {
        let older = Tag(
            id: UUID(),
            createdAt: Date(timeIntervalSince1970: 1000),
            updatedAt: Date(timeIntervalSince1970: 2000),
            isDeleted: false,
            name: "Old",
            color: "#FF0000",
        )
        let newer = Tag(
            id: older.id,
            createdAt: Date(timeIntervalSince1970: 1000),
            updatedAt: Date(timeIntervalSince1970: 3000),
            isDeleted: false,
            name: "New",
            color: "#00FF00",
        )

        let result = ConflictStrategy.lastWriteWins.resolve(local: older, remote: newer)
        #expect(result.name == "New")

        let result2 = ConflictStrategy.lastWriteWins.resolve(local: newer, remote: older)
        #expect(result2.name == "New")
    }

    @Test("keepLocal always returns local")
    func keepLocalLogic() {
        let local = Tag(
            id: UUID(),
            createdAt: Date(),
            updatedAt: Date(),
            isDeleted: false,
            name: "Local",
            color: "#FF0000",
        )
        let remote = Tag(
            id: local.id,
            createdAt: Date(),
            updatedAt: Date().addingTimeInterval(1000),
            isDeleted: false,
            name: "Remote",
            color: "#00FF00",
        )

        let result = ConflictStrategy.keepLocal.resolve(local: local, remote: remote)
        #expect(result.name == "Local")
    }

    @Test("keepRemote always returns remote")
    func keepRemoteLogic() {
        let local = Tag(
            id: UUID(),
            createdAt: Date(),
            updatedAt: Date().addingTimeInterval(1000),
            isDeleted: false,
            name: "Local",
            color: "#FF0000",
        )
        let remote = Tag(
            id: local.id,
            createdAt: Date(),
            updatedAt: Date(),
            isDeleted: false,
            name: "Remote",
            color: "#00FF00",
        )

        let result = ConflictStrategy.keepRemote.resolve(local: local, remote: remote)
        #expect(result.name == "Remote")
    }
}
