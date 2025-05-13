import SwiftUI

struct NoteListView: View {
    @EnvironmentObject var noteViewModel: NoteViewModel

    @State private var showingNoteEditor = false
    @State private var searchText: String = ""
    @State private var stagingSearchText: String = ""
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
            if filteredAndSortedNotes.isEmpty {
                VStack {
                    Image(systemName: "note.text") // 示例图标
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray.opacity(0.5))
                        .padding(.bottom)
                    Text(searchText.isEmpty ? "还没有笔记呢" : "没有找到符合条件的笔记")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text(searchText.isEmpty ? "点击右上方 \"+\" 添加一个新笔记吧！" : "尝试修改你的搜索词，或者清除搜索。")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
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
                            self.showingNoteEditor = true // This showingNoteEditor is for the ListView's sheet for NEW notes
                        } label: {
                            Label("添加笔记", systemImage: "plus.circle.fill")
                        }
                    }
                }
                .sheet(isPresented: $showingNoteEditor) { // This sheet is for creating NEW notes
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
                .frame(maxWidth: .infinity, maxHeight: .infinity) // 居中内容
                .searchable(text: $stagingSearchText, prompt: "搜索笔记") // 添加 searchable 修饰符
                .onSubmit(of: .search) {
                    searchText = stagingSearchText
                }
                .onChange(of: stagingSearchText) {
                    if stagingSearchText.isEmpty {
                        searchText = ""
                    }
                }
            } else {
                List {
                    ForEach(filteredAndSortedNotes) { note in // 使用 filteredAndSortedNotes
                        NavigationLink(destination: NoteBlockDetailView(noteBlock: note)) {
                            NoteBlockRow(
                                note: note,
                                onDelete: {
                                    noteViewModel.deleteNote(note)
                                },
                                onEdit: { editableNote in
                                    noteViewModel.updateNote(editableNote) // This aligns with CharacterListView patch
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
                            self.showingNoteEditor = true // This showingNoteEditor is for the ListView's sheet for NEW notes
                        } label: {
                            Label("添加笔记", systemImage: "plus.circle.fill")
                        }
                    }
                }
                .searchable(text: $stagingSearchText, prompt: "搜索笔记") // 添加 searchable 修饰符
                .onSubmit(of: .search) {
                    searchText = stagingSearchText
                }
                .onChange(of: stagingSearchText) {
                    if stagingSearchText.isEmpty {
                        searchText = ""
                    }
                }
                .sheet(isPresented: $showingNoteEditor) { // This sheet is for creating NEW notes
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
            } // 关闭 else 代码块
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