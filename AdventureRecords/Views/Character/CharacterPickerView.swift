import SwiftUI

struct CharacterPickerView: View {
    @Binding var selectedCharacterIDs: [UUID]
    @Environment(\.dismiss) var dismiss
    
    // 使用单例
    private let viewModel = CharacterViewModel.shared
    
    var body: some View {
        NavigationStack {
            List(viewModel.getCharacters()) { character in
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