import Foundation
import SwiftUI
import Combine

class SceneViewModel: ObservableObject {
    @Published var scenes: [AdventureScene] = []
    
    private var cancellables = Set<AnyCancellable>()
    private let coreDataManager = CoreDataManager.shared
    
    init() {
        loadScenes()
    }
    
    func loadScenes() {
        scenes = coreDataManager.fetchScenes()
    }
    
    func addScene(_ scene: AdventureScene) {
        coreDataManager.saveScene(scene)
        loadScenes()
    }
    
    func updateScene(_ scene: AdventureScene) {
        coreDataManager.updateScene(scene)
        loadScenes()
    }
    
    func deleteScene(_ scene: AdventureScene) {
        coreDataManager.deleteScene(scene.id)
        loadScenes()
    }    
    // func getRelatedCharacters(for scene: AdventureScene) -> [CharacterModel] {
    //     guard !scene.relatedNoteIDs.isEmpty else {
    //         return []
    //     }
    //     let notes = coreDataManager.fetchNotes(for: scene.relatedNoteIDs) // Assumes fetchNotes returns [NoteBlock]
    //     let characterIDs = notes.flatMap { $0.relatedCharacterIDs } // NoteBlock should have relatedCharacterIDs: [UUID]
    //     let uniqueCharacterIDs = Array(Set(characterIDs))
        
    //     guard !uniqueCharacterIDs.isEmpty else {
    //         return []
    //     }
    //     // Assumes coreDataManager.fetchCharacters(for: [UUID]) exists and returns [CharacterModel]
    //     return coreDataManager.fetchCharacters(for: uniqueCharacterIDs)
    // }
    
    // func getRelatedNotes(for scene: AdventureScene) -> [NoteBlock] {
    //     return coreDataManager.fetchNotes(for: scene.relatedNoteIDs)
    // }
}