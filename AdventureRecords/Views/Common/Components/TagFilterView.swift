import SwiftUI

struct TagFilterView: View {
    let allTags: [String]
    @Binding var selectedTags: [String]
    let accentColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("按标签筛选")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(allTags, id: \.self) { tag in
                        Button(action: {
                            toggleTag(tag)
                        }) {
                            HStack(spacing: 4) {
                                if selectedTags.contains(tag) {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 10))
                                }
                                
                                Text(tag)
                                    .lineLimit(1)
                            }
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                selectedTags.contains(tag) ?
                                accentColor.opacity(0.2) :
                                ThemeManager.shared.secondaryBackgroundColor
                            )
                            .foregroundColor(
                                selectedTags.contains(tag) ?
                                accentColor :
                                ThemeManager.shared.primaryTextColor
                            )
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(
                                        selectedTags.contains(tag) ?
                                        accentColor :
                                        Color.gray.opacity(0.3),
                                        lineWidth: 1
                                    )
                            )
                        }
                    }
                    
                    if !selectedTags.isEmpty {
                        Button(action: {
                            selectedTags = []
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 10))
                                Text("清除筛选")
                            }
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(ThemeManager.shared.secondaryBackgroundColor)
                            .foregroundColor(.secondary)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.vertical, 8)
        .background(ThemeManager.shared.backgroundColor)
    }
    
    private func toggleTag(_ tag: String) {
        if selectedTags.contains(tag) {
            selectedTags.removeAll { $0 == tag }
        } else {
            selectedTags.append(tag)
        }
    }
}
