import SwiftUI

struct SceneListView: View {
    @Binding var showingSceneEditor: Bool

    @State private var searchText: String = ""
    @State private var sortOrder: SortOrder = .titleAscending
    @State private var selectedScene: AdventureScene? = nil
    @State private var showingSortMenu: Bool = false
    
    // 使用单例
    @StateObject private var sceneViewModel = SceneViewModel.shared

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
                            withAnimation {
                                sortOrder = order
                            }
                        }) {
                            HStack {
                                Text(order.rawValue)
                                    .font(.system(.body))
                                Spacer()
                                if sortOrder == order {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(ThemeManager.shared.accentColor(for: .scene))
                                }
                            }
                            .contentShape(Rectangle())
                        }
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 16, weight: .semibold))
                        .padding(8)
                        .background(ThemeManager.shared.accentColor(for: .scene).opacity(0.1))
                        .clipShape(Circle())
                }
            }
        ) {
            if filteredAndSortedScenes.isEmpty {
                VStack(spacing: 20) {
                    Spacer()
                    
                    VStack(spacing: 16) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 64))
                            .foregroundColor(ThemeManager.shared.accentColor(for: .scene).opacity(0.6))
                        
                        Text(searchText.isEmpty ? "暂无场景" : "没有找到相关场景")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        if searchText.isEmpty {
                            Button {
                                showingSceneEditor = true
                            } label: {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("创建场景")
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(ThemeManager.shared.accentColor(for: .scene))
                                .foregroundColor(.white)
                                .cornerRadius(20)
                            }
                            .buttonStyle(ScaleButtonStyle())
                            .padding(.top, 8)
                        }
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
            } else {
                List {
                    ForEach(filteredAndSortedScenes) { scene in
                        Button {
                            selectedScene = scene
                        } label: {
                            SceneRow(scene: scene,
                                onDelete: {
                                    withAnimation {
                                        SceneViewModel.shared.deleteScene(scene)
                                    }
                                },
                                onEdit: { editableScene in
                                    sceneViewModel.updateScene(editableScene)
                                }
                            )
                            .contentShape(Rectangle())
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .sheet(item: $selectedScene) { scene in
            SceneDetailView(sceneID: scene.id)
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