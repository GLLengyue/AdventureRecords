import SwiftUI

struct NoteListView: View {
    @EnvironmentObject var noteViewModel: NoteViewModel

    @State private var showingNoteEditor = false
    @State private var noteToEdit: NoteBlock? = nil
    @State private var searchText: String = ""
    @State private var sortOrder: SortOrder = .titleAscending

    enum SortOrder: String, CaseIterable, Identifiable {
        case titleAscending = "标题升序"
        case titleDescending = "标题降序"
        case dateAscending = "创建日期升序"
        case dateDescending = "创建日期降序"
        var id: String { self.rawValue }
    }

    var filteredAndSortedNotes: [NoteBlock] {
        let filtered = noteViewModel.notes.filter { note in
            searchText.isEmpty ? true : note.title.localizedCaseInsensitiveContains(searchText) || note.content.localizedCaseInsensitiveContains(searchText)
        }

        switch sortOrder {
        case .titleAscending:
            return filtered.sorted { $0.title.localizedCompare($1.title) == .orderedAscending }
        case .titleDescending:
            return filtered.sorted { $0.title.localizedCompare($1.title) == .orderedDescending }
        case .dateAscending:
            return filtered.sorted { $0.date < $1.date }
        case .dateDescending:
            return filtered.sorted { $0.date > $1.date }
        }
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(filteredAndSortedNotes) { note in // 使用 filteredAndSortedNotes
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
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    EditButton()
                    Menu {
                        Picker("排序方式", selection: $sortOrder) {
                            ForEach(SortOrder.allCases, id: \.self) { order in
                                Text(order.rawValue).tag(order)
                            }
                        }
                    } label: {
                        Label("排序", systemImage: "arrow.up.arrow.down.circle")
                    }
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
            .searchable(text: $searchText, prompt: "搜索笔记") // 添加 searchable 修饰符
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
        offsets.map { filteredAndSortedNotes[$0] }.forEach { // 使用 filteredAndSortedNotes
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