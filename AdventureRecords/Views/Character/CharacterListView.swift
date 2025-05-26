import SwiftUI

struct CharacterListView: View {
    @Binding var showingCharacterEditor: Bool
    @State private var searchText: String = ""
    @State private var sortOrder: SortOrder = .nameAscending
    @State private var selectedCharacter: Character? = nil
    @State private var selectedTags: [String] = []
    
    // 使用单例
    @StateObject private var characterViewModel = CharacterViewModel.shared

    enum SortOrder: String, CaseIterable, Identifiable {
        case nameAscending = "名称升序"
        case nameDescending = "名称降序"
        // 可以根据需要添加更多排序选项，例如按创建日期
        var id: String { self.rawValue }
    }

    // 获取所有角色中的标签
    var allTags: [String] {
        var tags = Set<String>()
        for character in characterViewModel.characters {
            for tag in character.tags {
                tags.insert(tag)
            }
        }
        return Array(tags).sorted()
    }
    
    var filteredAndSortedCharacters: [Character] {
        let filtered = characterViewModel.characters.filter { character in
            let matchesSearch = searchText.isEmpty ? true : 
                character.name.localizedCaseInsensitiveContains(searchText) || 
                character.description.localizedCaseInsensitiveContains(searchText) ||
                character.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            
            let matchesTags = selectedTags.isEmpty ? true : 
                character.tags.contains { selectedTags.contains($0) }
            
            return matchesSearch && matchesTags
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
            title: "角色",
            searchText: $searchText,
            onSearch: { _ in },
            addAction: {
                showingCharacterEditor = true
            },
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
                                        .foregroundColor(ThemeManager.shared.accentColor(for: .character))
                                }
                            }
                            .contentShape(Rectangle())
                        }
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 16, weight: .semibold))
                        .padding(8)
                        .background(ThemeManager.shared.accentColor(for: .character).opacity(0.1))
                        .clipShape(Circle())
                }
            }
        ) {
            if filteredAndSortedCharacters.isEmpty {
                VStack(spacing: 20) {
                    Spacer()
                    
                    VStack(spacing: 16) {
                        Image(systemName: "person.crop.circle.badge.questionmark")
                            .font(.system(size: 64))
                            .foregroundColor(ThemeManager.shared.accentColor(for: .character).opacity(0.6))
                        
                        Text(searchText.isEmpty ? "暂无角色" : "没有找到相关角色")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        if searchText.isEmpty {
                            Button {
                                showingCharacterEditor = true
                            } label: {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("创建角色")
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(ThemeManager.shared.accentColor(for: .character))
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
                VStack(spacing: 0) {
                    // 标签筛选视图
                    if !allTags.isEmpty {
                        TagFilterView(
                            allTags: allTags,
                            selectedTags: $selectedTags,
                            accentColor: ThemeManager.shared.accentColor(for: .character)
                        )
                        .padding(.bottom, 8)
                    }
                    
                    List {
                        ForEach(filteredAndSortedCharacters) { character in
                            Button {
                                selectedCharacter = character
                            } label: {
                                CharacterRow(character: character,
                                    onDelete: {
                                    withAnimation {
                                        CharacterViewModel.shared.deleteCharacter(character)
                                    }
                                },
                                onEdit: { editableCharacter in
                                    characterViewModel.updateCharacter(editableCharacter)
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
                    .refreshable {
                        refreshData()
                    }
                }
            }
        }
        .sheet(item: $selectedCharacter) { character in
            CharacterDetailView(CharacterID: character.id)
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

    private func refreshData() {
        characterViewModel.loadCharacters()
    }
}