//  SceneDetailView.swift
//  AdventureRecords
//  场景详情视图
import AVFoundation
import SwiftUI

struct SceneDetailView: View {
    @StateObject private var audioPlayerManager = AudioPlayerManager()
    let sceneID: UUID

    // 使用单例
    @StateObject private var sceneViewModel = SceneViewModel.shared
    @StateObject private var noteViewModel = NoteViewModel.shared
    @StateObject private var characterViewModel = CharacterViewModel.shared

    @State private var showImageViewer = false
    @State private var showNoteEditor = false
    @State private var showSceneEditor = false
    @State private var selectedNoteForDetail: NoteBlock? = nil
    @State private var selectedCharacterForDetail: Character? = nil
    @State private var isDescriptionExpanded: Bool = false

    private var scene: AdventureScene? {
        sceneViewModel.getScene(id: sceneID)
    }

    private var relatedNotes: [NoteBlock] {
        guard let scene = scene else { return [] }
        return scene.relatedNotes(in: noteViewModel.notes)
    }

    private var relatedCharacters: [Character] {
        guard let scene = scene else { return [] }
        return scene.relatedCharacters(in: noteViewModel.notes, characterProvider: { note in
            note.relatedCharacters(in: characterViewModel.characters)
        })
    }

    var body: some View {
        Group {
            if let scene = scene {
                DetailContainer(module: .scene, title: scene.title, backAction: { /* 由导航处理 */ },
                                editAction: { showSceneEditor = true })
                {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                    // 场景图片区域
                    ZStack(alignment: .bottomLeading) {
                        if let coverImage = scene.coverImage {
                            Image(uiImage: coverImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 220)
                                .clipped()
                                .overlay(LinearGradient(gradient: Gradient(colors: [
                                        Color.black.opacity(0.6),
                                        Color.black.opacity(0),
                                    ]),
                                    startPoint: .bottom,
                                    endPoint: .center))
                        } else {
                            Rectangle()
                                .fill(ThemeManager.shared.accentColor(for: .scene).opacity(0.15))
                                .frame(height: 180)
                                .overlay(Image(systemName: "photo.on.rectangle.angled")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(ThemeManager.shared.accentColor(for: .scene).opacity(0.5)))
                        }

                        // 标题和日期可以直接显示在图片上
                        VStack(alignment: .leading, spacing: 6) {
                            Text(scene.title)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(Color.white)
                                .shadow(color: Color.black.opacity(0.5), radius: 2, x: 0, y: 1)
                                .foregroundColor(Color.white.opacity(0.9))
                                .shadow(color: Color.black.opacity(0.5), radius: 2, x: 0, y: 1)
                        }
                        .padding([.leading, .bottom], 16)
                    }
                    .cornerRadius(12)
                    .onTapGesture { showImageViewer = true }
                    .padding(.horizontal, 16)

                    // 音频播放区
                    if let audioURL = scene.audioURL {
                        HStack(spacing: 12) {
                            Button(action: {
                                if audioPlayerManager.isPlaying && audioPlayerManager.currentlyPlayingURL == audioURL {
                                    audioPlayerManager.pause()
                                } else {
                                    guard audioURL.isFileURL,
                                          FileManager.default.fileExists(atPath: audioURL.path)
                                    else {
                                        debugPrint("Audio file not found at \(audioURL.path)")
                                        return
                                    }
                                    audioPlayerManager.play(url: audioURL)
                                }
                            }) {
                                HStack {
                                    Image(systemName: audioPlayerManager.isPlaying && audioPlayerManager
                                        .currentlyPlayingURL == audioURL ? "pause.circle.fill" : "play.circle.fill")
                                        .font(.title2)
                                    Text(audioPlayerManager.isPlaying && audioPlayerManager
                                        .currentlyPlayingURL == audioURL ? "暂停场景音频" : "播放场景音频")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(ThemeManager.shared.accentColor(for: .scene).opacity(0.15))
                                .foregroundColor(ThemeManager.shared.accentColor(for: .scene))
                                .cornerRadius(20)
                                .overlay(RoundedRectangle(cornerRadius: 20)
                                    .stroke(ThemeManager.shared.accentColor(for: .scene).opacity(0.3),
                                            lineWidth: 1))
                            }
                            .buttonStyle(ScaleButtonStyle())

                            // 播放波形模拟
                            if audioPlayerManager.isPlaying && audioPlayerManager.currentlyPlayingURL == audioURL {
                                HStack(spacing: 2) {
                                    ForEach(0 ..< 8, id: \.self) { index in
                                        RoundedRectangle(cornerRadius: 1.5)
                                            .fill(ThemeManager.shared.accentColor(for: .scene))
                                            .frame(width: 3, height: CGFloat.random(in: 8 ... 20))
                                            .animation(Animation.easeInOut(duration: 0.6)
                                                .repeatForever(autoreverses: true)
                                                .delay(Double.random(in: 0 ... 0.6)),
                                                value: audioPlayerManager.isPlaying)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                    }

                    VStack(alignment: .leading, spacing: 20) {
                        // 场景描述
                        VStack(alignment: .leading, spacing: 12) {
                            Label("场景简介", systemImage: "text.alignleft")
                                .font(.headline)
                                .foregroundColor(ThemeManager.shared.accentColor(for: .scene))

                            Text(scene.description)
                                .font(.body)
                                .foregroundColor(ThemeManager.shared.primaryTextColor)
                                .lineLimit(isDescriptionExpanded ? nil : 3)
                                .fixedSize(horizontal: false, vertical: true)

                            if scene.description.count > 100 {
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        isDescriptionExpanded.toggle()
                                    }
                                }) {
                                    HStack(spacing: 4) {
                                        Text(isDescriptionExpanded ? "收起内容" : "展开全部")
                                            .font(.caption)
                                        Image(systemName: isDescriptionExpanded ? "chevron.up" : "chevron.down")
                                            .font(.caption)
                                    }
                                    .foregroundColor(ThemeManager.shared.accentColor(for: .scene))
                                    .padding(.vertical, 4)
                                }
                                .buttonStyle(ScaleButtonStyle())
                            }
                        }

                        Divider()
                            .padding(.vertical, 8)

                        // 场景标签
                        if !scene.tags.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Label("标签", systemImage: "tag")
                                    .font(.headline)
                                    .foregroundColor(ThemeManager.shared.accentColor(for: .scene))

                                FlowLayout(spacing: 8) {
                                    ForEach(scene.tags, id: \.self) { tag in
                                        TagView(tag: tag, accentColor: ThemeManager.shared.accentColor(for: .scene))
                                    }
                                }
                            }
                            .padding(.bottom, 16)
                        }

                        Divider()
                            .padding(.vertical, 8)

                        // 相关角色
                        if !relatedCharacters.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Label("出场角色 (\(relatedCharacters.count))", systemImage: "person.2")
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
                            .padding(.bottom, 16)
                        }

                        // 相关笔记
                        if !relatedNotes.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Label("相关笔记 (\(relatedNotes.count))", systemImage: "doc.text")
                                    .font(.headline)
                                    .foregroundColor(ThemeManager.shared.accentColor(for: .note))

                                VStack(spacing: 10) {
                                    ForEach(relatedNotes) { note in
                                        NoteItemView(note: note) {
                                            selectedNoteForDetail = note
                                        }
                                    }
                                }
                            }
                            .padding(.bottom, 16)
                        }

                        // 新建关联笔记按钮
                        Button(action: { showNoteEditor = true }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.headline)
                                Text("在当前场景下新建笔记")
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(RoundedRectangle(cornerRadius: 12)
                                .fill(ThemeManager.shared.accentColor(for: .scene)))
                            .foregroundColor(.white)
                        }
                        .buttonStyle(ScaleButtonStyle())
                        .padding(.vertical, 8)
                    }
                    .padding(.horizontal)

