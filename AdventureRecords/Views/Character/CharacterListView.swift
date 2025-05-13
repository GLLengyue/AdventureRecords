import SwiftUI

struct CharacterListView: View {
    @EnvironmentObject var characterViewModel: CharacterViewModel
    // @EnvironmentObject var noteViewModel: NoteViewModel
    // @EnvironmentObject var sceneViewModel: SceneViewModel

    @State private var showingCharacterEditor = false
    @State private var characterToEdit: CharacterCard? = nil
    @State private var searchText: String = ""
    @State private var sortOrder: SortOrder = .nameAscending

    enum SortOrder: String, CaseIterable, Identifiable {
        case nameAscending = "名称升序"
        case nameDescending = "名称降序"
        // 可以根据需要添加更多排序选项，例如按创建日期
        var id: String { self.rawValue }
    }

    var filteredAndSortedCharacters: [CharacterCard] {
        let filtered = characterViewModel.characters.filter { character in
            searchText.isEmpty ? true : character.name.localizedCaseInsensitiveContains(searchText) || character.description.localizedCaseInsensitiveContains(searchText)
        }

        switch sortOrder {
        case .nameAscending:
            return filtered.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
        case .nameDescending:
            return filtered.sorted { $0.name.localizedCompare($1.name) == .orderedDescending }
        }
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(filteredAndSortedCharacters) { character in // 使用 filteredAndSortedCharacters
                    NavigationLink(destination: CharacterDetailView(card: character)) {
                        CharacterCardRow(
                            character: character,
                            onDelete: {
                                characterViewModel.deleteCharacter(character)
                            },
                            onEdit: { editableCharacter in
                                self.characterToEdit = editableCharacter
                                self.showingCharacterEditor = true
                            },
                            getRelatedNotes: {
                                return characterViewModel.getRelatedNotes(for: character)
                            },
                            getRelatedScenes: {
                                return characterViewModel.getRelatedScenes(for: character)
                            }
                        )
                    }
                }
                .onDelete(perform: deleteCharacters)
            }
            .refreshable {
                characterViewModel.loadCharacters()
            }
            .navigationTitle("角色卡")
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
                        self.characterToEdit = nil // Ensure we are creating a new one
                        self.showingCharacterEditor = true
                    } label: {
                        Label("添加角色", systemImage: "plus.circle.fill")
                    }
                }
            }
            .searchable(text: $searchText, prompt: "搜索角色") // 添加 searchable 修饰符
             .sheet(isPresented: $showingCharacterEditor) {
                 CharacterEditorView(
                     card: characterToEdit, // Pass nil for new, or existing card for edit
                     onSave: { savedCard in
                         if let index = characterViewModel.characters.firstIndex(where: { $0.id == savedCard.id }) {
                             characterViewModel.updateCharacter(savedCard)
                         } else {
                             characterViewModel.addCharacter(savedCard)
                         }
                         showingCharacterEditor = false
                     },
                     onCancel: {
                         showingCharacterEditor = false
                     }
                 )
             }
        }
    }

    private func deleteCharacters(at offsets: IndexSet) {
        offsets.map { filteredAndSortedCharacters[$0] }.forEach { // 使用 filteredAndSortedCharacters
            characterViewModel.deleteCharacter($0)
        }
    }
}

 #Preview {
     CharacterListView()
}
