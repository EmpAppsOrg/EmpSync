// Sources/EmpSync/Services/SyncService.swift
import Combine
import Foundation

/// Protocol defining synchronization service capabilities
public protocol SyncService: Sendable {
    /// Perform a full sync operation
    func sync() async throws -> SyncResult

    /// Start observing for remote changes (e.g., CloudKit push notifications)
    func startObserving() async throws

    /// Stop observing for remote changes
    func stopObserving()

    /// Strategy for resolving conflicts between local and remote data
    var conflictStrategy: ConflictStrategy { get set }

    /// Current sync state
    var state: SyncState { get }

    /// Publisher for observing state changes
    var statePublisher: AnyPublisher<SyncState, Never> { get }
}
