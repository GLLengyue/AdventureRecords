//
//  CharacterDetailView.swift
//  AdventureRecords
//
//  Created by Lengyue's Macbook on 2025/5/10.
//

import AVFoundation
import SwiftUI

struct CharacterDetailView: View {
    @StateObject private var audioPlayerManager = AudioPlayerManager()
    let CharacterID: UUID
    // let character: Character

    // 使用单例
    @StateObject private var characterViewModel = CharacterViewModel.shared
    @StateObject private var noteViewModel = NoteViewModel.shared
    @StateObject private var sceneViewModel = SceneViewModel.shared
    @StateObject private var audioViewModel = AudioViewModel.shared

    @State private var showNoteEditor = false
    @State private var showCharacterEditor = false
    @State private var selectedNoteForDetail: NoteBlock? = nil
    @State private var selectedSceneForDetail: AdventureScene? = nil
    @State private var isDescriptionExpanded: Bool = false
    @State private var selectedRecordingForPlayback: AudioRecording? = nil

    private var character: Character? {
        characterViewModel.getCharacter(id: CharacterID)
    }

    private var relatedNotes: [NoteBlock] {
        guard let character = character else { return [] }
        return character.relatedNotes(in: noteViewModel.notes)
    }

    private var relatedScenes: [AdventureScene] {
        guard let character = character else { return [] }
        return character.relatedScenes(in: noteViewModel.notes, sceneProvider: { note in
            note.relatedScenes(in: sceneViewModel.scenes)
        })
    }

    // 获取与角色相关的录音
    private var relatedRecordings: [AudioRecording] {
        guard let character = character,
              let ids = character.audioRecordings?.map({ $0.id }) else { return [] }
        return audioViewModel.recordings.filter { ids.contains($0.id) }
    }

