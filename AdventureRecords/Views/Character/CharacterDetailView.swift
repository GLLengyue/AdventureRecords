//
//  CharacterDetailView.swift
//  AdventureRecords
//
//  Created by Lengyue's Macbook on 2025/5/10.
//

import SwiftUI

import AVFoundation

struct CharacterDetailView: View {
    @StateObject private var audioPlayerManager = AudioPlayerManager()
    let character: Character
    @EnvironmentObject var characterViewModel: CharacterViewModel
    @EnvironmentObject var noteViewModel: NoteViewModel
    @EnvironmentObject var sceneViewModel: SceneViewModel

    @State private var showNoteEditor = false
    @State private var showCharacterEditor = false
    @State private var selectedNoteForDetail: NoteBlock? = nil
    @State private var selectedSceneForDetail: AdventureScene? = nil
    @State private var isDescriptionExpanded: Bool = false
    @State private var showImmersiveMode = false // 新增状态：控制沉浸模式显示
    
    var relatedNotes: [NoteBlock] {
        character.relatedNotes(in: noteViewModel.notes)
    }
    var relatedScenes: [AdventureScene] {
        character.relatedScenes(in: noteViewModel.notes, sceneProvider: { note in
            note.relatedScenes(in: sceneViewModel.scenes)
        })
    }

    // 最佳实践：直接用全局音频数据过滤出属于当前角色的录音
    @EnvironmentObject var audioViewModel: AudioViewModel
    private var relatedRecordings: [AudioRecording] {
        guard let ids = character.audioRecordings?.map({ $0.id }) else { return [] }
        return audioViewModel.recordings.filter { ids.contains($0.id) }
    }
    
    var body: some View {
        DetailContainer(module: .character, title: character.name, backAction: {}, editAction: { showCharacterEditor = true }) {
            VStack(alignment: .leading, spacing: 20) {
                // 角色头像和基本信息
                HStack(alignment: .center, spacing: 16) {
                    if let avatar = character.avatar {
                        Image(uiImage: avatar)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(ThemeManager.shared.accentColor(for: .character), lineWidth: 2))
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .foregroundColor(ThemeManager.shared.accentColor(for: .character))
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(character.name)
                            .font(.largeTitle)
                            .bold()
                    }
                }
                .padding(.bottom)
                
                // 简介
                VStack(alignment: .leading) {
                    Text(character.description)
                        .font(.body)
                        .lineLimit(isDescriptionExpanded ? nil : 3) // 根据状态限制行数
                    
                    if character.description.count > 100 { // 仅当描述较长时显示展开/收起按钮 (可调整字数阈值)
                        Button(action: {
                            withAnimation {
                                isDescriptionExpanded.toggle()
                            }
                        }) {
                            Text(isDescriptionExpanded ? "收起" : "展开")
                                .font(.caption)
                                .foregroundColor(ThemeManager.shared.accentColor(for: .character))
                        }
                        .padding(.top, 2)
                    }
                }
                
                // 标签
                if !character.tags.isEmpty {
                    Section(header: Text("标签").font(.headline)) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(character.tags, id: \.self) { tag in
                                    Text(tag)
                                        .font(.caption)
                                        .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                                        .background(ThemeManager.shared.accentColor(for: .character).opacity(0.15))
                                        .clipShape(Capsule())
                                }
                            }
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
                
                // 相关场景
                if !relatedScenes.isEmpty {
                    Section(header: Text("相关场景 (\(relatedScenes.count))").font(.headline)) {
                        ForEach(relatedScenes) { scene in
                            Button(action: { selectedSceneForDetail = scene }) {
                                HStack {
                                    Text(scene.title).foregroundColor(ThemeManager.shared.primaryTextColor)
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
                
                // 相关录音
                if !relatedRecordings.isEmpty {
                    Section(header: Text("相关录音 (\(relatedRecordings.count))").font(.headline)) {
                        ForEach(relatedRecordings) { recording in
                            let audioURL = recording.recordingURL
                            HStack {
                                Text(recording.title)
                                    .foregroundColor(ThemeManager.shared.primaryTextColor)
                                Spacer()
                                Button {
                                    if audioPlayerManager.isPlaying && audioPlayerManager.currentlyPlayingURL == audioURL {
                                        audioPlayerManager.pause()
                                    } else {
                                        guard audioURL.isFileURL, FileManager.default.fileExists(atPath: audioURL.path) else {
                                            print("Audio file not found at \(audioURL.path)")
                                            // Consider showing an alert to the user here
                                                return
                                            }
                                            audioPlayerManager.play(url: audioURL)
                                        }
                                    } label: {
                                        Image(systemName: audioPlayerManager.isPlaying && audioPlayerManager.currentlyPlayingURL == audioURL ? "pause.circle.fill" : "play.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(ThemeManager.shared.accentColor(for: .character))
                                    }
                                }
                                .padding()
                                .background(ThemeManager.shared.secondaryBackgroundColor)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.bottom) // Add some spacing after the audio section
                }

                // 沉浸模式入口按钮
                Button(action: { showImmersiveMode = true }) {
                    Label("进入沉浸模式", systemImage: "arrow.up.left.and.arrow.down.right.circle.fill")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(ThemeManager.shared.accentColor(for: .character))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.top)
                // 新建关联笔记按钮 - 移至内容区，更符合"底部操作区"的感觉
                Button(action: { showNoteEditor = true }) {
                    Label("新建关联笔记", systemImage: "plus.circle.fill")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(ThemeManager.shared.accentColor(for: .character))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Spacer()
            }
        .onDisappear {
            audioPlayerManager.stopAndDeactivateSession()
        }
        .sheet(isPresented: $showNoteEditor) {
            NoteEditorView(
                preselectedCharacterID: character.id,
                onSave: { newNote in
                    noteViewModel.addNote(newNote)
                    showNoteEditor = false
                },
                onCancel: {
                    showNoteEditor = false
                }
            )
        }
        .sheet(isPresented: $showCharacterEditor) {
            CharacterEditorView(
                card: character,
                onSave: { updatedCard in
                    characterViewModel.updateCharacter(updatedCard)
                    showCharacterEditor = false
                },
                onCancel: {
                    showCharacterEditor = false
                }
            )
            .environmentObject(characterViewModel)
        }
        .sheet(item: $selectedNoteForDetail) { noteItem in
            NavigationStack {
                NoteBlockDetailView(noteBlock: noteItem)
            }
        }
        .sheet(item: $selectedSceneForDetail) { sceneItem in
            NavigationStack {
                SceneDetailView(scene: sceneItem)
            }
        }
        .fullScreenCover(isPresented: $showImmersiveMode) { // 使用 fullScreenCover 展示沉浸模式
            ImmersiveModeView(content: .character(character))
        }
    }
}