import SwiftUI

struct NoteBlockDetailView: View {
    let noteBlock: NoteBlock
    @EnvironmentObject var noteViewModel: NoteViewModel
    @EnvironmentObject var characterViewModel: CharacterViewModel
    @EnvironmentObject var sceneViewModel: SceneViewModel
    @State private var showEditor = false
    @State private var selectedCharacterForDetail: Character? = nil
    @State private var selectedSceneForDetail: AdventureScene? = nil
    @State private var showImmersiveMode = false // 新增状态：控制沉浸模式显示

    private var relatedCharacters: [Character] {
        characterViewModel.characters.filter { noteBlock.relatedCharacterIDs.contains($0.id) }
    }

    private var relatedScenes: [AdventureScene] {
        sceneViewModel.scenes.filter { noteBlock.relatedSceneIDs.contains($0.id) }
    }

    var body: some View {
        DetailContainer(module: .note, title: "笔记详情", backAction: { /* 通常由 NavigationView 处理 */ }, editAction: { showEditor = true }) {
            VStack(alignment: .leading, spacing: 16) {
                Text(noteBlock.title)
                    .font(.largeTitle)
                    .bold()
                
                Text("创建于: \(noteBlock.date, style: .date)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                if !relatedCharacters.isEmpty {
                    Section(header: Text("关联角色").font(.headline)) {
                        ForEach(relatedCharacters) { character in
                            Button(action: {
                                selectedCharacterForDetail = character
                            }) {
                                Text(character.name)
                                    .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                                    .background(ThemeManager.shared.accentColor(for: .character).opacity(0.2))
                                    .cornerRadius(8)
                                    .foregroundColor(ThemeManager.shared.accentColor(for: .character))
                            }
                        }
                    }
                }
                
                if !relatedScenes.isEmpty {
                    Section(header: Text("关联场景").font(.headline)) {
                        ForEach(relatedScenes) { scene in
                            Button(action: {
                                selectedSceneForDetail = scene
                            }) {
                                Text(scene.title)
                                    .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                                    .background(ThemeManager.shared.accentColor(for: .scene).opacity(0.2))
                                    .cornerRadius(8)
                                    .foregroundColor(ThemeManager.shared.accentColor(for: .scene))
                            }
                        }
                    }
                }

                Text("笔记内容：")
                    .font(.headline)
                    .padding(.top)
                Text(noteBlock.content)
                    .font(.body)
                
                // 沉浸模式入口按钮
                Button(action: { showImmersiveMode = true }) {
                    Label("进入沉浸模式", systemImage: "arrow.up.left.and.arrow.down.right.circle.fill")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(ThemeManager.shared.accentColor(for: .note).opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.top)
                
                Spacer()
            }
        }
        .sheet(isPresented: $showEditor) {
            NoteEditorView(
                note: noteBlock, 
                onSave: { updatedNote in
                    noteViewModel.updateNote(updatedNote)
                    showEditor = false
                }, 
                onCancel: { 
                    showEditor = false
                }
            )
        }
        .sheet(item: $selectedCharacterForDetail) { characterItem in
            NavigationStack {
                CharacterDetailView(character: characterItem)
            }
        }
        .sheet(item: $selectedSceneForDetail) { sceneItem in
            NavigationStack {
                SceneDetailView(scene: sceneItem)
            }
        }
        .fullScreenCover(isPresented: $showImmersiveMode) { // 使用 fullScreenCover 展示沉浸模式
            ImmersiveModeView(content: .note(noteBlock))
        }
    }
}