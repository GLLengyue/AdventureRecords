import SwiftUI

struct CharacterRow: View {
    let character: CharacterCard
    @State private var showEditor = false
    
    var onDelete: () -> Void
    var onEdit: (CharacterCard) -> Void
    var getRelatedNotes: () -> [NoteBlock]
    var getRelatedScenes: () -> [AdventureScene]

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

#Preview {
    CharacterRow(
        character: CharacterCard(
            id: UUID(),
            name: "预览角色",
            description: "这是一个预览用的角色描述",
            avatar: nil,
            audioRecordings: nil,
            tags: ["预览"],
            noteIDs: [],
            sceneIDs: []
        ),
        onDelete: { print("Delete action triggered for preview") },
        onEdit: { _ in print("Edit action triggered for preview") },
        getRelatedNotes: { [] },
        getRelatedScenes: { [] }
    )
    .environmentObject(CharacterViewModel())
} 