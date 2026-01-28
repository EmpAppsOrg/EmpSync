// Sources/EmpSync/Types/SyncState.swift
import Foundation

/// Current state of synchronization
public enum SyncState: Equatable, Sendable {
    /// No sync operation in progress
    case idle
    /// Sync operation is currently running
    case syncing
    /// Sync failed with an error
    case error(SyncError)
    /// Device is offline, sync will resume when online
    case offline
}
