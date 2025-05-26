import Combine
import Foundation
import SwiftUI

class SceneViewModel: ObservableObject {
    static let shared = SceneViewModel()

    @Published var scenes: [AdventureScene] = []

    private var cancellables = Set<AnyCancellable>()
    private let coreDataManager = CoreDataManager.shared

    private init() {
        loadScenes()
    }

    func getScene(id: UUID) -> AdventureScene? {
        return scenes.first(where: { $0.id == id })
    }

    func loadScenes() {
        scenes = coreDataManager.fetchScenes()
        self.objectWillChange.send()
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

    /// 获取所有场景中使用的标签
    func getAllTags() -> [String] {
        var allTags = Set<String>()
        for scene in scenes {
            for tag in scene.tags {
                allTags.insert(tag)
            }
        }
        return Array(allTags).sorted()
    }
}
