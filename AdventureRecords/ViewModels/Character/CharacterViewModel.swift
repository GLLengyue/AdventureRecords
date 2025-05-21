import Foundation
import SwiftUI
import Combine

class CharacterViewModel: ObservableObject {
    static let shared = CharacterViewModel()
    
    @Published var characters: [Character] = []
    
    private var cancellables = Set<AnyCancellable>()
    private let coreDataManager = CoreDataManager.shared
    
    private init() {
        loadCharacters()
    }

    func getCharacter(id: UUID) -> Character? {
        return characters.first(where: {$0.id == id})
    }

    // func characters -> [Character] {
    //     loadCharacters()
    //     return characters
    // }
    
    func loadCharacters() {
        characters = coreDataManager.fetchCharacters()
        self.objectWillChange.send()
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