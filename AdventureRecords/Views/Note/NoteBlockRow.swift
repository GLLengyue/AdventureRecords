import SwiftUI

struct NoteBlockRow: View {
    let note: NoteBlock
    @State private var showEditor = false
    
    // 使用单例
    @StateObject private var characterViewModel = CharacterViewModel.shared
    @StateObject private var sceneViewModel = SceneViewModel.shared
    
    var onDelete: () -> Void
    var onEdit: (NoteBlock) -> Void
    // 通过全局ViewModel和ID动态查找
    var relatedCharacters: [Character] { note.relatedCharacters(in: characterViewModel.characters) }
    var relatedScenes: [AdventureScene] { note.relatedScenes(in: sceneViewModel.scenes) }

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
            NoteEditorView(note: note, onSave: { updatedNote in
                onEdit(updatedNote)
                showEditor = false
            }, onCancel: {
                showEditor = false
            })
        }
    }
}