import SwiftUI

struct CharacterListView: View {
    @EnvironmentObject var characterViewModel: CharacterViewModel
    // @EnvironmentObject var noteViewModel: NoteViewModel
    // @EnvironmentObject var sceneViewModel: SceneViewModel

    @State private var showingCharacterEditor = false
    @State private var characterToEdit: CharacterCard? = nil

    var body: some View {
        NavigationView {
            List {
                ForEach(characterViewModel.characters) { character in
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
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
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
        offsets.map { characterViewModel.characters[$0] }.forEach {
            characterViewModel.deleteCharacter($0)
        }
    }
}

 #Preview {
     CharacterListView()
}
