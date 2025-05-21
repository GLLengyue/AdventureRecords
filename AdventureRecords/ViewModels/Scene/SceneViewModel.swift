import Foundation
import SwiftUI
import Combine

class SceneViewModel: ObservableObject {
    static let shared = SceneViewModel()
    
    @Published var scenes: [AdventureScene] = []
    
    private var cancellables = Set<AnyCancellable>()
    private let coreDataManager = CoreDataManager.shared
    
    private init() {
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
}