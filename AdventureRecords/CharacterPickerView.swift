import SwiftUI

struct CharacterPickerView: View {
    @Binding var selectedCharacters: [UUID]
    let availableCharacters: [CharacterCard]
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(availableCharacters) { character in
                    Button(action: {
                        if selectedCharacters.contains(character.id) {
                            selectedCharacters.removeAll(where: { $0 == character.id })
                        } else {
                            selectedCharacters.append(character.id)
                        }
                    }) {
                        HStack {
                            Text(character.name)
                            Spacer()
                            if selectedCharacters.contains(character.id) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("选择角色")
            .toolbar {
                Button("完成") {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    CharacterPickerView(selectedCharacters: .constant([]), availableCharacters: [])
}