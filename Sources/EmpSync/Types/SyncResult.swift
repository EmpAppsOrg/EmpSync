// Sources/EmpSync/Types/SyncResult.swift
import Foundation

/// Result of a sync operation
public struct SyncResult: Sendable {
    /// Number of records pushed to remote
    public let pushed: Int
    /// Number of records pulled from remote
    public let pulled: Int
    /// Number of conflicts encountered
    public let conflicts: Int
    /// Errors that occurred during sync
    public let errors: [SyncError]

    public init(pushed: Int, pulled: Int, conflicts: Int, errors: [SyncError]) {
        self.pushed = pushed
        self.pulled = pulled
        self.conflicts = conflicts
        self.errors = errors
    }
}
