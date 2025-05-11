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
        loadNotes()
    }
    
    func updateNote(_ note: NoteBlock) {
        coreDataManager.saveNote(note)
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
        let allCharacters = coreDataManager.fetchCharacters()
        return allCharacters.filter { character in
            note.relatedCharacterIDs.contains(character.id)
        }
    }
    
    func getRelatedScenes(for note: NoteBlock) -> [AdventureScene] {
        let allScenes = coreDataManager.fetchScenes()
        return allScenes.filter { scene in
            note.relatedSceneIDs.contains(scene.id)
        }
    }
} 