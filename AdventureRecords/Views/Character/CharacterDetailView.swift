//
//  CharacterCardDetailView.swift
//  AdventureRecords
//
//  Created by Lengyue's Macbook on 2025/5/10.
//

import SwiftUI

struct CharacterDetailView: View {
    let card: CharacterCard
    @EnvironmentObject var characterViewModel: CharacterViewModel
    @EnvironmentObject var noteViewModel: NoteViewModel
    @EnvironmentObject var sceneViewModel: SceneViewModel

    @State private var showNoteEditor = false
    @State private var showCharacterEditor = false
    @State private var selectedNoteForDetail: NoteBlock? = nil
    @State private var selectedSceneForDetail: AdventureScene? = nil
    
    private var relatedNotes: [NoteBlock] {
        noteViewModel.notes.filter { card.noteIDs.contains($0.id) }
    }
    
    private var relatedScenes: [AdventureScene] {
        sceneViewModel.scenes.filter { card.sceneIDs.contains($0.id) }
    }
    
    var body: some View {
        DetailContainer(module: .character, title: card.name, backAction: {}, editAction: { showCharacterEditor = true }) {
            VStack(alignment: .leading, spacing: 20) {
                // 角色头像和基本信息
                HStack(alignment: .center, spacing: 16) {
                    if let avatar = card.avatar {
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
                        Text(card.name)
                            .font(.largeTitle)
                            .bold()
                    }
                }
                .padding(.bottom)
                
                // 简介
                Text(card.description)
                    .font(.body)
                
                // 标签
                if !card.tags.isEmpty {
                    Section(header: Text("标签").font(.headline)) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(card.tags, id: \.self) { tag in
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
                .padding(.top)
                
                Spacer()
            }
        }
        .sheet(isPresented: $showNoteEditor) {
            NoteEditorView(
                preselectedCharacterID: card.id,
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
                card: card,
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
                    .environmentObject(sceneViewModel)
                    .environmentObject(noteViewModel)
                    .environmentObject(characterViewModel)
            }
        }
    }
}