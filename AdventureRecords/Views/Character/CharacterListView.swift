import SwiftUI

struct CharacterListView: View {
    @EnvironmentObject var characterViewModel: CharacterViewModel
    @Binding var showingCharacterEditor: Bool
    @State private var searchText: String = ""
    @State private var stagingSearchText: String = ""
    @State private var sortOrder: SortOrder = .nameAscending
    @State private var selectedCharacter: CharacterCard? = nil

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
        ListContainer(module: .character, title: "角色卡", addAction: {
            showingCharacterEditor = true
        }) {
            List(filteredAndSortedCharacters) { character in
                Button {
                    selectedCharacter = character
                } label: {
                    CharacterRow(character: character,
                        onDelete: {
                            characterViewModel.deleteCharacter(character)
                        },
                        onEdit: { editableCharacter in
                            characterViewModel.updateCharacter(editableCharacter)
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
        }
        .sheet(item: $selectedCharacter) { character in
            CharacterDetailView(card: character)
                .environmentObject(characterViewModel)
        }
        .searchable(text: $stagingSearchText, prompt: "搜索角色") // 添加 searchable 修饰符
        .onSubmit(of: .search) {
            searchText = stagingSearchText
        }
        .onChange(of: stagingSearchText) {
            if stagingSearchText.isEmpty {
                searchText = ""
            }
        }
        .sheet(isPresented: $showingCharacterEditor) {
            CharacterEditorView(
                onSave: { savedCard in
                        characterViewModel.addCharacter(savedCard)
                    showingCharacterEditor = false
                },
                onCancel: {
                    showingCharacterEditor = false
                }
            )
            .environmentObject(characterViewModel)
        }
    }

    private func deleteCharacters(at offsets: IndexSet) {
        offsets.map { filteredAndSortedCharacters[$0] }.forEach { // 使用 filteredAndSortedCharacters
            characterViewModel.deleteCharacter($0)
        }
    }
}

// #Preview {
//     CharacterListView(showingCharacterEditor: .constant(false))
// }
