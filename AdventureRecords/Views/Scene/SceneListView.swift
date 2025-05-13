import SwiftUI

struct SceneListView: View {
    @EnvironmentObject var sceneViewModel: SceneViewModel

    @State private var showingSceneEditor = false
    @State private var sceneToEdit: AdventureScene? = nil
    @State private var searchText: String = ""
    @State private var stagingSearchText: String = ""
    @State private var sortOrder: SortOrder = .titleAscending

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
        NavigationView {
            if filteredAndSortedScenes.isEmpty {
                VStack {
                    Image(systemName: "film.stack") // 示例图标
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray.opacity(0.5))
                        .padding(.bottom)
                    Text(searchText.isEmpty ? "还没有场景呢" : "没有找到符合条件的场景")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text(searchText.isEmpty ? "点击右上方 \"+\" 添加一个新场景吧！" : "尝试修改你的搜索词，或者清除搜索。")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
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
                .frame(maxWidth: .infinity, maxHeight: .infinity) // 居中内容
            } else {
                List {
                    ForEach(filteredAndSortedScenes) { scene in // Use filteredAndSortedScenes
                        NavigationLink(destination: SceneDetailView(scene: scene)) {
                            SceneRow(
                                scene: scene,
                                onDelete: {
                                    sceneViewModel.deleteScene(scene)
                                },
                                onEdit: { editableScene in
                                    self.sceneToEdit = editableScene
                                    self.showingSceneEditor = true
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
                .refreshable {
                    sceneViewModel.loadScenes()
                }
                .navigationTitle("场景")
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        EditButton()
                        Menu {
                            Picker("排序方式", selection: $sortOrder) {
                                ForEach(SortOrder.allCases, id: \.self) { order in
                                    Text(order.rawValue).tag(order)
                                }
                            }
                        } label: {
                            Label("排序", systemImage: "arrow.up.arrow.down.circle")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            self.sceneToEdit = nil // Ensure we are creating a new one
                            self.showingSceneEditor = true
                        } label: {
                            Label("添加场景", systemImage: "plus.circle.fill")
                        }
                    }
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
                        scene: sceneToEdit , // Pass nil for new, or existing scene for edit
                        onSave: { savedScene in
                            if let index = sceneViewModel.scenes.firstIndex(where: { $0.id == savedScene.id }) {
                                sceneViewModel.updateScene(savedScene)
                            } else {
                                sceneViewModel.addScene(savedScene)
                            }
                            showingSceneEditor = false
                        },
                        onCancel: {
                            showingSceneEditor = false
                        }
                    )
                }
            } // 关闭 else 代码块
        }
    }

    private func deleteScenes(at offsets: IndexSet) {
        offsets.map { filteredAndSortedScenes[$0] }.forEach { // Use filteredAndSortedScenes
            sceneViewModel.deleteScene($0)
        }
    }
}

// #Preview {
//     SceneListView()
//         .environmentObject(SceneViewModel())
//         .environmentObject(CharacterViewModel.preview)
//         .environmentObject(NoteViewModel.preview)
// }