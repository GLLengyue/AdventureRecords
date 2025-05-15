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
        updateRelatedEntities(for: scene)
        loadScenes()
    }
    
    func updateScene(_ scene: AdventureScene) {
        coreDataManager.updateScene(scene)
        updateRelatedEntities(for: scene)
        loadScenes()
    }
    
    func updateRelatedEntities(for scene: AdventureScene) {
        let characters = coreDataManager.fetchCharacters(for: scene.relatedCharacterIDs)
        for var character in characters {
            print("Updating character: \(character.name)")
            if !character.sceneIDs.contains(scene.id) {
                character.sceneIDs.append(scene.id)
                coreDataManager.updateCharacter(character)
            }
        }
        let notes = coreDataManager.fetchNotes(for: scene.relatedNoteIDs)
        for var note in notes {
            print("Updating note: \(note.title)")
            if !note.relatedSceneIDs.contains(scene.id) {
                note.relatedSceneIDs.append(scene.id)
                coreDataManager.updateNote(note)
            }
        }
    }
    
    func deleteScene(_ scene: AdventureScene) {
        coreDataManager.deleteScene(scene.id)
        loadScenes()
    }
    
    func selectScene(_ scene: AdventureScene) {
        selectedScene = scene
    }
    
    func getRelatedCharacters(for scene: AdventureScene) -> [Character] {
        return coreDataManager.fetchCharacters(for: scene.relatedCharacterIDs)
    }
    
    func getRelatedNotes(for scene: AdventureScene) -> [NoteBlock] {
        return coreDataManager.fetchNotes(for: scene.relatedNoteIDs)
    }
}