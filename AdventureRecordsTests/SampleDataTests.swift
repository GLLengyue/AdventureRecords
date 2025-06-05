import XCTest
@testable import AdventureRecords

final class SampleDataTests: XCTestCase {
    override func setUp() {
        _ = CoreDataManager.shared.cleanupData(type: .all)
    }

    override func tearDown() {
        _ = CoreDataManager.shared.cleanupData(type: .all)
    }

    func testInitializeSampleDataCreatesRecords() {
        SampleDataGenerator.initializeData()
        let manager = CoreDataManager.shared
        XCTAssertGreaterThan(manager.fetchCharacters().count, 0)
        XCTAssertGreaterThan(manager.fetchScenes().count, 0)
        XCTAssertGreaterThan(manager.fetchNotes().count, 0)
    }

    func testCleanupRemovesAllData() {
        SampleDataGenerator.initializeData()
        let manager = CoreDataManager.shared
        XCTAssertFalse(manager.fetchCharacters().isEmpty)
        let success = manager.cleanupData(type: .all)
        XCTAssertTrue(success)
        XCTAssertTrue(manager.fetchCharacters().isEmpty)
        XCTAssertTrue(manager.fetchScenes().isEmpty)
        XCTAssertTrue(manager.fetchNotes().isEmpty)
    }
}
