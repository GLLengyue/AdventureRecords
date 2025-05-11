import SwiftUI

struct CharacterPickerView: View {
    @Binding var selectedCharacterIDs: [UUID]
    @EnvironmentObject var viewModel: CharacterViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List(viewModel.characters) { character in
                HStack {
                    Text(character.name)
                    Spacer()
                    if selectedCharacterIDs.contains(character.id) {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if let index = selectedCharacterIDs.firstIndex(of: character.id) {
                        selectedCharacterIDs.remove(at: index)
                    } else {
                        selectedCharacterIDs.append(character.id)
                    }
                }
            }
            .navigationTitle("选择角色")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    CharacterPickerView(selectedCharacterIDs: .constant([]))
        .environmentObject(CharacterViewModel())
} 