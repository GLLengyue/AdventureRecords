import XCTest
@testable import AdventureRecords

final class ExportAndCleanupTests: XCTestCase {
    override func setUp() {
        _ = CoreDataManager.shared.cleanupData(type: .all)
        SampleDataGenerator.initializeData()
    }

    override func tearDown() {
        _ = CoreDataManager.shared.cleanupData(type: .all)
    }

    func testExportJSONIncludesAllSections() throws {
        let manager = CoreDataManager.shared
        guard let document = manager.exportData(type: .json, includeCharacters: true, includeScenes: true, includeNotes: true) else {
            XCTFail("Expected export document")
            return
        }
        let jsonObject = try JSONSerialization.jsonObject(with: document.data, options: []) as? [String: Any]
        XCTAssertNotNil(jsonObject?["characters"])
        XCTAssertNotNil(jsonObject?["scenes"])
        XCTAssertNotNil(jsonObject?["notes"])
    }
}