                    Spacer(minLength: 40)
                }
            }
            .background(ThemeManager.shared.backgroundColor)
            .onDisappear {
                audioPlayerManager.stopAndDeactivateSession()
            }
        }
        .sheet(isPresented: $showImageViewer) {
            ZStack(alignment: .topTrailing) {
                if let coverImage = scene.coverImage {
                    GeometryReader { geometry in
                        Image(uiImage: coverImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipped()
                    }
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .foregroundColor(ThemeManager.shared.accentColor(for: .scene).opacity(0.7))

                        Text("暂无场景图片")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                }

                Button(action: {
                    showImageViewer = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Circle())
                        .padding()
                }
            }
            .edgesIgnoringSafeArea(.all)
            .background(Color.black)
        }
        .sheet(isPresented: $showNoteEditor) {
            NoteEditorView(preselectedSceneID: scene.id,
                           onSave: { newNote in
                               noteViewModel.addNote(newNote)
                               showNoteEditor = false
                           },
                           onCancel: {
                               showNoteEditor = false
                           })
        }
        .sheet(isPresented: $showSceneEditor) {
            SceneEditorView(scene: scene,
                            onSave: { updatedScene in
                                sceneViewModel.updateScene(updatedScene)
                                showSceneEditor = false
                            },
                            onCancel: {
                                showSceneEditor = false
                            })
        }
        .sheet(item: $selectedCharacterForDetail) { characterItem in
            NavigationStack {
                CharacterDetailView(CharacterID: characterItem.id)
            }
        }
        .sheet(item: $selectedNoteForDetail) { noteItem in
            NavigationStack {
                NoteBlockDetailView(noteID: noteItem.id)
            }
        }
            } else {
                Text("无法找到场景")
                    .foregroundColor(.secondary)
            }
        }
    }
}
