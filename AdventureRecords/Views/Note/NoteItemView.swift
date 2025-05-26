import SwiftUI

// 笔记项视图
struct NoteItemView: View {
    let note: NoteBlock
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 12) {
                // 图标
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 20))
                    .foregroundColor(ThemeManager.shared.accentColor(for: .note))
                    .frame(width: 36, height: 36)
                    .background(ThemeManager.shared.accentColor(for: .note).opacity(0.15))
                    .cornerRadius(8)

                // 文本内容
                VStack(alignment: .leading, spacing: 4) {
                    Text(note.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(ThemeManager.shared.primaryTextColor)
                        .lineLimit(1)

                    if !note.content.isEmpty {
                        Text(note.content)
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
