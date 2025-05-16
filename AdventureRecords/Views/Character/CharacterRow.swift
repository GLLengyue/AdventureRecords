import SwiftUI

struct CharacterRow: View {
    let character: Character
    @State private var showEditor = false
    
    @EnvironmentObject var noteViewModel: NoteViewModel
    @EnvironmentObject var sceneViewModel: SceneViewModel
    var onDelete: () -> Void
    var onEdit: (Character) -> Void
    // 通过全局ViewModel和ID动态查找
    var relatedNotes: [NoteBlock] { noteViewModel.notes.filter { character.noteIDs.contains($0.id) } }
    var relatedScenes: [AdventureScene] { sceneViewModel.scenes.filter { character.sceneIDs.contains($0.id) } }

    var body: some View {
        HStack {
            if let avatar = character.avatar {
                Image(uiImage: avatar)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .frame(width: 40, height: 40)
            }
            
            VStack(alignment: .leading) {
                Text(character.name).font(.headline)
                Text(character.description).font(.subheadline).foregroundColor(.secondary)

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
                self.showEditor = true
            } label: {
                Label("编辑", systemImage: "pencil")
            }
            Button(role: .destructive) {
                onDelete()
            }label: {
                Label("删除", systemImage: "trash")
            }
        }
        .sheet(isPresented: $showEditor) {
            CharacterEditorView(card: character, onSave: { updatedCard in
                onEdit(updatedCard)
                showEditor = false
            }, onCancel: {
                showEditor = false
            })
        }
    }
}