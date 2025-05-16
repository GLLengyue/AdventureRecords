import SwiftUI

struct SceneListView: View {
    @EnvironmentObject var sceneViewModel: SceneViewModel
    @Binding var showingSceneEditor: Bool

    @State private var searchText: String = ""
    @State private var sortOrder: SortOrder = .titleAscending
    @State private var selectedScene: AdventureScene? = nil
    @State private var showingSortMenu: Bool = false

    enum SortOrder: String, CaseIterable, Identifiable {
        case titleAscending = "名称升序"
        case titleDescending = "名称降序"
        // Add more sort options if needed, e.g., by date
        var id: String { self.rawValue }
    }

    var filteredAndSortedScenes: [AdventureScene] {
        let filtered = sceneViewModel.scenes.filter { scene in
            searchText.isEmpty ? true : scene.title.localizedCaseInsensitiveContains(searchText) || scene.description.localizedCaseInsensitiveContains(searchText)
        }

        switch sortOrder {
        case .titleAscending:
            return filtered.sorted { $0.title.localizedCompare($1.title) == .orderedAscending }
        case .titleDescending:
            return filtered.sorted { $0.title.localizedCompare($1.title) == .orderedDescending }
        }
    }

    var body: some View {
        ListContainer(
            module: .scene,
            title: "场景",
            searchText: $searchText,
            onSearch: { _ in },
            addAction: { showingSceneEditor = true },
            trailingContent: {
                Menu {
                    ForEach(SortOrder.allCases) { order in
                        Button(action: {
                            sortOrder = order
                        }) {
                            HStack {
                                Text(order.rawValue)
                                if sortOrder == order {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                        .foregroundColor(ThemeManager.shared.accentColor(for: .scene))
                }
            }
        ) {
            List(filteredAndSortedScenes) { scene in
                Button {
                    selectedScene = scene
                } label: {
                    SceneRow(scene: scene,
                        onDelete: {
                            sceneViewModel.deleteScene(scene)
                        },
                        onEdit: { editableScene in
                            sceneViewModel.updateScene(editableScene)
                        }
                    )
                }
            }
        }
        .sheet(item: $selectedScene) { scene in
            SceneDetailView(scene: scene)
        }
        .sheet(isPresented: $showingSceneEditor) {
            SceneEditorView(
                onSave: { savedScene in
                    sceneViewModel.addScene(savedScene)
                    showingSceneEditor = false
                },
                onCancel: {
                    showingSceneEditor = false
                }
            )
        }
    }

    private func deleteScenes(at offsets: IndexSet) {
        offsets.map { filteredAndSortedScenes[$0] }.forEach {
            sceneViewModel.deleteScene($0)
        }
    }
}