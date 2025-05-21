import SwiftUI
// 角色标签视图
struct CharacterTagView: View {
    let character: Character
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: "person.fill")
                    .font(.caption)
                Text(character.name)
                    .font(.subheadline)
            }
            .padding(EdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10))
            .background(ThemeManager.shared.accentColor(for: .character).opacity(0.15))
            .foregroundColor(ThemeManager.shared.accentColor(for: .character))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(ThemeManager.shared.accentColor(for: .character).opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
