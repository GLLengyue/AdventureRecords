import SwiftUI

struct CharacterListView: View {
    @EnvironmentObject var characterViewModel: CharacterViewModel
    @Binding var showingCharacterEditor: Bool
    @State private var searchText: String = ""
    @State private var sortOrder: SortOrder = .nameAscending
    @State private var selectedCharacter: Character? = nil

    enum SortOrder: String, CaseIterable, Identifiable {
        case nameAscending = "名称升序"
        case nameDescending = "名称降序"
        // 可以根据需要添加更多排序选项，例如按创建日期
        var id: String { self.rawValue }
    }

    var filteredAndSortedCharacters: [Character] {
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
        ListContainer(
            module: .character,
            title: "角色卡",
            searchText: $searchText,
            onSearch: { _ in },
            addAction: {
                showingCharacterEditor = true
            },
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
                        .foregroundColor(ThemeManager.shared.accentColor(for: .character))
                }
            }
        ) {
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
                        }
                    )
                }
            }
        }
        .sheet(item: $selectedCharacter) { character in
            CharacterDetailView(card: character)
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
        }
    }

    private func deleteCharacters(at offsets: IndexSet) {
        offsets.map { filteredAndSortedCharacters[$0] }.forEach {
            characterViewModel.deleteCharacter($0)
        }
    }
}