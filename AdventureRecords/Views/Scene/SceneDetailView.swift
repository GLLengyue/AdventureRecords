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
    @State private var selectedNoteForDetail: NoteBlock? = nil
    @State private var selectedCharacterForDetail: CharacterCard? = nil
    
    private var relatedCharacters: [CharacterCard] {
        sceneViewModel.getRelatedCharacters(for: scene)
    }
    
    private var relatedNotes: [NoteBlock] {
        sceneViewModel.getRelatedNotes(for: scene)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // 场景标题和描述
                Text(scene.title).font(.largeTitle).bold()
                Text(scene.description).font(.body)
                
                // 场景图片区域（示例）
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 200)
                    .overlay(
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.gray)
                    )
                    .onTapGesture {
                        showImageViewer = true
                    }
                
                // 新增播放音频按钮
                Button("播放场景音频 (占位符)") {
                    selectedAudioURL = URL(string: "https://example.com/placeholder_audio.mp3") // 示例 URL
                    showAudioPlayer = true
                }
                .padding(.top)
                
                // 相关角色
                if !relatedCharacters.isEmpty {
                    VStack(alignment: .leading) {
                        Text("相关角色").font(.headline)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(relatedCharacters) { character in
                                    CharacterCardRow(
                                        character: character,
                                        onDelete: { print("Delete from SceneDetailView not implemented") },
                                        onEdit: { _ in print("Edit from SceneDetailView not implemented") },
                                        getRelatedNotes: { characterViewModel.getRelatedNotes(for: character) },
                                        getRelatedScenes: { characterViewModel.getRelatedScenes(for: character) }
                                    )
                                    .frame(width: 200)
                                    .onTapGesture {
                                        selectedCharacterForDetail = character
                                    }
                                }
                            }
                        }
                    }
                }
                
                // 相关笔记
                if !relatedNotes.isEmpty {
                    VStack(alignment: .leading) {
                        Text("相关笔记").font(.headline)
                        ForEach(relatedNotes) { note in
                            VStack(alignment: .leading) {
                                Text(note.title).font(.title3)
                                Text(note.content).lineLimit(3)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                            .onTapGesture {
                                selectedNoteForDetail = note
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showNoteEditor = true }) {
                    Image(systemName: "square.and.pencil")
                }
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
                onSave: { newNote in
                    var noteWithScene = newNote
                    if !noteWithScene.relatedSceneIDs.contains(scene.id) {
                        noteWithScene.relatedSceneIDs.append(scene.id)
                    }
                    noteViewModel.addNote(noteWithScene)
                    showNoteEditor = false
                }, 
                onCancel: { 
                    showNoteEditor = false
                }
            )
        }
        .sheet(item: $selectedCharacterForDetail) { characterItem in
            NavigationStack {
                CharacterDetailView(card: characterItem)
            }
        }
        .sheet(item: $selectedNoteForDetail) { noteItem in
            NavigationStack {
                NoteBlockDetailView(noteBlock: noteItem)
            }
        }
    }
}

#Preview {
    NavigationStack {
        SceneDetailView(scene: AdventureScene(
            id: UUID(),
            title: "预览场景",
            description: "这是一个预览用的场景描述",
            relatedCharacterIDs: [],
            relatedNoteIDs: []
        ))
        .environmentObject(SceneViewModel())
        .environmentObject(NoteViewModel())
        .environmentObject(CharacterViewModel())
    }
}
