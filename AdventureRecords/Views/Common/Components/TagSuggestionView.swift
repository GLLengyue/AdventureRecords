import SwiftUI

struct TagSuggestionView: View {
    let suggestions: [String]
    let onSelectSuggestion: (String) -> Void
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !suggestions.isEmpty {
                Text("建议标签")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(suggestions, id: \.self) { suggestion in
                            Button(action: {
                                onSelectSuggestion(suggestion)
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 10))
                                    Text(suggestion)
                                        .lineLimit(1)
                                }
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(accentColor.opacity(0.1))
                                .foregroundColor(accentColor)
                                .cornerRadius(16)
                                .overlay(RoundedRectangle(cornerRadius: 16)
                                    .stroke(accentColor.opacity(0.3), lineWidth: 1))
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
