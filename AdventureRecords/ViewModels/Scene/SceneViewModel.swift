import Foundation
import SwiftUI
import Combine

class SceneViewModel: ObservableObject {
    @Published var scenes: [AdventureScene] = []
    @Published var selectedScene: AdventureScene?
    @Published var isEditing: Bool = false
    
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
        coreDataManager.saveScene(scene)
        loadScenes()
    }
    
    func deleteScene(_ scene: AdventureScene) {
        coreDataManager.deleteScene(scene.id)
        loadScenes()
    }
    
    func selectScene(_ scene: AdventureScene) {
        selectedScene = scene
    }
    
    func getRelatedCharacters(for scene: AdventureScene) -> [CharacterCard] {
        return coreDataManager.fetchCharacters(for: scene.relatedCharacterIDs)
    }
    
    func getRelatedNotes(for scene: AdventureScene) -> [NoteBlock] {
        return coreDataManager.fetchNotes(for: scene.relatedNoteIDs)
    }
}