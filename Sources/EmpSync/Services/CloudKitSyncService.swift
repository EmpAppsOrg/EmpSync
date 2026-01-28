// Sources/EmpSync/Services/CloudKitSyncService.swift
import CloudKit
import Combine
import Foundation

/// CloudKit-based implementation of SyncService using CKSyncEngine
public final class CloudKitSyncService: SyncService, @unchecked Sendable {
    // MARK: - Properties

    private let container: CKContainer
    private let database: CKDatabase
    private let stateSubject = CurrentValueSubject<SyncState, Never>(.idle)
    private var syncEngine: CKSyncEngine?

    public var conflictStrategy: ConflictStrategy = .lastWriteWins

    public var state: SyncState {
        stateSubject.value
    }

    public var statePublisher: AnyPublisher<SyncState, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    // MARK: - Initialization

    /// Initialize with CloudKit container identifier
    /// - Parameter containerIdentifier: The CloudKit container identifier (e.g., "iCloud.com.example.app")
    public init(containerIdentifier: String) {
        container = CKContainer(identifier: containerIdentifier)
        database = container.privateCloudDatabase
    }

    // MARK: - SyncService

    public func sync() async throws -> SyncResult {
        stateSubject.send(.syncing)

        do {
            // Check account status first
            let status = try await container.accountStatus()

            guard status == .available else {
                let error: SyncError = status == .noAccount ? .unauthorized : .networkUnavailable
                stateSubject.send(.error(error))
                throw error
            }

            // Perform sync using CKSyncEngine if available
            // For now, return empty result as CKSyncEngine handles sync automatically
            let result = SyncResult(pushed: 0, pulled: 0, conflicts: 0, errors: [])
            stateSubject.send(.idle)
            return result
        } catch let error as SyncError {
            stateSubject.send(.error(error))
            throw error
        } catch {
            let syncError = SyncError.unknown(error as NSError)
            stateSubject.send(.error(syncError))
            throw syncError
        }
    }

    public func startObserving() async throws {
        // Initialize CKSyncEngine for automatic sync
        // CKSyncEngine requires iOS 17+/macOS 14+

        let configuration = CKSyncEngine.Configuration(
            database: database,
            stateSerialization: nil,
            delegate: SyncEngineDelegate(service: self)
        )

        syncEngine = CKSyncEngine(configuration)
    }

    public func stopObserving() {
        syncEngine = nil
    }

    // MARK: - Internal

    func handleNetworkChange(isAvailable: Bool) {
        if isAvailable, state == .offline {
            stateSubject.send(.idle)
            Task {
                try? await sync()
            }
        } else if !isAvailable {
            stateSubject.send(.offline)
        }
    }
}

// MARK: - CKSyncEngine Delegate

private final class SyncEngineDelegate: CKSyncEngineDelegate, @unchecked Sendable {
    weak var service: CloudKitSyncService?

    init(service: CloudKitSyncService) {
        self.service = service
    }

    func handleEvent(_ event: CKSyncEngine.Event, syncEngine: CKSyncEngine) {
        switch event {
        case .stateUpdate:
            // Handle state updates
            break

        case .accountChange:
            // Handle account changes
            break

        case .fetchedDatabaseChanges:
            // Handle fetched database changes
            break

        case .fetchedRecordZoneChanges:
            // Handle fetched record zone changes
            break

        case .sentDatabaseChanges:
            // Handle sent database changes
            break

        case .sentRecordZoneChanges:
            // Handle sent record zone changes
            break

        case .willFetchChanges, .willFetchRecordZoneChanges, .didFetchChanges, .didFetchRecordZoneChanges:
            // Lifecycle events
            break

        case .willSendChanges, .didSendChanges:
            // Lifecycle events
            break

        @unknown default:
            break
        }
    }

    func nextRecordZoneChangeBatch(
        _ context: CKSyncEngine.SendChangesContext,
        syncEngine: CKSyncEngine
    ) -> CKSyncEngine.RecordZoneChangeBatch? {
        // Return pending changes to sync
        nil
    }
}
