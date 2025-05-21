import SwiftUI

struct SceneRow: View {
    let scene: AdventureScene
    @State private var showEditor = false
    
    // 使用单例
    private let characterViewModel = CharacterViewModel.shared
    private let noteViewModel = NoteViewModel.shared
    
    var onDelete: () -> Void
    var onEdit: (AdventureScene) -> Void
    // 通过全局ViewModel和ID动态查找
    var relatedNotes: [NoteBlock] { scene.relatedNotes(in: noteViewModel.notes) }
    var relatedCharacters: [Character] {
        scene.relatedCharacters(in: noteViewModel.notes, characterProvider: { note in
            note.relatedCharacters(in: characterViewModel.getCharacters())
        })
    }
    // 移除 getRelatedCharacters/getRelatedNotes 参数，保持与调用方一致


    var body: some View {
        VStack(alignment: .leading) {
            Text(scene.title)
                .font(.headline)
            Text(scene.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)

            // Display related characters
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

            // Display related notes
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
        .swipeActions {
            Button(role: .destructive) {
                onDelete()
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
        .contextMenu {
            Button {
                showEditor = true
            } label: {
                Label("编辑", systemImage: "pencil")
            }
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("删除", systemImage: "trash")
            }
        }

        .sheet(isPresented: $showEditor) {
            SceneEditorView(scene: scene, onSave: { updatedScene in
                onEdit(updatedScene)
                showEditor = false
            }, onCancel: {
                showEditor = false
            })
        }
    }
}