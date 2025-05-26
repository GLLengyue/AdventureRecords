import SwiftUI

struct SceneRow: View {
    let scene: AdventureScene
    @State private var showEditor = false

    // 使用单例
    @StateObject private var characterViewModel = CharacterViewModel.shared
    @StateObject private var noteViewModel = NoteViewModel.shared

    var onDelete: () -> Void
    var onEdit: (AdventureScene) -> Void
    // 通过全局ViewModel和ID动态查找
    var relatedNotes: [NoteBlock] { scene.relatedNotes(in: noteViewModel.notes) }
    var relatedCharacters: [Character] {
        scene.relatedCharacters(in: noteViewModel.notes, characterProvider: { note in
            note.relatedCharacters(in: characterViewModel.characters)
        })
    }

    // 移除 getRelatedCharacters/getRelatedNotes 参数，保持与调用方一致

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // 场景图标部分
            ZStack {
                Circle()
                    .fill(ThemeManager.shared.accentColor(for: .scene).opacity(0.1))
                    .frame(width: 56, height: 56)

                if let coverImage = scene.coverImage {
                    Image(uiImage: coverImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .overlay(Circle()
                            .stroke(ThemeManager.shared.accentColor(for: .scene).opacity(0.3), lineWidth: 2))
                } else {
                    Image(systemName: "photo.on.rectangle.angled.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(ThemeManager.shared.accentColor(for: .scene))
                }
            }

            // 场景信息部分
            VStack(alignment: .leading, spacing: 4) {
                Text(scene.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(ThemeManager.shared.primaryTextColor)

                if !scene.description.isEmpty {
                    Text(scene.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                // 标签预览
                if !scene.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(Array(scene.tags.prefix(3)), id: \.self) { tag in
                                HStack(spacing: 4) {
                                    Image(systemName: "tag.fill")
                                        .font(.system(size: 8))
                                    Text(tag)
                                        .lineLimit(1)
                                }
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(ThemeManager.shared.accentColor(for: .scene).opacity(0.1))
                                .foregroundColor(ThemeManager.shared.accentColor(for: .scene))
                                .cornerRadius(6)
                                .overlay(RoundedRectangle(cornerRadius: 6)
                                    .stroke(ThemeManager.shared.accentColor(for: .scene).opacity(0.3),
                                            lineWidth: 1))
                            }

                            if scene.tags.count > 3 {
                                Text("+\(scene.tags.count - 3)")
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(ThemeManager.shared.accentColor(for: .scene).opacity(0.1))
                                    .foregroundColor(ThemeManager.shared.accentColor(for: .scene))
                                    .cornerRadius(6)
                                    .overlay(RoundedRectangle(cornerRadius: 6)
                                        .stroke(ThemeManager.shared.accentColor(for: .scene).opacity(0.3),
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
                                    .overlay(RoundedRectangle(cornerRadius: 8)
                                        .stroke(ThemeManager.shared.accentColor(for: .note).opacity(0.3),
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
            .tint(ThemeManager.shared.accentColor(for: .scene))
        }
        .contextMenu {
            Button {
                showEditor = true
            } label: {
                Label("编辑", systemImage: "pencil")
                    .foregroundColor(ThemeManager.shared.accentColor(for: .scene))
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
            SceneEditorView(scene: scene, onSave: { updatedScene in
                onEdit(updatedScene)
                showEditor = false
            }, onCancel: {
                showEditor = false
            })
        }
    }
}
