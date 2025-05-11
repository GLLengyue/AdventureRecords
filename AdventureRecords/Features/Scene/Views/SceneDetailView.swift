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
    @State private var showCharacterDetail = false
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
                                            showCharacterDetail = true
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
        .sheet(isPresented: $showNoteEditor) {
            NavigationStack {
                NoteEditorView()
            }
        }
        .sheet(isPresented: $showCharacterDetail) {
            if let character = selectedCharacter {
                NavigationStack {
                    CharacterDetailView(card: character)
                }
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
