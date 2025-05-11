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