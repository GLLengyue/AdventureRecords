//  NoteBlockView.swift
//  AdventureRecords
//  笔记块列表视图
import SwiftUI

struct NoteBlockView: View {
    @EnvironmentObject var viewModel: NoteViewModel
    @State private var showEditor = false
    @State private var showingNote: NoteBlock? = nil
    @State private var selectedCharacter: CharacterCard? = nil
    @State private var selectedScene: AdventureScene? = nil
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.notes) { note in
                    NoteBlockRow(
                        note: note,
                        onDelete: {
                            viewModel.deleteNote(note)
                        },
                        onEdit: { updatedNote in
                            viewModel.updateNote(updatedNote)
                        },
                        getRelatedCharacters: {
                            return viewModel.getRelatedCharacters(for: note)
                        },
                        getRelatedScenes: {
                            return viewModel.getRelatedScenes(for: note)
                        }
                    )
                    .onTapGesture {
                        showingNote = note
                    }
                }
            }
            .refreshable {
                viewModel.loadNotes()
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
                NoteEditorView(onSave: { newNote in
                    viewModel.addNote(newNote)
                    showEditor = false
                }, onCancel: {
                    showEditor = false
                })
            }
            .sheet(item: $showingNote) { noteItem in
                NavigationStack {
                    NoteBlockDetailView(noteBlock: noteItem)
                }
            }
            .sheet(item: $selectedCharacter) { characterItem in
                NavigationStack {
                    CharacterDetailView(card: characterItem)
                }
            }
            .sheet(item: $selectedScene) { sceneItem in
                NavigationStack {
                    SceneDetailView(scene: sceneItem)
                }
            }
            .onAppear {
                viewModel.loadNotes()
            }
        }
    }
}

#Preview {
    NoteBlockView()
        .environmentObject(NoteViewModel())
}
