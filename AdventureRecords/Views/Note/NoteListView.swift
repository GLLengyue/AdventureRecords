import SwiftUI

struct NoteListView: View {
    @EnvironmentObject var noteViewModel: NoteViewModel

    @State private var showingNoteEditor = false
    @State private var noteToEdit: NoteBlock? = nil

    var body: some View {
        NavigationView {
            List {
                ForEach(noteViewModel.notes) { note in
                    NavigationLink(destination: NoteBlockDetailView(noteBlock: note)) {
                        NoteBlockRow(
                            note: note,
                            onDelete: {
                                noteViewModel.deleteNote(note)
                            },
                            onEdit: { editableNote in
                                self.noteToEdit = editableNote
                                self.showingNoteEditor = true
                            },
                            getRelatedCharacters: {
                                return noteViewModel.getRelatedCharacters(for: note) // Pass the note for contex
                            },
                            getRelatedScenes: {
                                return noteViewModel.getRelatedScenes(for: note) // Pass the note for context
                            }
                        )
                    }
                }
                .onDelete(perform: deleteNotes)
            }
            .refreshable {
                noteViewModel.loadNotes()
            }
            .navigationTitle("笔记")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        self.noteToEdit = nil // Ensure we are creating a new one
                        self.showingNoteEditor = true
                    } label: {
                        Label("添加笔记", systemImage: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingNoteEditor) {
                NoteEditorView(
                    note: noteToEdit, // Pass nil for new, or existing note for edit
                    onSave: { savedNote in
                        if let index = noteViewModel.notes.firstIndex(where: { $0.id == savedNote.id }) {
                            noteViewModel.updateNote(savedNote)
                        } else {
                            noteViewModel.addNote(savedNote)
                        }
                        showingNoteEditor = false
                    },
                    onCancel: {
                        showingNoteEditor = false
                    }
                )
            }
        }
    }

    private func deleteNotes(at offsets: IndexSet) {
        offsets.map { noteViewModel.notes[$0] }.forEach {
            noteViewModel.deleteNote($0)
        }
    }
}

// #Preview {
//     NoteListView()
//         .environmentObject(NoteViewModel.preview)
//         .environmentObject(CharacterViewModel.preview)
//         .environmentObject(SceneViewModel.preview)
// }