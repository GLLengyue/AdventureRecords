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
        coreDataManager.saveNote(note)
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
        for var character in characters {
            print("Updating character: \(character.name)")
            if !character.noteIDs.contains(note.id) {
                character.noteIDs.append(note.id)
                // 保存更新后的角色卡
                coreDataManager.saveCharacter(character)
            }
        }
        let scenes = coreDataManager.fetchScenes(for: note.relatedSceneIDs)
        for var scene in scenes {
            print("Updating scene: \(scene.title)")
            if !scene.relatedNoteIDs.contains(note.id) {
                scene.relatedNoteIDs.append(note.id)
                coreDataManager.saveScene(scene)
            }
        }
    }

}