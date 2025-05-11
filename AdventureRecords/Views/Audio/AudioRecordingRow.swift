import SwiftUI

struct AudioRecordingRow: View {
    // let recording: AudioRecording // 假设 AudioRecording 已在其他地方定义
    // @StateObject private var viewModel: AudioRecordingViewModel // 修改为依赖注入方式
    // @State private var showDeleteAlert = false 
    // @State private var isPlaying = false
    
    // init(recording: AudioRecording, viewModel: AudioRecordingViewModel) {
    //     self.recording = recording
    //     _viewModel = StateObject(wrappedValue: viewModel)
    // }
    
    var body: some View {
        Text("Hello, World!")
    }
    //     HStack {
    //         Button(action: {
    //             isPlaying.toggle()
    //             // TODO: 实现音频播放逻辑
    //         }) {
    //             Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
    //                 .font(.title)
    //                 .foregroundColor(.blue)
    //         }
            
    //         VStack(alignment: .leading) {
    //             Text(recording.title)
    //                 .font(.headline)
    //             Text(recording.date, style: .date)
    //                 .font(.caption)
    //                 .foregroundColor(.secondary)
    //         }
            
    //         Spacer()
            
    //         Button(action: {
    //             showDeleteAlert = true
    //         }) {
    //             Image(systemName: "trash")
    //                 .foregroundColor(.red)
    //         }
    //     }
    //     .padding(.vertical, 8)
    //     .alert("确认删除", isPresented: $showDeleteAlert) {
    //         Button("取消", role: .cancel) {}
    //         Button("删除", role: .destructive) {
    //             viewModel.deleteRecording(recording)
    //         }
    //     } message: {
    //         Text("确定要删除录音 \(recording.title) 吗？此操作无法撤销。")
    //     }
    // }
}

// Preview can be added if needed, e.g.:
// #Preview {
//     // Requires a sample AudioRecording instance
//     // AudioRecordingRow(recording: AudioRecording(title: "Sample Recording", date: Date(), url: URL(string: "example.com")!))
// } 