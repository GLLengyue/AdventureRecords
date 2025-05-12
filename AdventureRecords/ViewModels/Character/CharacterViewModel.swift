import Foundation
import SwiftUI
import Combine

class CharacterViewModel: ObservableObject {
    @Published var characters: [CharacterCard] = []
    @Published var selectedCharacter: CharacterCard?
    @Published var isEditing: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    private let coreDataManager = CoreDataManager.shared
    
    init() {
        loadCharacters()
    }
    
    func loadCharacters() {
        characters = coreDataManager.fetchCharacters()
    }
    
    func addCharacter(_ character: CharacterCard) {
        coreDataManager.saveCharacter(character)
        updateRelatedEntities(for: character)
        loadCharacters()
    }
    
    func updateCharacter(_ character: CharacterCard) {
        coreDataManager.updateCharacter(character)
        updateRelatedEntities(for: character)
        loadCharacters()
    }
    
    func updateRelatedEntities(for character: CharacterCard) {
        let notes = coreDataManager.fetchNotes(for: character.noteIDs)
        for var note in notes {
            print("Updating note: \(note.title)")
            if !note.relatedCharacterIDs.contains(character.id) {
                note.relatedCharacterIDs.append(character.id)
                coreDataManager.updateNote(note)
            }
        }
        let scenes = coreDataManager.fetchScenes(for: character.sceneIDs)
        for var scene in scenes {
            print("Updating scene: \(scene.title)")
            if !scene.relatedCharacterIDs.contains(character.id) {
                scene.relatedCharacterIDs.append(character.id)
                coreDataManager.updateScene(scene)
            }
        }
    }
    
    func deleteCharacter(_ character: CharacterCard) {
        print("Deleting character: \(character.id)")
        coreDataManager.deleteCharacter(character.id)
        print("Character deleted")
        loadCharacters()
    }
    
    func selectCharacter(_ character: CharacterCard) {
        selectedCharacter = character
    }
    
    func getRelatedNotes(for character: CharacterCard) -> [NoteBlock] {
        return coreDataManager.fetchNotes(for: character.noteIDs)
    }
    
    func getRelatedScenes(for character: CharacterCard) -> [AdventureScene] {
        return coreDataManager.fetchScenes(for: character.sceneIDs)
    }
}