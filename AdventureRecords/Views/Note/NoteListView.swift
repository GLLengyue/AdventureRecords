import SwiftUI

struct NoteListView: View {
    @Binding var showingNoteEditor: Bool

    @State private var searchText: String = ""
    @State private var sortOrder: SortOrder = .titleAscending
    @State private var selectedNote: NoteBlock? = nil
    
    // 使用单例
    @StateObject private var noteViewModel = NoteViewModel.shared

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
                            withAnimation {
                                sortOrder = order
                            }
                        }) {
                            HStack {
                                Text(order.rawValue)
                                    .font(.system(.body))
                                Spacer()
                                if sortOrder == order {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(ThemeManager.shared.accentColor(for: .note))
                                }
                            }
                            .contentShape(Rectangle())
                        }
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 16, weight: .semibold))
                        .padding(8)
                        .background(ThemeManager.shared.accentColor(for: .note).opacity(0.1))
                        .clipShape(Circle())
                }
            }
        ) {
            if filteredAndSortedNotes.isEmpty {
                VStack(spacing: 20) {
                    Spacer()
                    
                    VStack(spacing: 16) {
                        Image(systemName: "note.text.badge.plus")
                            .font(.system(size: 64))
                            .foregroundColor(ThemeManager.shared.accentColor(for: .note).opacity(0.6))
                        
                        Text(searchText.isEmpty ? "暂无笔记" : "没有找到相关笔记")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        if searchText.isEmpty {
                            Button {
                                showingNoteEditor = true
                            } label: {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("创建笔记")
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(ThemeManager.shared.accentColor(for: .note))
                                .foregroundColor(.white)
                                .cornerRadius(20)
                            }
                            .buttonStyle(ScaleButtonStyle())
                            .padding(.top, 8)
                        }
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
            } else {
                List {
                    ForEach(filteredAndSortedNotes) { note in
                        Button {
                            selectedNote = note
                        } label: {
                            NoteBlockRow(
                                note: note,
                                onDelete: {
                                    withAnimation {
                                        NoteViewModel.shared.deleteNote(note)
                                    }
                                },
                                onEdit: { editableNote in
                                    noteViewModel.updateNote(editableNote)
                                }
                            )
                            .contentShape(Rectangle())
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .sheet(item: $selectedNote) { note in
            NoteBlockDetailView(noteID: note.id)
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