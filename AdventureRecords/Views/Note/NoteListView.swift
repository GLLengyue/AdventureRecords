import SwiftUI

struct NoteListView: View {
    @EnvironmentObject var noteViewModel: NoteViewModel
    @Binding var showingNoteEditor: Bool

    @State private var searchText: String = ""
    @State private var sortOrder: SortOrder = .titleAscending
    @State private var selectedNote: NoteBlock? = nil

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
        ListContainer(
            module: .note,
            title: "笔记",
            searchText: $searchText,
            onSearch: { _ in },
            addAction: { showingNoteEditor = true },
            trailingContent: {
                Menu {
                    ForEach(SortOrder.allCases) { order in
                        Button(action: {
                            sortOrder = order
                        }) {
                            HStack {
                                Text(order.rawValue)
                                if sortOrder == order {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                        .foregroundColor(ThemeManager.shared.accentColor(for: .note))
                }
            }
        ) {
            List(filteredAndSortedNotes) { note in
                Button {
                    selectedNote = note
                } label: {
                    NoteBlockRow(
                        note: note,
                        onDelete: {
                            noteViewModel.deleteNote(note)
                        },
                        onEdit: { editableNote in
                            noteViewModel.updateNote(editableNote)
                        }
                    )
                }
            }
        }
        .sheet(item: $selectedNote) { note in
            NoteBlockDetailView(noteBlock: note)
        }
        .sheet(isPresented: $showingNoteEditor) {
            NoteEditorView(
                onSave: { newNote in
                    noteViewModel.addNote(newNote)
                    showingNoteEditor = false
                },
                onCancel: {
                    showingNoteEditor = false
                }
            )
        }
    }

    private func deleteNotes(at offsets: IndexSet) {
        offsets.map { filteredAndSortedNotes[$0] }.forEach {
            noteViewModel.deleteNote($0)
        }
    }
}