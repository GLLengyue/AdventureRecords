import SwiftUI

struct CharacterCardRow: View {
    let character: CharacterCard
    @StateObject private var viewModel = CharacterViewModel()
    @State private var showDeleteAlert = false
    @State private var showEditor = false
    
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
                if !character.noteIDs.isEmpty {
                    let relatedNotes = viewModel.getRelatedNotes(for: character)
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

                // Display related scenes
                if !character.sceneIDs.isEmpty {
                    let relatedScenes = viewModel.getRelatedScenes(for: character)
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
                viewModel.deleteCharacter(character)
            }
        } message: {
            Text("确定要删除角色 \(character.name) 吗？此操作无法撤销。")
        }
        .sheet(isPresented: $showEditor) {
            NavigationStack {
                CharacterEditorView(card: character, onSave: { updatedCard in
                    viewModel.updateCharacter(updatedCard)
                }, onCancel: {
                    showEditor = false
                })
            }
        }
    }
}

#Preview {
    CharacterCardRow(character: CharacterCard(
        id: UUID(),
        name: "预览角色",
        description: "这是一个预览用的角色描述",
        avatar: nil,
        audioRecordings: nil,
        tags: ["预览"],
        noteIDs: [],
        sceneIDs: []
    ))
} 