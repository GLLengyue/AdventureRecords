//  CharacterCardView.swift
//  AdventureRecords
//  角色卡列表视图
import SwiftUI

struct CharacterCardView: View {
    @EnvironmentObject var viewModel: CharacterViewModel
    @State private var showEditor = false
    @State private var selectedCharacter: CharacterCard? = nil
    
    var body: some View {

        NavigationStack {
            Section {
                Text("提示：左滑可进行编辑或删除")
                        .font(.footnote)
                        .foregroundColor(.secondary)
            } header: {
                EmptyView()
            }

            List {
                ForEach(viewModel.characters) { character in
                    CharacterCardRow(
                        character: character,
                        onDelete: {
                            viewModel.deleteCharacter(character)
                        },
                        onEdit: { updatedCard in
                            viewModel.updateCharacter(updatedCard)
                        },
                        getRelatedNotes: {
                            return viewModel.getRelatedNotes(for: character)
                        },
                        getRelatedScenes: {
                            return viewModel.getRelatedScenes(for: character)
                        }
                    )
                    .onTapGesture {
                        selectedCharacter = character
                    }
                }
            }
            .refreshable {
                viewModel.loadCharacters()
            }
            .navigationTitle("角色卡")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showEditor = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showEditor) {
                NavigationStack {
                    CharacterEditorView(onSave: { updatedCard in
                        viewModel.updateCharacter(updatedCard)
                    }, onCancel: {
                        showEditor = false
                    })
                }
            }
            .sheet(item: $selectedCharacter) { characterItem in
                NavigationStack {
                    CharacterDetailView(card: characterItem)
                }
            }
            .onAppear {
                viewModel.loadCharacters()
            }
        }
    }
}

#Preview {
    CharacterCardView()
        .environmentObject(CharacterViewModel())
}
