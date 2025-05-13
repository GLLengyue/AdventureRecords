import SwiftUI

struct SceneListView: View {
    @EnvironmentObject var sceneViewModel: SceneViewModel

    @State private var showingSceneEditor = false
    @State private var sceneToEdit: AdventureScene? = nil

    var body: some View {
        NavigationView {
            List {
                ForEach(sceneViewModel.scenes) { scene in
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
                .onDelete(perform: deleteScenes)
            }
            .refreshable {
                sceneViewModel.loadScenes()
            }
            .navigationTitle("场景")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
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
        }
    }

    private func deleteScenes(at offsets: IndexSet) {
        offsets.map { sceneViewModel.scenes[$0] }.forEach {
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