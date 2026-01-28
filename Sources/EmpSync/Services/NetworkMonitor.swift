// Sources/EmpSync/Services/NetworkMonitor.swift
import Combine
import Foundation
import Network

/// Monitors network connectivity status
public actor NetworkMonitor {
    // MARK: - Properties

    private var monitor: NWPathMonitor?
    private let queue = DispatchQueue(label: "com.empapps.empsync.networkmonitor")
    /// CurrentValueSubject is thread-safe, marked nonisolated for cross-actor access
    private nonisolated(unsafe) let statusSubject = CurrentValueSubject<Bool, Never>(false)

    /// Current network connectivity status
    public var isConnected: Bool {
        statusSubject.value
    }

    /// Publisher for network status changes
    public nonisolated var statusPublisher: AnyPublisher<Bool, Never> {
        statusSubject.eraseToAnyPublisher()
    }

    // MARK: - Initialization

    public init() {}

    // MARK: - Public Methods

    /// Start monitoring network status
    public func start() {
        guard monitor == nil else { return }

        let newMonitor = NWPathMonitor()

        newMonitor.pathUpdateHandler = { [weak self] path in
            let isConnected = path.status == .satisfied
            self?.statusSubject.send(isConnected)
        }

        newMonitor.start(queue: queue)
        monitor = newMonitor
    }

    /// Stop monitoring network status
    public func stop() {
        monitor?.cancel()
        monitor = nil
    }
}
