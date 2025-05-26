import Combine
import Foundation
import SwiftUI

class NoteViewModel: ObservableObject {
    static let shared = NoteViewModel()

    @Published var notes: [NoteBlock] = []

    private var cancellables = Set<AnyCancellable>()
    private let coreDataManager = CoreDataManager.shared

    private init() {
        loadNotes()
    }

    func getNote(id: UUID) -> NoteBlock? {
        return notes.first(where: { $0.id == id })
    }

    func loadNotes() {
        notes = coreDataManager.fetchNotes()
        self.objectWillChange.send()
    }

    func addNote(_ note: NoteBlock) {
        coreDataManager.saveNote(note)
        addRelationships(for: note)
        loadNotes()
    }

    func updateNote(_ note: NoteBlock) {
        coreDataManager.updateNote(note)
        addRelationships(for: note)
        loadNotes()
    }

    func deleteNote(_ note: NoteBlock) {
        coreDataManager.deleteNote(note.id)
        removeRelationship(for: note)
        loadNotes()
    }

    /// 获取所有笔记中使用的标签
    func getAllTags() -> [String] {
        var allTags = Set<String>()
        for note in notes {
            for tag in note.tags {
                allTags.insert(tag)
            }
        }
        return Array(allTags).sorted()
    }

    func removeRelationship(for note: NoteBlock) {
        let characters = coreDataManager.fetchCharacters(for: note.relatedCharacterIDs)
        let scenes = coreDataManager.fetchScenes(for: note.relatedSceneIDs)

        for var character: Character in characters {
            character.removeNoteID(note.id)
            coreDataManager.updateCharacter(character)
        }
        for var scene: AdventureScene in scenes {
            scene.removeRelatedNoteID(note.id)
            coreDataManager.updateScene(scene)
        }
    }

    func addRelationships(for note: NoteBlock) {
        let characters = coreDataManager.fetchCharacters(for: note.relatedCharacterIDs)
        let scenes = coreDataManager.fetchScenes(for: note.relatedSceneIDs)

        for var character in characters {
            character.addNoteID(note.id)
            coreDataManager.updateCharacter(character)
        }
        for var scene: AdventureScene in scenes {
            scene.addRelatedNoteID(note.id)
            coreDataManager.updateScene(scene)
        }
    }
}
