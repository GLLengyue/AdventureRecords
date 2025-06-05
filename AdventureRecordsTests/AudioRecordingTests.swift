import XCTest
@testable import AdventureRecords

final class AudioRecordingTests: XCTestCase {
    let manager = CoreDataManager.shared
    override func setUp() {
        _ = manager.cleanupData(type: .all)
    }
    override func tearDown() {
        _ = manager.cleanupData(type: .all)
        let doc = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audios = doc.appendingPathComponent("AudioRecordings")
        try? FileManager.default.removeItem(at: audios)
    }

    func testSaveFetchUpdateDeleteRecording() throws {
        let audioDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("AudioRecordings")
        try FileManager.default.createDirectory(at: audioDir, withIntermediateDirectories: true)
        let id = UUID()
        let audioURL = audioDir.appendingPathComponent("\(id.uuidString).m4a")
        try Data("audio".utf8).write(to: audioURL)

        var recording = AudioRecording(id: id, title: "Original", recordingURL: audioURL, date: Date())
        manager.saveAudioRecording(recording)

        var fetched = manager.fetchAudioRecordings().first { $0.id == id }
        XCTAssertNotNil(fetched)
        XCTAssertEqual(fetched?.title, "Original")

        recording.title = "Updated"
        manager.updateAudioRecording(recording)

        fetched = manager.fetchAudioRecordings().first { $0.id == id }
        XCTAssertEqual(fetched?.title, "Updated")

        manager.deleteAudioRecording(id)
        fetched = manager.fetchAudioRecordings().first { $0.id == id }
        XCTAssertNil(fetched)

        try? FileManager.default.removeItem(at: audioURL)
    }
}
