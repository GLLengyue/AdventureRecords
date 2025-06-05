import XCTest
@testable import AdventureRecords

final class CoreDataBackupTests: XCTestCase {
    func testCreateBackupGeneratesFile() throws {
        // Generate sample data
        SampleDataGenerator.initializeData()
        let manager = CoreDataManager.shared

        // Record existing backups
        let existingBackups = manager.getAllBackups()

        // Create backup
        let now = Date()
        let _ = manager.createBackup(name: "TestBackup", date: now)

        // Fetch backups after creation
        let allBackups = manager.getAllBackups()
        let newBackups = allBackups.filter { !existingBackups.contains($0) && $0.name.contains("TestBackup") }
        XCTAssertFalse(newBackups.isEmpty, "Backup file should be created")

        // Cleanup new backup files
        for backup in newBackups {
            try? FileManager.default.removeItem(at: backup.url)
        }
    }
}
