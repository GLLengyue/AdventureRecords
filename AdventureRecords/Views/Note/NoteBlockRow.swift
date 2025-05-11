import SwiftUI

struct NoteBlockRow: View {
    let note: NoteBlock
    @State private var showEditor = false
    
    var onDelete: () -> Void
    var onEdit: (NoteBlock) -> Void
    var getRelatedCharacters: () -> [CharacterCard]
    var getRelatedScenes: () -> [AdventureScene]

    var body: some View {
        VStack(alignment: .leading) {
            Text(note.title)
                .font(.headline)
            Text(note.content)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            Text(note.date, style: .date)
                .font(.caption)
                .foregroundColor(.secondary)

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

            // Display related scenes
            let relatedScenes = getRelatedScenes()
            if !relatedScenes.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        Text("场景:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        ForEach(relatedScenes, id: \.id) { scene in
                            Text(scene.title)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.green.opacity(0.1))
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
        .sheet(isPresented: $showEditor) {
            NoteEditorView(note: note, onSave: { updatedNote in
                onEdit(updatedNote)
            }, onCancel: {
                showEditor = false
            })
        }
    }
}

#Preview {
    NoteBlockRow(
        note: NoteBlock(
            id: UUID(), 
            title: "预览笔记", 
            content: "这是预览笔记的内容。", 
            relatedCharacterIDs: [], 
            relatedSceneIDs: [], 
            date: Date()
        ),
        onDelete: { print("Delete action triggered for preview note") },
        onEdit: { _ in print("Edit action triggered for preview note") },
        getRelatedCharacters: { [] },
        getRelatedScenes: { [] }
    )
    .environmentObject(NoteViewModel())
    .environmentObject(CharacterViewModel())
    .environmentObject(SceneViewModel())
}
