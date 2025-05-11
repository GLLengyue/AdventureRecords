//  SceneDetailView.swift
//  AdventureRecords
//  场景详情视图
import SwiftUI

struct SceneDetailView: View {
    let AdventureScene: AdventureScene
    @State private var showImageViewer = false
    @State private var showAudioPlayer = false
    @State private var selectedAudioURL: URL?
    @State private var showNoteEditor = false
    @State private var selectedNote: NoteBlock? = nil
    @State private var showCharacterDetail = false
    @State private var selectedCharacter: CharacterCard? = nil
    
    @State private var relatedCharacters: [CharacterCard] = DataModule.characterCards
    @State private var relatedNotes: [NoteBlock] = DataModule.notes
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // 场景标题和描述
                Text(AdventureScene.title).font(.largeTitle).bold()
                Text(AdventureScene.description).font(.body)
                
                // 场景图片区域（示例）
                VStack(alignment: .leading) {
                    Text("场景图片").font(.headline).padding(.top)
                    
                    // 这里应该显示场景的图片，目前使用占位图
                    Button(action: {
                        showImageViewer = true
                    }) {
                        Image(systemName: "photo")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(12)
                            .overlay(
                                Text("点击查看场景图片")
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Color.black.opacity(0.6))
                                    .cornerRadius(8)
                            )
                    }
                }
                
                if !AdventureScene.relatedCharacterIDs.isEmpty || !AdventureScene.relatedNoteIDs.isEmpty {
                    Divider().padding(.vertical, 8)
                }
                
                // 关联角色区域
                VStack(alignment: .leading) {
                    HStack {
                        Text("关联角色").font(.headline)
                        Spacer()
                        Text("\(AdventureScene.relatedCharacterIDs.count) 个")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    if AdventureScene.relatedCharacterIDs.isEmpty && relatedCharacters.isEmpty {
                        Text("暂无关联角色")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 8)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(relatedCharacters) { character in
                                    Button(action: {
                                        selectedCharacter = character
                                        showCharacterDetail = true
                                    }) {
                                        VStack {
                                            if let avatar = character.avatar {
                                                Image(uiImage: avatar)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 60, height: 60)
                                                    .clipShape(Circle())
                                            } else {
                                                Image(systemName: "person.circle.fill")
                                                    .resizable()
                                                    .frame(width: 60, height: 60)
                                                    .foregroundColor(.blue)
                                            }
                                            
                                            Text(character.name)
                                                .font(.caption)
                                                .lineLimit(1)
                                        }
                                        .frame(width: 80)
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
                
                // 关联笔记区域
                VStack(alignment: .leading) {
                    HStack {
                        Text("关联笔记").font(.headline).padding(.top)
                        Spacer()
                        Button(action: {
                            selectedNote = nil
                            showNoteEditor = true
                        }) {
                            Label("新建笔记", systemImage: "square.and.pencil")
                                .font(.caption)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                    
                    if AdventureScene.relatedNoteIDs.isEmpty && relatedNotes.isEmpty {
                        Text("暂无关联笔记")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 8)
                    } else {
                        ForEach(relatedNotes) { note in
                            Button(action: {
                                selectedNote = note
                                showNoteEditor = true
                            }) {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(note.title)
                                            .font(.headline)
                                        Spacer()
                                        Text(note.date, style: .date)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Text(note.content)
                                        .font(.subheadline)
                                        .lineLimit(2)
                                        .foregroundColor(.secondary)
                                    
                                    // 显示关联角色
                                    if !note.relatedCharacterIDs.isEmpty {
                                        HStack {
                                            ForEach(note.relatedCharacterIDs.prefix(3), id: \.self) { characterID in
                                                if let character = relatedCharacters.first(where: { $0.id == characterID }) {
                                                    Text(character.name)
                                                        .font(.caption)
                                                        .padding(.horizontal, 8)
                                                        .padding(.vertical, 4)
                                                        .background(Color.blue.opacity(0.1))
                                                        .cornerRadius(12)
                                                }
                                            }
                                            
                                            if note.relatedCharacterIDs.count > 3 {
                                                Text("+\(note.relatedCharacterIDs.count - 3)")
                                                    .font(.caption)
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 4)
                                                    .background(Color.gray.opacity(0.1))
                                                    .cornerRadius(12)
                                            }
                                        }
                                    }
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            }
                            .buttonStyle(.plain)
                            .padding(.vertical, 4)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .sheet(isPresented: $showNoteEditor) {
            if let note = selectedNote {
                NavigationStack {
                    NoteBlockDetailView(noteBlock: note)
                }
            }
        }
        .onChange(of: selectedCharacter) {
            // 当 selectedCharacter 发生变化时，触发刷新动作
            if selectedCharacter != nil {
                showCharacterDetail = true
            }
        }
        .sheet(isPresented: $showCharacterDetail) {
            if let character = selectedCharacter {
                NavigationStack {
                    CharacterDetailView(card: character)
                }
            }
        }
        .navigationTitle("场景详情")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showImageViewer) {
            // 图片查看器（示例）
            VStack {
                Text("场景图片查看器")
                    .font(.headline)
                    .padding()
                
                Image(systemName: "photo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: 300)
                
                Text("这里将显示场景的实际图片")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding()
                
                Button("关闭") {
                    showImageViewer = false
                }
                .padding()
            }
        }
        .sheet(isPresented: $showAudioPlayer) {
            // 音频播放器（示例）
            VStack {
                Text("音频播放器")
                    .font(.headline)
                    .padding()
                
                Image(systemName: "waveform")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 100)
                
                Text(selectedAudioURL?.lastPathComponent ?? "未知音频")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding()
                
                HStack {
                    Button(action: {}) {
                        Image(systemName: "play.fill")
                            .font(.title)
                    }
                    .padding()
                    
                    Button(action: {}) {
                        Image(systemName: "pause.fill")
                            .font(.title)
                    }
                    .padding()
                }
                
                Button("关闭") {
                    showAudioPlayer = false
                }
                .padding()
            }
        }
    }
}

#Preview {
    NavigationStack {
        SceneDetailView(AdventureScene: AdventureScene(
            id: UUID(), 
            title: "古老遗迹", 
            description: "充满谜团的遗迹遗址，据说曾经是一个古代文明的中心。遗迹中布满了神秘的符文和雕像，似乎在诉说着一个被遗忘的故事。", 
            relatedCharacterIDs: [UUID(), UUID()], 
            relatedNoteIDs: [UUID(), UUID(), UUID()]
        ))
    }
}
