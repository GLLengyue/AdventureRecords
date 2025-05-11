//  SceneDetailView.swift
//  AdventureRecords
//  场景详情视图
import SwiftUI

struct SceneDetailView: View {
    let scene: AdventureScene
    @StateObject private var viewModel = SceneViewModel()
    @State private var showImageViewer = false
    @State private var showAudioPlayer = false
    @State private var selectedAudioURL: URL?
    @State private var showNoteEditor = false
    @State private var selectedNote: NoteBlock? = nil
    @State private var selectedCharacter: CharacterCard? = nil
    
    private var relatedCharacters: [CharacterCard] {
        viewModel.getRelatedCharacters(for: scene)
    }
    
    private var relatedNotes: [NoteBlock] {
        viewModel.getRelatedNotes(for: scene)
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
                                    CharacterCardRow(character: character)
                                        .frame(width: 200)
                                        .onTapGesture {
                                            selectedCharacter = character
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
                                selectedNote = note
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
            NavigationStack {
                NoteEditorView()
            }
        }
        .sheet(item: $selectedCharacter) { characterItem in
            NavigationStack {
                CharacterDetailView(card: characterItem)
            }
        }
        .sheet(item: $selectedNote) { noteItem in
            NavigationStack {
                NoteBlockDetailView(noteBlock: noteItem)
            }
        }
        .onAppear {
            viewModel.loadScenes()
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
    }
}
