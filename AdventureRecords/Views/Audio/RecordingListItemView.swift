import SwiftUI

// 录音列表项视图
struct RecordingListItemView: View {
    let recording: AudioRecording
    let isPlaying: Bool
    let onPlayPause: () -> Void
    let onRename: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            // 播放/暂停按钮
            Button(action: onPlayPause) {
                ZStack {
                    Circle()
                        .fill(isPlaying ? Color.red.opacity(0.15) : ThemeManager.shared.accentColor(for: .character).opacity(0.15))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(isPlaying ? .red : ThemeManager.shared.accentColor(for: .character))
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // 录音信息
            VStack(alignment: .leading, spacing: 4) {
                Text(recording.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    Text(formattedDate(recording.date))
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.leading, 12)
            
            Spacer()
            
            // 上下文菜单
            Menu {
                Button(action: onRename) {
                    Label("重命名", systemImage: "pencil")
                }
                
                Button(role: .destructive, action: onDelete) {
                    Label("删除", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 22))
                    .foregroundColor(.secondary)
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .contentShape(Rectangle())
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: date)
    }
}
