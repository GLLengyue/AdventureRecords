//  SceneView.swift
//  AdventureRecords
//  场景管理列表视图
import SwiftUI

struct SceneView: View {
    @EnvironmentObject var viewModel: SceneViewModel
    @State private var showEditor = false
    @State private var selectedScene: AdventureScene? = nil
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.scenes) { scene in
                    SceneRow(
                        scene: scene,
                        onDelete: {
                            viewModel.deleteScene(scene)
                        },
                        onEdit: { updatedScene in
                            viewModel.updateScene(updatedScene)
                        },
                        getRelatedCharacters: {
                            return viewModel.getRelatedCharacters(for: scene)
                        },
                        getRelatedNotes: {
                            return viewModel.getRelatedNotes(for: scene)
                        }
                    )
                    .onTapGesture {
                        selectedScene = scene
                    }
                }
            }
            .refreshable {
                viewModel.loadScenes()
            }
            .navigationTitle("场景")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showEditor = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showEditor) {
                NavigationStack {
                    SceneEditorView(onSave: { updatedScene in
                        viewModel.updateScene(updatedScene)
                    }, onCancel: {
                        showEditor = false
                    })
                }
            }
            .sheet(item: $selectedScene) { sceneItem in
                NavigationStack {
                    SceneDetailView(scene: sceneItem)
                }
            }
            .onAppear {
                viewModel.loadScenes()
            }
        }
    }
}

#Preview {
    SceneView()
        .environmentObject(SceneViewModel())
}
