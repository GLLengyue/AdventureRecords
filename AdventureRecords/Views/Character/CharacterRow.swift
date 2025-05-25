import SwiftUI

struct CharacterRow: View {
    let character: Character
    @State private var showEditor = false
    
    // 使用单例
    @StateObject private var noteViewModel = NoteViewModel.shared
    @StateObject private var sceneViewModel = SceneViewModel.shared
    
    var onDelete: () -> Void
    var onEdit: (Character) -> Void
    // 通过全局ViewModel和ID动态查找
    var relatedNotes: [NoteBlock] {
        character.relatedNotes(in: noteViewModel.notes)
    }
    var relatedScenes: [AdventureScene] {
        character.relatedScenes(in: noteViewModel.notes, sceneProvider: { note in
            note.relatedScenes(in: sceneViewModel.scenes)
        })
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // 头像部分
            ZStack {
                Circle()
                    .fill(ThemeManager.shared.accentColor(for: .character).opacity(0.1))
                    .frame(width: 56, height: 56)
                
                if let avatar = character.avatar {
                    Image(uiImage: avatar)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(ThemeManager.shared.accentColor(for: .character).opacity(0.3), lineWidth: 2)
                        )
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36, height: 36)
                        .foregroundColor(ThemeManager.shared.accentColor(for: .character))
                }
            }
            
            // 角色信息部分
            VStack(alignment: .leading, spacing: 4) {
                Text(character.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(ThemeManager.shared.primaryTextColor)
                
                if !character.description.isEmpty {
                    Text(character.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                // 相关条目部分
                VStack(alignment: .leading) {
                    // 相关笔记
                    if !relatedNotes.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(relatedNotes, id: \.id) { note in
                                    HStack(spacing: 4) {
                                        Image(systemName: "doc.text.fill")
                                            .font(.system(size: 10))
                                        Text(note.title)
                                            .lineLimit(1)
                                    }
                                    .font(.caption2)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(ThemeManager.shared.accentColor(for: .note).opacity(0.1))
                                    .foregroundColor(ThemeManager.shared.accentColor(for: .note))
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(ThemeManager.shared.accentColor(for: .note).opacity(0.3), lineWidth: 1)
                                    )
                                }
                            }
                        }
                        .padding(.bottom, 4)
                    }

                    // 相关场景
                    if !relatedScenes.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(relatedScenes, id: \.id) { scene in
                                    HStack(spacing: 4) {
                                        Image(systemName: "photo.fill")
                                            .font(.system(size: 10))
                                        Text(scene.title)
                                            .lineLimit(1)
                                    }
                                    .font(.caption2)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(ThemeManager.shared.accentColor(for: .scene).opacity(0.1))
                                    .foregroundColor(ThemeManager.shared.accentColor(for: .scene))
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(ThemeManager.shared.accentColor(for: .scene).opacity(0.3), lineWidth: 1)
                                    )
                                }
                            }
                        }
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(.vertical, 6)
        .background(Color.clear)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                withAnimation {
                    onDelete()
                }
            } label: {
                Label("删除", systemImage: "trash")
            }
            
            Button {
                showEditor = true
            } label: {
                Label("编辑", systemImage: "pencil")
            }
            .tint(ThemeManager.shared.accentColor(for: .character))
        }
        .contextMenu {
            Button {
                showEditor = true
            } label: {
                Label("编辑", systemImage: "pencil")
                    .foregroundColor(ThemeManager.shared.accentColor(for: .character))
            }
            
            Divider()
            
            Button(role: .destructive) {
                withAnimation {
                    onDelete()
                }
            } label: {
                Label("删除", systemImage: "trash.fill")
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