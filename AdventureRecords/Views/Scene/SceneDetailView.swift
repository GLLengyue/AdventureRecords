//  SceneDetailView.swift
//  AdventureRecords
//  场景详情视图
import SwiftUI

struct SceneDetailView: View {
    let scene: AdventureScene
    @EnvironmentObject var sceneViewModel: SceneViewModel
    @EnvironmentObject var noteViewModel: NoteViewModel
    @EnvironmentObject var characterViewModel: CharacterViewModel

    @State private var showImageViewer = false
    @State private var showAudioPlayer = false
    @State private var selectedAudioURL: URL?
    @State private var showNoteEditor = false
    @State private var showSceneEditor = false
    @State private var selectedNoteForDetail: NoteBlock? = nil
    @State private var selectedCharacterForDetail: CharacterCard? = nil
    
    private var relatedCharacters: [CharacterCard] {
        characterViewModel.characters.filter { scene.relatedCharacterIDs.contains($0.id) }
    }
    
    private var relatedNotes: [NoteBlock] {
        noteViewModel.notes.filter { scene.relatedNoteIDs.contains($0.id) }
    }
    
    var body: some View {
        DetailContainer(module: .scene, title: scene.title, backAction: { /* 由导航处理 */ }, editAction: { showSceneEditor = true }) {
            VStack(alignment: .leading, spacing: 20) {
                // 场景图片区域 (保留占位符逻辑，实际图片应从 scene.coverImageURL 或类似属性加载)
                if let coverImage = scene.coverImage {
                    Image(uiImage: coverImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 250)
                        .clipped()
                        .cornerRadius(10)
                        .onTapGesture { showImageViewer = true }
                } else {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(ThemeManager.shared.secondaryBackgroundColor)
                        .frame(height: 250)
                        .overlay(
                            Image(systemName: "photo.on.rectangle.angled")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .foregroundColor(ThemeManager.shared.accentColor(for: .scene).opacity(0.7))
                        )
                        .onTapGesture { showImageViewer = true }
                }
                
                Text(scene.description)
                    .font(.body)
                    .padding(.bottom)
   
                // 新增播放音频按钮 (保持现有占位符逻辑)
                if scene.audioURL != nil {
                    Button("播放场景音频") {
                        selectedAudioURL = scene.audioURL
                        showAudioPlayer = true
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(ThemeManager.shared.accentColor(for: .scene))
                    .padding(.bottom)
                }
                
                // 相关角色
                if !relatedCharacters.isEmpty {
                    Section(header: Text("出场角色 (\(relatedCharacters.count))").font(.headline)) {
                        ForEach(relatedCharacters) { character in
                            Button(action: { selectedCharacterForDetail = character }) {
                                HStack {
                                    Text(character.name).foregroundColor(ThemeManager.shared.primaryTextColor)
                                    Spacer()
                                    Image(systemName: "chevron.right").foregroundColor(.secondary)
                                }
                                .padding()
                                .background(ThemeManager.shared.secondaryBackgroundColor)
                                .cornerRadius(8)
                            }
                        }
                    }
                }
                
                // 相关笔记
                if !relatedNotes.isEmpty {
                    Section(header: Text("相关笔记 (\(relatedNotes.count))").font(.headline)) {
                        ForEach(relatedNotes) { note in
                            Button(action: { selectedNoteForDetail = note }) {
                                HStack {
                                    Text(note.title).foregroundColor(ThemeManager.shared.primaryTextColor)
                                    Spacer()
                                    Image(systemName: "chevron.right").foregroundColor(.secondary)
                                }
                                .padding()
                                .background(ThemeManager.shared.secondaryBackgroundColor)
                                .cornerRadius(8)
                            }
                        }
                    }
                }
                
                // 新建关联笔记按钮
                Button(action: { showNoteEditor = true }) {
                    Label("在当前场景下新建笔记", systemImage: "plus.circle.fill")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(ThemeManager.shared.accentColor(for: .scene))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.top)
            }
        }
        .sheet(isPresented: $showImageViewer) {
            VStack {
                Text("图片查看器占位符")
                    .font(.title)
                Text("这里将来会显示场景图片")
                Button("关闭") {
                    showImageViewer = false
                }
                .padding()
            }
        }
        .sheet(isPresented: $showAudioPlayer) {
            VStack {
                if let url = selectedAudioURL {
                    Text("音频播放器占位符")
                        .font(.title)
                    Text("播放: \(url.absoluteString)")
                } else {
                    Text("未选择音频")
                }
                Button("关闭") {
                    showAudioPlayer = false
                }
                .padding()
            }
        }
        .sheet(isPresented: $showNoteEditor) {
            NoteEditorView(
                preselectedSceneID: scene.id,
                onSave: { newNote in
                    noteViewModel.addNote(newNote)
                    showNoteEditor = false
                },
                onCancel: {
                    showNoteEditor = false
                }
            )
            .environmentObject(noteViewModel)
            .environmentObject(characterViewModel)
            .environmentObject(sceneViewModel)
        }
        .sheet(isPresented: $showSceneEditor) {
            SceneEditorView(
                scene: scene,
                onSave: { updatedScene in
                    sceneViewModel.updateScene(updatedScene)
                    showSceneEditor = false
                },
                onCancel: {
                    showSceneEditor = false
                }
            )
            .environmentObject(sceneViewModel)
            .environmentObject(characterViewModel)
        }
        .sheet(item: $selectedCharacterForDetail) { characterItem in
            NavigationStack {
                CharacterDetailView(card: characterItem)
            }
        }
        .sheet(item: $selectedNoteForDetail) { noteItem in
            NavigationStack {
                NoteBlockDetailView(noteBlock: noteItem)
                    .environmentObject(noteViewModel)
                    .environmentObject(characterViewModel)
                    .environmentObject(sceneViewModel)
            }
        }
    }
}

// #Preview {
//     NavigationStack {
//         SceneDetailView(scene: AdventureScene(
//             id: UUID(),
//             title: "幽暗森林的深处",
//             description: "这是一个充满迷雾和未知危险的古老森林，据说中心地带隐藏着连接异世界的传送门。阳光很难穿透茂密的树冠，使得森林内部常年昏暗。",
//             coverImage: nil,
//             audioURL: URL(string: "https://example.com/forest_sounds.mp3"),
//             relatedCharacterIDs: [UUID(), UUID()],
//             relatedNoteIDs: [UUID()],
//             creationDate: Date().addingTimeInterval(-86400 * 30),
//             lastModifiedDate: Date().addingTimeInterval(-86400 * 5)
//         ))
//         .environmentObject(SceneViewModel.mock)
//         .environmentObject(NoteViewModel.mock)
//         .environmentObject(CharacterViewModel.mock)
//     }
// }
