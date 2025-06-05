import XCTest
@testable import AdventureRecords

final class CoreDataCRUDTests: XCTestCase {
    override func setUp() {
        _ = CoreDataManager.shared.cleanupData(type: .all)
    }

    override func tearDown() {
        _ = CoreDataManager.shared.cleanupData(type: .all)
    }

    func testCharacterCRUD() {
        let manager = CoreDataManager.shared
        let character = manager.createCharacter(name: "TestChar", description: "desc")
        var fetched = manager.fetchCharacters().first { $0.id == character.id }
        XCTAssertNotNil(fetched)

        var updated = character
        updated.name = "UpdatedChar"
        manager.updateCharacter(updated)

        fetched = manager.fetchCharacters().first { $0.id == character.id }
        XCTAssertEqual(fetched?.name, "UpdatedChar")

        manager.deleteCharacter(character.id)
        fetched = manager.fetchCharacters().first { $0.id == character.id }
        XCTAssertNil(fetched)
    }

    func testSceneCRUD() {
        let manager = CoreDataManager.shared
        let scene = manager.createScene(title: "TestScene", description: "desc")
        var fetched = manager.fetchScenes().first { $0.id == scene.id }
        XCTAssertNotNil(fetched)

        var updated = scene
        updated.title = "UpdatedScene"
        manager.updateScene(updated)
        fetched = manager.fetchScenes().first { $0.id == scene.id }
        XCTAssertEqual(fetched?.title, "UpdatedScene")

        manager.deleteScene(scene.id)
        fetched = manager.fetchScenes().first { $0.id == scene.id }
        XCTAssertNil(fetched)
    }

    func testNoteCRUD() {
        let manager = CoreDataManager.shared
        let note = manager.createNote(title: "TestNote", content: "content")
        var fetched = manager.fetchNotes().first { $0.id == note.id }
        XCTAssertNotNil(fetched)

        var updated = note
        updated.title = "UpdatedNote"
        manager.updateNote(updated)

        fetched = manager.fetchNotes().first { $0.id == note.id }
        XCTAssertEqual(fetched?.title, "UpdatedNote")

        manager.deleteNote(note.id)
        fetched = manager.fetchNotes().first { $0.id == note.id }
        XCTAssertNil(fetched)
    }
}