    var body: some View {
        Group {
            if let character = character {
                DetailContainer(module: .character, title: character.name, backAction: {},
                                editAction: { showCharacterEditor = true })
                {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                    // 角色头像和基本信息
                    HStack(alignment: .center, spacing: 20) {
                        if let avatar = character.avatar {
                            Image(uiImage: avatar)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .overlay(Circle()
                                    .stroke(ThemeManager.shared.accentColor(for: .character), lineWidth: 2))
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        } else {
                            ZStack {
                                Circle()
                                    .fill(ThemeManager.shared.accentColor(for: .character).opacity(0.1))
                                    .frame(width: 100, height: 100)

                                Image(systemName: "person.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(ThemeManager.shared.accentColor(for: .character))
                            }
                            .overlay(Circle()
                                .stroke(ThemeManager.shared.accentColor(for: .character).opacity(0.3),
                                        lineWidth: 1.5))
                            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 1)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(character.name)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(ThemeManager.shared.primaryTextColor)

                            if !character.tags.isEmpty {
                                Text(character.tags.prefix(3).joined(separator: " • "))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 8)

                    Divider()
                        .padding(.vertical, 8)

                    // 简介
                    VStack(alignment: .leading, spacing: 12) {
                        Label("角色简介", systemImage: "text.quote")
                            .font(.headline)
                            .foregroundColor(ThemeManager.shared.accentColor(for: .character))

                        Text(character.description)
                            .font(.body)
                            .foregroundColor(ThemeManager.shared.primaryTextColor)
                            .lineLimit(isDescriptionExpanded ? nil : 3)
                            .fixedSize(horizontal: false, vertical: true)

                        if character.description.count > 100 {
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
                                .foregroundColor(ThemeManager.shared.accentColor(for: .character))
                                .padding(.vertical, 4)
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                    }
                    .padding(.bottom, 8)

                    // 标签
                    if !character.tags.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("标签", systemImage: "tag")
                                .font(.headline)
                                .foregroundColor(ThemeManager.shared.accentColor(for: .character))

                            FlowLayout(spacing: 8) {
                                ForEach(character.tags, id: \.self) { tag in
                                    TagView(tag: tag, accentColor: ThemeManager.shared.accentColor(for: .character))
                                }
                            }
                        }
                        .padding(.bottom, 16)
                    }

                    // 相关录音
                    if !relatedRecordings.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("相关录音 (\(relatedRecordings.count))", systemImage: "waveform")
                                .font(.headline)
                                .foregroundColor(ThemeManager.shared.accentColor(for: .character))

                            VStack(spacing: 10) {
                                ForEach(relatedRecordings) { recording in
                                    RecordingItemView(recording: recording,
                                                      isPlaying: audioPlayerManager.isPlaying && audioPlayerManager
                                                          .currentlyPlayingURL == recording.recordingURL,
                                                      onPlayPause: {
                                                          let audioURL = recording.recordingURL
                                                          if audioPlayerManager.isPlaying && audioPlayerManager
                                                              .currentlyPlayingURL == audioURL
                                                          {
                                                              audioPlayerManager.pause()
                                                          } else {
                                                              guard audioURL.isFileURL,
                                                                    FileManager.default
                                                                    .fileExists(atPath: audioURL.path)
                                                              else {
                                                                  debugPrint("Audio file not found at \(audioURL.path)")
                                                                  return
                                                              }
                                                              audioPlayerManager.play(url: audioURL)
                                                          }
                                                      })
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

                    // 相关场景
                    if !relatedScenes.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("相关场景 (\(relatedScenes.count))", systemImage: "film")
                                .font(.headline)
                                .foregroundColor(ThemeManager.shared.accentColor(for: .scene))

                            VStack(spacing: 10) {
                                ForEach(relatedScenes) { scene in
                                    SceneItemView(scene: scene) {
                                        selectedSceneForDetail = scene
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
                            Text("新建关联笔记")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(RoundedRectangle(cornerRadius: 12)
                            .fill(ThemeManager.shared.accentColor(for: .character)))
                        .foregroundColor(.white)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .padding(.vertical, 8)

                    Spacer(minLength: 40)
                }
                .padding(.horizontal)
            }
            .background(ThemeManager.shared.backgroundColor)
            .onDisappear {
                audioPlayerManager.stopAndDeactivateSession()
            }
        }
        .sheet(isPresented: $showNoteEditor) {
            NoteEditorView(preselectedCharacterID: character.id,
                           onSave: { newNote in
                               noteViewModel.addNote(newNote)
                               showNoteEditor = false
                           },
                           onCancel: {
                               showNoteEditor = false
                           })
        }
        .sheet(isPresented: $showCharacterEditor) {
            CharacterEditorView(card: character,
                                onSave: { updatedCard in
                                    characterViewModel.updateCharacter(updatedCard)
                                    showCharacterEditor = false
                                },
                                onCancel: {
                                    showCharacterEditor = false
                                })
        }
        .sheet(item: $selectedNoteForDetail) { noteItem in
            NavigationStack {
                NoteBlockDetailView(noteID: noteItem.id)
            }
        }
        .sheet(item: $selectedSceneForDetail) { sceneItem in
            NavigationStack {
                SceneDetailView(sceneID: sceneItem.id)
            }
        }
            } else {
                Text("无法找到角色")
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - 辅助视图组件

// 标签视图
struct TagView: View {
    let tag: String
    let accentColor: Color

    var body: some View {
        Text(tag)
            .font(.caption)
            .padding(EdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10))
            .background(accentColor.opacity(0.15))
            .foregroundColor(accentColor)
            .clipShape(Capsule())
            .overlay(Capsule()
                .stroke(accentColor.opacity(0.3), lineWidth: 1))
    }
}

// 录音项视图
struct RecordingItemView: View {
    let recording: AudioRecording
    let isPlaying: Bool
    let onPlayPause: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // 播放按钮
            Button(action: onPlayPause) {
                ZStack {
                    Circle()
                        .fill(ThemeManager.shared.accentColor(for: .character).opacity(0.15))
                        .frame(width: 44, height: 44)

                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(ThemeManager.shared.accentColor(for: .character))
                }
            }
            .buttonStyle(ScaleButtonStyle())

            // 录音信息
            VStack(alignment: .leading, spacing: 4) {
                Text(recording.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(ThemeManager.shared.primaryTextColor)

                // 录音日期和时长
                HStack(spacing: 8) {
                    // if let duration = recording.duration {
                    //     Label(formatDuration(duration), systemImage: "clock")
                    //         .font(.caption)
                    //         .foregroundColor(.secondary)
                    // }

                    // if var date = recording.date {
                    Text(formatDate(recording.date))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    // }
                }
            }

            Spacer()
        }
        .padding(EdgeInsets(top: 10, leading: 12, bottom: 10, trailing: 12))
        .background(ThemeManager.shared.secondaryBackgroundColor)
        .cornerRadius(12)
        .contentShape(Rectangle())
    }

    // 格式化录音时长
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    // 格式化日期
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
