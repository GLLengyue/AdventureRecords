import SwiftUI

// 角色项视图
struct CharacterItemView: View {
    let character: Character
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 12) {
                // 角色头像或图标
                if let avatar = character.avatar {
                    Image(uiImage: avatar)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 48, height: 48)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    Image(systemName: "person.fill")
                        .font(.system(size: 20))
                        .foregroundColor(ThemeManager.shared.accentColor(for: .character))
                        .frame(width: 48, height: 48)
                        .background(ThemeManager.shared.accentColor(for: .character).opacity(0.15))
                        .cornerRadius(8)
                }

                // 文本内容
                VStack(alignment: .leading, spacing: 4) {
                    Text(character.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(ThemeManager.shared.primaryTextColor)
                        .lineLimit(1)

                    if !character.description.isEmpty {
                        Text(character.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .padding(12)
            .background(ThemeManager.shared.secondaryBackgroundColor)
            .cornerRadius(12)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
