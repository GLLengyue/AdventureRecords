import SwiftUI

struct NoteBlockDetailView: View {
    let noteID: UUID
    // let noteBlock: NoteBlock

    // 使用单例
    @StateObject private var noteViewModel = NoteViewModel.shared
    @StateObject private var characterViewModel = CharacterViewModel.shared
    @StateObject private var sceneViewModel = SceneViewModel.shared
    @State private var showEditor = false
    @State private var selectedCharacterForDetail: Character? = nil
    @State private var selectedSceneForDetail: AdventureScene? = nil

    private var noteBlock: NoteBlock? {
        noteViewModel.getNote(id: noteID)
    }

    private var relatedCharacters: [Character] {
        guard let noteBlock = noteBlock else { return [] }
        return characterViewModel.characters.filter { noteBlock.relatedCharacterIDs.contains($0.id) }
    }

    private var relatedScenes: [AdventureScene] {
        guard let noteBlock = noteBlock else { return [] }
        return sceneViewModel.scenes.filter { noteBlock.relatedSceneIDs.contains($0.id) }
    }

    // 格式化的创建日期
    private var formattedDate: String {
        guard let noteBlock = noteBlock else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: noteBlock.date)
    }

    var body: some View {
        Group {
            if let noteBlock = noteBlock {
                DetailContainer(module: .note, title: "笔记详情", backAction: { /* 通常由 NavigationView 处理 */ },
                                editAction: { showEditor = true })
                {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                    // 笔记标题和日期
                    VStack(alignment: .leading, spacing: 8) {
                            Text(noteBlock.title)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(ThemeManager.shared.primaryTextColor)
                            .padding(.bottom, 4)

                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.secondary)
                            Text(formattedDate)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.bottom, 8)

                    Divider()

                    // 关联角色
                    if !relatedCharacters.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("关联角色", systemImage: "person.2")
                                .font(.headline)
                                .foregroundColor(ThemeManager.shared.accentColor(for: .character))

                            FlowLayout(spacing: 8) {
                                ForEach(relatedCharacters) { character in
                                    CharacterItemView(character: character) {
                                        selectedCharacterForDetail = character
                                    }
                                }
                            }
                        }
                        .padding(.bottom, 8)
                    }

                    // 关联场景
                    if !relatedScenes.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("关联场景", systemImage: "film")
                                .font(.headline)
                                .foregroundColor(ThemeManager.shared.accentColor(for: .scene))

                            FlowLayout(spacing: 8) {
                                ForEach(relatedScenes) { scene in
                                    SceneItemView(scene: scene) {
                                        selectedSceneForDetail = scene
                                    }
                                }
                            }
                        }
                        .padding(.bottom, 8)
                    }

                    // 笔记标签
                    if !noteBlock.tags.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("标签", systemImage: "tag")
                                .font(.headline)
                                .foregroundColor(ThemeManager.shared.accentColor(for: .note))

                            FlowLayout(spacing: 8) {
                                ForEach(noteBlock.tags, id: \.self) { tag in
                                    TagView(tag: tag, accentColor: ThemeManager.shared.accentColor(for: .note))
                                }
                            }
                        }
                        .padding(.bottom, 8)
                    }

                    Divider()

                    // 笔记内容
                    VStack(alignment: .leading, spacing: 12) {
                        Label("笔记内容", systemImage: "doc.text")
                            .font(.headline)
                            .foregroundColor(ThemeManager.shared.accentColor(for: .note))

                        Text(noteBlock.content)
                            .font(.body)
                            .foregroundColor(ThemeManager.shared.primaryTextColor)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.vertical, 4)
                    }

                    Spacer(minLength: 40)
                }
                .padding(.horizontal)
                    }
                    .background(ThemeManager.shared.backgroundColor)
                }
                .sheet(isPresented: $showEditor) {
                    NoteEditorView(note: noteBlock,
                                   onSave: { updatedNote in
                                       noteViewModel.updateNote(updatedNote)
                                       showEditor = false
                                   },
                                   onCancel: {
                                       showEditor = false
                                   })
                }
                .sheet(item: $selectedCharacterForDetail) { character in
                    NavigationStack {
                        CharacterDetailView(CharacterID: character.id)
                    }
                }
                .sheet(item: $selectedSceneForDetail) { scene in
                    NavigationStack {
                        SceneDetailView(sceneID: scene.id)
                    }
                }
            } else {
                Text("无法找到笔记")
                    .foregroundColor(.secondary)
            }
        }
    }
}
