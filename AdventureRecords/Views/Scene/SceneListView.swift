import SwiftUI

struct SceneListView: View {
    @EnvironmentObject var sceneViewModel: SceneViewModel
    @Binding var showingSceneEditor: Bool

    @State private var searchText: String = ""
    @State private var stagingSearchText: String = ""
    @State private var sortOrder: SortOrder = .titleAscending
    @State private var selectedScene: AdventureScene? = nil

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
            module: .character,
            title: "角色卡",
            addAction: { /* 新增操作 */ },
            trailingContent: {
                Button(action: { /* 排序操作 */ }) {
                    Image(systemName: "arrow.up.arrow.down")
                }
                Button(action: { /* 搜索操作 */ }) {
                    Image(systemName: "magnifyingglass")
                }
            }
        ){
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
                        },
                        getRelatedCharacters: {
                            return sceneViewModel.getRelatedCharacters(for: scene)
                        },
                        getRelatedNotes: {
                            return sceneViewModel.getRelatedNotes(for: scene)
                        }
                    )
                }
            }
        }
        .sheet(item: $selectedScene) { scene in
            SceneDetailView(scene: scene)
        }
        .searchable(text: $stagingSearchText, prompt: "搜索场景") // Add searchable modifier
        .onSubmit(of: .search) {
            searchText = stagingSearchText
        }
        .onChange(of: stagingSearchText) {
            if stagingSearchText.isEmpty {
                searchText = ""
            }
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
            .environmentObject(sceneViewModel)
            // .environmentObject(CharacterViewModel()) // 假设的共享实例
            // .environmentObject(NoteViewModel())       // 假设的共享实例
        }
    }

    private func deleteScenes(at offsets: IndexSet) {
        offsets.map { filteredAndSortedScenes[$0] }.forEach { // Use filteredAndSortedScenes
            sceneViewModel.deleteScene($0)
        }
    }
}