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
        HStack(alignment: .top, spacing: 12) {
            // 笔记图标部分
            ZStack {
                Circle()
                    .fill(ThemeManager.shared.accentColor(for: .note).opacity(0.1))
                    .frame(width: 56, height: 56)

                Image(systemName: "note.text")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(ThemeManager.shared.accentColor(for: .note))
            }

            // 笔记信息部分
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(note.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(ThemeManager.shared.primaryTextColor)

                    Spacer()

                    Text(note.date, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if !note.content.isEmpty {
                    Text(note.content)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                // 标签预览
                if !note.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(Array(note.tags.prefix(3)), id: \.self) { tag in
                                HStack(spacing: 4) {
                                    Image(systemName: "tag.fill")
                                        .font(.system(size: 8))
                                    Text(tag)
                                        .lineLimit(1)
                                }
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(ThemeManager.shared.accentColor(for: .note).opacity(0.1))
                                .foregroundColor(ThemeManager.shared.accentColor(for: .note))
                                .cornerRadius(6)
                                .overlay(RoundedRectangle(cornerRadius: 6)
                                    .stroke(ThemeManager.shared.accentColor(for: .note).opacity(0.3), lineWidth: 1))
                            }

                            if note.tags.count > 3 {
                                Text("+\(note.tags.count - 3)")
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(ThemeManager.shared.accentColor(for: .note).opacity(0.1))
                                    .foregroundColor(ThemeManager.shared.accentColor(for: .note))
                                    .cornerRadius(6)
                                    .overlay(RoundedRectangle(cornerRadius: 6)
                                        .stroke(ThemeManager.shared.accentColor(for: .note).opacity(0.3),
                                                lineWidth: 1))
                            }
                        }
                    }
                    .padding(.top, 2)
                    .padding(.bottom, 2)
                }

                // 相关条目部分
                VStack(alignment: .leading) {
                    // 相关角色
                    if !relatedCharacters.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(relatedCharacters, id: \.id) { character in
                                    HStack(spacing: 4) {
                                        Image(systemName: "person.circle.fill")
                                            .font(.system(size: 10))
                                        Text(character.name)
                                            .lineLimit(1)
                                    }
                                    .font(.caption2)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(ThemeManager.shared.accentColor(for: .character).opacity(0.1))
                                    .foregroundColor(ThemeManager.shared.accentColor(for: .character))
                                    .cornerRadius(8)
                                    .overlay(RoundedRectangle(cornerRadius: 8)
                                        .stroke(ThemeManager.shared.accentColor(for: .character).opacity(0.3),
                                                lineWidth: 1))
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
                                    .overlay(RoundedRectangle(cornerRadius: 8)
                                        .stroke(ThemeManager.shared.accentColor(for: .scene).opacity(0.3),
                                                lineWidth: 1))
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
            .tint(ThemeManager.shared.accentColor(for: .note))
        }
        .contextMenu {
            Button {
                showEditor = true
            } label: {
                Label("编辑", systemImage: "pencil")
                    .foregroundColor(ThemeManager.shared.accentColor(for: .note))
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
            NoteEditorView(note: note, onSave: { updatedNote in
                onEdit(updatedNote)
                showEditor = false
            }, onCancel: {
                showEditor = false
            })
        }
    }
}
