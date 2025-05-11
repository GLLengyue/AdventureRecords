import SwiftUI

struct AudioRecordingRow: View {
    let recording: AudioRecording // Assuming AudioRecording is defined elsewhere or will be
    @StateObject private var viewModel = AudioRecordingViewModel() // Assuming AudioRecordingViewModel is defined elsewhere or will be
    @State private var showDeleteAlert = false
    @State private var isPlaying = false
    
    var body: some View {
        HStack {
            Button(action: {
                isPlaying.toggle()
                // TODO: 实现音频播放逻辑
            }) {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.title)
                    .foregroundColor(.blue)
            }
            
            VStack(alignment: .leading) {
                Text(recording.title)
                    .font(.headline)
                Text(recording.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {
                showDeleteAlert = true
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 8)
        .alert("确认删除", isPresented: $showDeleteAlert) {
            Button("取消", role: .cancel) {}
            Button("删除", role: .destructive) {
                viewModel.deleteRecording(recording)
            }
        } message: {
            Text("确定要删除录音 \(recording.title) 吗？此操作无法撤销。")
        }
    }
}

// Preview can be added if needed, e.g.:
// #Preview {
//     // Requires a sample AudioRecording instance
//     // AudioRecordingRow(recording: AudioRecording(title: "Sample Recording", date: Date(), url: URL(string: "example.com")!))
// } 