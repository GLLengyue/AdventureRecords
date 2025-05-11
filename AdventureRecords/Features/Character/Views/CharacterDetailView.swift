//
//  CharacterCardDetailView.swift
//  AdventureRecords
//
//  Created by Lengyue's Macbook on 2025/5/10.
//

import SwiftUI

struct CharacterDetailView: View {
    let card: CharacterCard
    @StateObject private var viewModel = CharacterViewModel()
    @State private var showNoteEditor = false
    @State private var selectedNote: NoteBlock? = nil
    @State private var selectedScene: AdventureScene? = nil
    
    private var relatedNotes: [NoteBlock] {
        viewModel.getRelatedNotes(for: card)
    }
    
    private var relatedScenes: [AdventureScene] {
        viewModel.getRelatedScenes(for: card)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // 角色头像和基本信息
                HStack(alignment: .top, spacing: 16) {
                    if let avatar = card.avatar {
                        Image(uiImage: avatar)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.blue)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(card.name)
                            .font(.title)
                            .bold()
                        Text(card.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                        if !card.tags.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(card.tags, id: \.self) { tag in
                                        Text(tag)
                                            .font(.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.blue.opacity(0.1))
                                            .cornerRadius(12)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // 相关笔记
                if !relatedNotes.isEmpty {
                    VStack(alignment: .leading) {
                        Text("相关笔记")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(relatedNotes) { note in
                                    VStack(alignment: .leading) {
                                        Text(note.title)
                                            .font(.headline)
                                        Text(note.content)
                                            .font(.body)
                                            .lineLimit(3)
                                        Text(note.date, style: .date)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .frame(width: 200)
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(10)
                                    .onTapGesture {
                                        selectedNote = note
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                // 相关场景
                if !relatedScenes.isEmpty {
                    VStack(alignment: .leading) {
                        Text("相关场景")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(relatedScenes) { scene in
                                    VStack(alignment: .leading) {
                                        Text(scene.title)
                                            .font(.headline)
                                        Text(scene.description)
                                            .font(.body)
                                            .lineLimit(3)
                                    }
                                    .frame(width: 200)
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(10)
                                    .onTapGesture {
                                        selectedScene = scene
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.vertical)
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
                NoteEditorView(preselectedCharacterID: card.id)
            }
        }
        .sheet(item: $selectedNote) { noteItem in
            NavigationStack {
                NoteBlockDetailView(noteBlock: noteItem)
            }
        }
        .sheet(item: $selectedScene) { sceneItem in
            NavigationStack {
                SceneDetailView(scene: sceneItem)
            }
        }
        .onAppear {
            viewModel.loadCharacters()
        }
    }
}

#Preview {
    NavigationStack {
        CharacterDetailView(card: CharacterCard(
            id: UUID(),
            name: "预览角色",
            description: "这是一个预览用的角色描述",
            avatar: nil,
            audioRecordings: nil,
            tags: ["预览"],
            noteIDs: [],
            sceneIDs: []
        ))
    }
}
