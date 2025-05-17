import Foundation
import SwiftUI
import Combine

class CharacterViewModel: ObservableObject {
    @Published var characters: [Character] = []
    
    private var cancellables = Set<AnyCancellable>()
    private let coreDataManager = CoreDataManager.shared
    
    init() {
        loadCharacters()
    }
    
    func loadCharacters() {
        characters = coreDataManager.fetchCharacters()
    }
    
    func addCharacter(_ character: Character) {
        coreDataManager.saveCharacter(character)
        loadCharacters()
    }
    
    func updateCharacter(_ character: Character) {
        coreDataManager.updateCharacter(character)
        loadCharacters()
    }
    
    func deleteCharacter(_ character: Character) {
        coreDataManager.deleteCharacter(character.id)
        loadCharacters()
    }

}