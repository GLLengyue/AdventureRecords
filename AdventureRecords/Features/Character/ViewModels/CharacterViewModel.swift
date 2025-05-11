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
        loadCharacters()
    }
    
    func updateCharacter(_ character: CharacterCard) {
        coreDataManager.saveCharacter(character)
        loadCharacters()
    }
    
    func deleteCharacter(_ character: CharacterCard) {
        coreDataManager.deleteCharacter(character.id)
        loadCharacters()
    }
    
    func selectCharacter(_ character: CharacterCard) {
        selectedCharacter = character
    }
    
    func getRelatedNotes(for character: CharacterCard) -> [NoteBlock] {
        let allNotes = coreDataManager.fetchNotes()
        return allNotes.filter { note in
            character.noteIDs.contains(note.id)
        }
    }
    
    func getRelatedScenes(for character: CharacterCard) -> [AdventureScene] {
        let allScenes = coreDataManager.fetchScenes()
        return allScenes.filter { scene in
            character.sceneIDs.contains(scene.id)
        }
    }
} 