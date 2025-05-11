//  NoteBlockView.swift
//  AdventureRecords
//  笔记块列表视图
import SwiftUI

struct NoteBlockView: View {
    @StateObject private var viewModel = NoteViewModel()
    @State private var showEditor = false
    @State private var showingNote: NoteBlock? = nil
    @State private var showCharacterDetail = false
    @State private var selectedCharacter: CharacterCard? = nil
    @State private var showSceneDetail = false
    @State private var selectedScene: AdventureScene? = nil
    @State private var showDetail = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.notes) { note in
                    NoteBlockRow(note: note)
                        .onTapGesture {
                            showingNote = note
                            showDetail = true
                        }
                }
            }
            .navigationTitle("笔记")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showEditor = true }) {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .sheet(isPresented: $showEditor) {
                NavigationStack {
                    NoteEditorView()
                }
            }
            .sheet(isPresented: $showDetail) {
                if let note = showingNote {
                    NavigationStack {
                        NoteBlockDetailView(noteBlock: note)
                    }
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
                        SceneDetailView(scene: scene)
                    }
                }
            }
            .onAppear {
                viewModel.loadNotes()
            }
        }
    }
}

struct NoteBlockRow: View {
    let note: NoteBlock
    @StateObject private var viewModel = NoteViewModel()
    @State private var showDeleteAlert = false
    @State private var showEditor = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(note.title)
                .font(.headline)
            Text(note.content)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            Text(note.date, style: .date)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .swipeActions {
            Button(role: .destructive) {
                showDeleteAlert = true
            } label: {
                Label("删除", systemImage: "trash")
            }
            
            Button {
                showEditor = true
            } label: {
                Label("编辑", systemImage: "pencil")
            }
            .tint(.blue)
        }
        .alert("确认删除", isPresented: $showDeleteAlert) {
            Button("取消", role: .cancel) {}
            Button("删除", role: .destructive) {
                viewModel.deleteNote(note)
            }
        } message: {
            Text("确定要删除笔记 \(note.title) 吗？此操作无法撤销。")
        }
        .sheet(isPresented: $showEditor) {
            NavigationStack {
                NoteEditorView(note: note)
            }
        }
    }
}

#Preview {
    NoteBlockView()
}
