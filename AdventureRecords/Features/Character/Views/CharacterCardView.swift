//  CharacterCardView.swift
//  AdventureRecords
//  角色卡列表视图
import SwiftUI

struct CharacterCardView: View {
    @StateObject private var viewModel = CharacterViewModel()
    @State private var showEditor = false
    @State private var selectedCharacter: CharacterCard? = nil
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.characters) { character in
                    CharacterCardRow(character: character)
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
}
