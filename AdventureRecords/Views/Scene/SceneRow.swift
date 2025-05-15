import SwiftUI

struct SceneRow: View {
    let scene: AdventureScene
    @State private var showEditor = false
    
    var onDelete: () -> Void
    var onEdit: (AdventureScene) -> Void
    var getRelatedCharacters: () -> [Character]
    var getRelatedNotes: () -> [NoteBlock]

    var body: some View {
        VStack(alignment: .leading) {
            Text(scene.title)
                .font(.headline)
            Text(scene.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)

            // Display related characters
            let relatedCharacters = getRelatedCharacters()
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
            let relatedNotes = getRelatedNotes()
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