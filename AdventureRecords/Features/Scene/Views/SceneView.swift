//  SceneView.swift
//  AdventureRecords
//  场景管理列表视图
import SwiftUI

struct SceneView: View {
    @StateObject private var viewModel = SceneViewModel()
    @State private var showEditor = false
    @State private var selectedScene: AdventureScene? = nil
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.scenes) { scene in
                    SceneRow(scene: scene)
                        .onTapGesture {
                            selectedScene = scene
                        }
                }
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
}
