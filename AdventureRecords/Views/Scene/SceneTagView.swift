import SwiftUI
// 场景标签视图
struct SceneTagView: View {
    let scene: AdventureScene
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: "film")
                    .font(.caption)
                Text(scene.title)
                    .font(.subheadline)
            }
            .padding(EdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10))
            .background(ThemeManager.shared.accentColor(for: .scene).opacity(0.15))
            .foregroundColor(ThemeManager.shared.accentColor(for: .scene))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(ThemeManager.shared.accentColor(for: .scene).opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}