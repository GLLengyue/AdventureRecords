import Foundation
import SwiftUI
import Combine

class NoteViewModel: ObservableObject {
    @Published var notes: [NoteBlock] = []
    @Published var selectedNote: NoteBlock?
    @Published var isEditing: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    private let coreDataManager = CoreDataManager.shared
    
    init() {
        loadNotes()
    }
    
    func loadNotes() {
        notes = coreDataManager.fetchNotes()
    }
    
    func addNote(_ note: NoteBlock) {
        coreDataManager.saveNote(note)
        updateRelatedEntities(for: note)
        loadNotes()
    }
    
    func updateNote(_ note: NoteBlock) {
        coreDataManager.updateNote(note)
        updateRelatedEntities(for: note)
        loadNotes()
    }
    
    func deleteNote(_ note: NoteBlock) {
        coreDataManager.deleteNote(note.id)
        loadNotes()
    }
    
    func selectNote(_ note: NoteBlock) {
        selectedNote = note
    }
    
    func getRelatedCharacters(for note: NoteBlock) -> [CharacterCard] {
        return coreDataManager.fetchCharacters(for: note.relatedCharacterIDs)
    }
    
    func getRelatedScenes(for note: NoteBlock) -> [AdventureScene] {
        return coreDataManager.fetchScenes(for: note.relatedSceneIDs)
    }

    func updateRelatedEntities(for note: NoteBlock) {
        let characters = coreDataManager.fetchCharacters(for: note.relatedCharacterIDs)
        let scenes = coreDataManager.fetchScenes(for: note.relatedSceneIDs)

        for var character in characters {
            print("Updating character: \(character.name)")
            character.addNoteID(note.id)
            character.addSceneIDs(scenes.map { $0.id })
            coreDataManager.updateCharacter(character)
        }
        for var scene : AdventureScene in scenes {
            print("Updating scene: \(scene.title)")
            scene.addRelatedNoteID(note.id)
            scene.addRelatedCharacterIDs(characters.map { $0.id })
            coreDataManager.updateScene(scene)
        }
    }

}