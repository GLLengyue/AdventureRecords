import Combine
import Foundation
import SwiftUI

class CharacterViewModel: ObservableObject {
    static let shared = CharacterViewModel()

    @Published var characters: [Character] = []

    private var cancellables = Set<AnyCancellable>()
    private let coreDataManager = CoreDataManager.shared

    private init() {
        loadCharacters()
    }

    func getCharacter(id: UUID) -> Character? {
        return characters.first(where: { $0.id == id })
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

    /// 获取所有角色中使用的标签
    func getAllTags() -> [String] {
        var allTags = Set<String>()
        for character in characters {
            for tag in character.tags {
                allTags.insert(tag)
            }
        }
        return Array(allTags).sorted()
    }
}
