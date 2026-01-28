@testable import EmpSync
import Testing

@Suite("EmpSync Module Tests")
struct EmpSyncTests {
    @Test("Module version is defined")
    func version() {
        #expect(EmpSync.version == "1.0.0")
    }
}
