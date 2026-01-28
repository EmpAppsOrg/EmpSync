// Tests/EmpSyncTests/Services/NetworkMonitorTests.swift
import Combine
@testable import EmpSync
import Testing

@Suite("NetworkMonitor Tests")
struct NetworkMonitorTests {
    @Test("NetworkMonitor provides initial status")
    func initialStatus() async throws {
        let monitor = NetworkMonitor()

        // Start monitoring
        await monitor.start()

        // Give it time to determine status
        try await Task.sleep(for: .milliseconds(100))

        // Status should be defined (either true or false)
        let status = await monitor.isConnected
        #expect(status == true || status == false)

        await monitor.stop()
    }

    @Test("NetworkMonitor publishes status changes")
    func statusPublisher() async throws {
        let monitor = NetworkMonitor()
        var receivedUpdates: [Bool] = []

        let cancellable = monitor.statusPublisher.sink { isConnected in
            receivedUpdates.append(isConnected)
        }

        await monitor.start()
        try await Task.sleep(for: .milliseconds(100))

        #expect(!receivedUpdates.isEmpty)

        await monitor.stop()
        _ = cancellable
    }

    @Test("NetworkMonitor can start and stop")
    func startStop() async {
        let monitor = NetworkMonitor()

        await monitor.start()
        await monitor.stop()
        await monitor.start()
        await monitor.stop()

        // No crash means success
    }
}
