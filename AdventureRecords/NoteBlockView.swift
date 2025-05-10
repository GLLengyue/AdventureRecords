//  NoteBlockView.swift
//  AdventureRecords
//  笔记块列表视图
import SwiftUI

struct NoteBlockView: View {
    @State private var notes: [NoteBlock] = DataModule.notes
    @State private var showEditor = false
    @State private var showingNote: NoteBlock? = nil
    @State private var showCharacterDetail = false
    @State private var selectedCharacter: CharacterCard? = nil
    @State private var showSceneDetail = false
    @State private var selectedScene: AdventureScene? = nil
    @State private var showDetail = false
    
    @State private var availableCharacters: [CharacterCard] = DataModule.characterCards
    @State private var availableScenes: [AdventureScene] = DataModule.availableScenes
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(notes) { note in
                    VStack(alignment: .leading, spacing: 8) {
                        Button(action: {
                            debugPrint("点击了笔记块")
                            showingNote = note
                            showDetail = true
                        }) {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(note.title).font(.headline)
                                    Spacer()
                                    Text(note.date, style: .date).font(.caption).foregroundColor(.secondary)
                                }
                                Text(note.content).font(.subheadline).lineLimit(2)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        
                        // 关联角色标签
                        if !note.relatedCharacterIDs.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    Text("角色:").font(.caption).foregroundColor(.secondary)
                                    
                                    ForEach(note.relatedCharacterIDs, id: \.self) { characterID in
                                        Button(action: {
                                            // 查找角色并显示详情
                                            if let character = findCharacter(by: characterID) {
                                                selectedCharacter = character
                                                showCharacterDetail = true
                                            }
                                        }) {
                                            if let character = findCharacter(by: characterID) {
                                                Text(character.name)
                                                    .font(.caption)
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 4)
                                                    .background(Color.blue.opacity(0.1))
                                                    .cornerRadius(12)
                                            } else {
                                                Text("未知角色")
                                                    .font(.caption)
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 4)
                                                    .background(Color.gray.opacity(0.1))
                                                    .cornerRadius(12)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        
                        // 关联场景标签
                        if !note.relatedSceneIDs.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    Text("场景:").font(.caption).foregroundColor(.secondary)
                                    
                                    ForEach(note.relatedSceneIDs, id: \.self) { sceneID in
                                        Button(action: {
                                            // 查找场景并显示详情
                                            if let scene = findScene(by: sceneID) {
                                                selectedScene = scene
                                                showSceneDetail = true
                                            }
                                        }) {
                                            if let scene = findScene(by: sceneID) {
                                                Text(scene.title)
                                                    .font(.caption)
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 4)
                                                    .background(Color.green.opacity(0.1))
                                                    .cornerRadius(12)
                                            } else {
                                                Text("未知场景")
                                                    .font(.caption)
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 4)
                                                    .background(Color.gray.opacity(0.1))
                                                    .cornerRadius(12)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("笔记块")
            .toolbar {
                Button(action: {
                    showEditor = true
                }) {
                    Label("新建笔记", systemImage: "square.and.pencil")
                }
            }
            .sheet(isPresented: $showEditor) {
                NoteEditorView(note: nil)
            }
            .sheet(isPresented: $showDetail) {
                if let note = showingNote {
                    NavigationStack {
                        NoteBlockDetailView(noteBlock: note)
                    }
                }
            }
            .onChange(of: showingNote) {
                // 当 showingNote 发生变化时，触发刷新动作
                if showingNote != nil {
                    showDetail = true
                }
            }
            .sheet(isPresented: $showCharacterDetail) {
                if let character = selectedCharacter {
                    NavigationStack {
                        CharacterDetailView(card: character)
                    }
                }
            }
            .sheet(isPresented: $showSceneDetail) {
                if let scene = selectedScene {
                    NavigationStack {
                        SceneDetailView(AdventureScene: scene)
                    }
                }
            }
        }
    }
    
    // 根据ID查找角色
    private func findCharacter(by id: UUID) -> CharacterCard? {
        return availableCharacters.first { $0.id == id }
    }
    
    // 根据ID查找场景
    private func findScene(by id: UUID) -> AdventureScene? {
        return availableScenes.first { $0.id == id }
    }
}

#Preview {
    NoteBlockView()
}
