import SwiftUI

struct CharacterListView: View {
    @EnvironmentObject var characterViewModel: CharacterViewModel
    @State private var showingCharacterEditor = false
    @State private var searchText: String = ""
    @State private var stagingSearchText: String = ""
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
            if filteredAndSortedCharacters.isEmpty {
                VStack {
                    Image(systemName: "person.3.fill") // 示例图标
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray.opacity(0.5))
                        .padding(.bottom)
                    Text(searchText.isEmpty ? "还没有角色呢" : "没有找到符合条件的角色")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text(searchText.isEmpty ? "点击右上方 \"+\" 添加一个新角色吧！" : "尝试修改你的搜索词，或者清除搜索。")
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
                            self.showingCharacterEditor = true
                        } label: {
                            Label("添加角色", systemImage: "plus.circle.fill")
                        }
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
                .frame(maxWidth: .infinity, maxHeight: .infinity) // 居中内容
            } else {
                List {
                    ForEach(filteredAndSortedCharacters) { character in // 使用 filteredAndSortedCharacters
                        NavigationLink(destination: CharacterDetailView(card: character)) {
                            CharacterCardRow(
                                character: character,
                                onDelete: {
                                    characterViewModel.deleteCharacter(character)
                                },
                                onEdit: characterViewModel.updateCharacter,
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
                            self.showingCharacterEditor = true
                        } label: {
                            Label("添加角色", systemImage: "plus.circle.fill")
                        }
                    }
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
                }
            } // 关闭 else 代码块
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
