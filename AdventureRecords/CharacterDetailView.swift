//
//  CharacterCardDetailView.swift
//  AdventureRecords
//
//  Created by Lengyue's Macbook on 2025/5/10.
//

import SwiftUI

struct CharacterDetailView: View {
    let card: CharacterCard
    @State private var showNoteEditor = false
    @State private var showNoteDetail = false
    @State private var selectedNote: NoteBlock? = nil
    @State private var showSceneDetail = false
    @State private var selectedScene: AdventureScene? = nil

    // 示例数据，实际应用中应从数据存储中获取
    @State private var relatedNotes: [NoteBlock] = [
        NoteBlock(id: UUID(), title: "初遇", content: "主角在酒馆邂逅神秘人。", relatedCharacterIDs: [], relatedSceneIDs: [], date: Date()),
        NoteBlock(id: UUID(), title: "遗迹探索", content: "队伍进入古老遗迹，发现线索。", relatedCharacterIDs: [], relatedSceneIDs: [], date: Date())
    ]

    @State private var relatedScenes: [AdventureScene] = [
        AdventureScene(id: UUID(), title: "古老遗迹", description: "充满谜团的遗迹遗址。", relatedCharacterIDs: [], relatedNoteIDs: []),
        AdventureScene(id: UUID(), title: "王都广场", description: "热闹非凡的城市中心。", relatedCharacterIDs: [], relatedNoteIDs: [])
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // 角色基本信息
                HStack {
                    if let avatar = card.avatar {
                        Image(uiImage: avatar)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .frame(width: 100, height: 100)
                    }
                    VStack(alignment: .leading) {
                        Text(card.name).font(.largeTitle).bold()
                        Text(card.description).font(.body)
                    }
                }

                Text("标签: " + card.tags.joined(separator: ", "))
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                // 相关场景部分
                if !card.sceneIDs.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("相关场景")
                                .font(.headline)
                            Spacer()
                            Text("\(card.sceneIDs.count) 个")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(relatedScenes) { scene in
                                    Button(action: {
                                        selectedScene = scene
                                        showSceneDetail = true
                                    }) {
                                        VStack(alignment: .leading) {
                                            Image(systemName: "map")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 60, height: 60)
                                                .foregroundColor(.blue)
                                                .padding(8)
                                                .background(Color.blue.opacity(0.1))
                                                .clipShape(RoundedRectangle(cornerRadius: 12))

                                            Text(scene.title)
                                                .font(.caption)
                                                .lineLimit(1)
                                                .frame(width: 80)
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }

                // 相关笔记部分
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("相关笔记")
                            .font(.headline)
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
                    .padding(.top)

                    if card.noteIDs.isEmpty && relatedNotes.isEmpty {
                        Text("暂无相关笔记")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 8)
                    } else {
                        ForEach(relatedNotes) { note in
                            Button(action: {
                                selectedNote = note
                                // showNoteEditor = true
                                showNoteDetail = true
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
            NoteEditorView(note: selectedNote, preselectedCharacterID: card.id)
        }
        .sheet(isPresented: $showNoteDetail) {
            if let note = selectedNote  {
                NavigationStack {
                    NoteBlockDetailView(noteBlock: note)
                }
            }
        }
        .onChange(of: selectedNote) {
            // 当 showingNote 发生变化时，触发刷新动作
            if selectedNote != nil {
                showNoteDetail = true
            }
        }

        .sheet(isPresented: $showSceneDetail) {
            if let scene = selectedScene {
                SceneDetailView(AdventureScene: scene)
            }
        }
        .navigationTitle("角色详情")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        CharacterDetailView(card: DataModule.characterCards.first!)
    }
}
