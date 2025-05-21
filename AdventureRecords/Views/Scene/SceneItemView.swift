import SwiftUI

// 场景项视图
struct SceneItemView: View {
    let scene: AdventureScene
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 12) {
                // 场景封面或图标
                if let coverImage = scene.coverImage {
                    Image(uiImage: coverImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 48, height: 48)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    Image(systemName: "film.fill")
                        .font(.system(size: 20))
                        .foregroundColor(ThemeManager.shared.accentColor(for: .scene))
                        .frame(width: 48, height: 48)
                        .background(ThemeManager.shared.accentColor(for: .scene).opacity(0.15))
                        .cornerRadius(8)
                }
                
                // 文本内容
                VStack(alignment: .leading, spacing: 4) {
                    Text(scene.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(ThemeManager.shared.primaryTextColor)
                        .lineLimit(1)
                    
                    if !scene.description.isEmpty {
                        Text(scene.description)
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