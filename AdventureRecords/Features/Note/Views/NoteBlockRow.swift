import SwiftUI

struct NoteBlockRow: View {    
    let note: NoteBlock
    @StateObject private var viewModel = NoteViewModel()
    @State private var showDeleteAlert = false
    @State private var showEditor = false
    
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
            if !note.relatedCharacterIDs.isEmpty {
                let relatedCharacters = viewModel.getRelatedCharacters(for: note)
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

            // Display related scenes
            if !note.relatedSceneIDs.isEmpty {
                let relatedScenes = viewModel.getRelatedScenes(for: note)
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
                viewModel.deleteNote(note)
            }
        } message: {
            Text("确定要删除笔记 \(note.title) 吗？此操作无法撤销。")
        }
        .sheet(isPresented: $showEditor) {
            NavigationStack {
                NoteEditorView(note: note)
            }
        }
    }
}
