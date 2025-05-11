import SwiftUI


struct SceneRow: View {
    let scene: AdventureScene
    @StateObject private var viewModel = SceneViewModel()
    @State private var showDeleteAlert = false
    @State private var showEditor = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(scene.title)
                .font(.headline)
            Text(scene.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)

            // Display related characters
            if !scene.relatedCharacterIDs.isEmpty {
                let relatedCharacters = viewModel.getRelatedCharacters(for: scene)
                if !relatedCharacters.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            Text("角色:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            ForEach(relatedCharacters, id: \.id) { character in
                                Text(character.name)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.top, 4)
                }
            }

            // Display related notes
            if !scene.relatedNoteIDs.isEmpty {
                let relatedNotes = viewModel.getRelatedNotes(for: scene)
                if !relatedNotes.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            Text("笔记:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            ForEach(relatedNotes, id: \.id) { note in
                                Text(note.title)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.orange.opacity(0.1))
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.top, 4)
                }
            }
        }
        .swipeActions {
            Button(role: .destructive) {
                showDeleteAlert = true
            } label: {
                Label("删除", systemImage: "trash")
            }
            
            Button {
                showEditor = true
            } label: {
                Label("编辑", systemImage: "pencil")
            }
            .tint(.blue)
        }
        .alert("确认删除", isPresented: $showDeleteAlert) {
            Button("取消", role: .cancel) {}
            Button("删除", role: .destructive) {
                viewModel.deleteScene(scene)
            }
        } message: {
            Text("确定要删除场景 \(scene.title) 吗？此操作无法撤销。")
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
    }
}