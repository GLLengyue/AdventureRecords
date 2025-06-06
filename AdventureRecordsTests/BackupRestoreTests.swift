import XCTest
@testable import AdventureRecords

final class BackupRestoreTests: XCTestCase {
    let manager = CoreDataManager.shared

    override func setUp() {
        _ = manager.cleanupData(type: .all)
    }

    override func tearDown() {
        _ = manager.cleanupData(type: .all)
        // Remove backup directory
        let backups = manager.getAllBackups()
        for backup in backups {
            try? FileManager.default.removeItem(at: backup.url)
        }
        // Remove audio directories
        let doc = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let recordings = doc.appendingPathComponent("Recordings")
        try? FileManager.default.removeItem(at: recordings)
        let audios = doc.appendingPathComponent("AudioRecordings")
        try? FileManager.default.removeItem(at: audios)
    }

    func testBackupAndRestoreData() throws {
        // Create sample records
        SampleDataGenerator.initializeData()

        // Create a dummy audio file and save recording
        let audioDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("AudioRecordings")
        try FileManager.default.createDirectory(at: audioDir, withIntermediateDirectories: true)
        let recID = UUID()
        let audioURL = audioDir.appendingPathComponent("\(recID.uuidString).m4a")
        try Data("test".utf8).write(to: audioURL)
        let recording = AudioRecording(id: recID, title: "Sample", recordingURL: audioURL, date: Date())
        manager.saveAudioRecording(recording)

        // Create backup
        let _ = manager.createBackup(name: "RestoreTest", date: Date())
        guard let backup = manager.getAllBackups().first(where: { $0.name.contains("RestoreTest") }) else {
            XCTFail("Expected backup file")
            return
        }

        // Clean existing data and audio
        _ = manager.cleanupData(type: .all)
        try? FileManager.default.removeItem(at: audioURL)

        // Restore
        let success = manager.restoreFromBackup(backup)
        XCTAssertTrue(success, "Restore should succeed")
        XCTAssertFalse(manager.fetchCharacters().isEmpty)
        XCTAssertFalse(manager.fetchScenes().isEmpty)
        XCTAssertFalse(manager.fetchNotes().isEmpty)
        XCTAssertFalse(manager.fetchAudioRecordings().isEmpty)

        // Verify audio file restored
        let expectedURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("AudioRecordings")
            .appendingPathComponent("\(recID.uuidString).m4a")
        XCTAssertTrue(FileManager.default.fileExists(atPath: expectedURL.path))
    }
}
