// Sources/EmpSync/EmpSync.swift
// EmpSync - CloudKit synchronization for EmpApps ecosystem
//
// EmpSync provides a protocol-based synchronization layer using CloudKit.
// It supports automatic sync, conflict resolution, and offline operation.
//
// ## Quick Start
//
// ```swift
// import EmpSync
//
// let syncService = CloudKitSyncService(
//     containerIdentifier: "iCloud.com.example.app"
// )
//
// // Start observing for changes
// try await syncService.startObserving()
//
// // Manual sync
// let result = try await syncService.sync()
// print("Pushed: \(result.pushed), Pulled: \(result.pulled)")
// ```
//
// ## Key Types
//
// - ``SyncService``: Protocol defining sync capabilities
// - ``CloudKitSyncService``: CloudKit implementation of SyncService
// - ``SyncState``: Current synchronization state
// - ``SyncResult``: Result of a sync operation
// - ``ConflictStrategy``: Strategy for resolving conflicts
// - ``SyncableRecord``: Protocol for models that can be synced

// Re-export all public types
@_exported import EmpCore

/// EmpSync module namespace
public enum EmpSync {
    /// Current version of the EmpSync module
    public static let version = "1.0.0"
}
