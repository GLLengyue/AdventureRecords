import Foundation

/// 录音模型
struct AudioRecording: Identifiable, Hashable, Codable {
    /// 获取音频文件名称
    var fileName: String {
        return "\(id.uuidString).m4a"
    }
    let id: UUID
    var title: String
    var recordingURL: URL
    var date: Date

    // 获取录音文件的相对路径
    var fileNameForPath: String {
        return recordingURL.lastPathComponent
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: AudioRecording, rhs: AudioRecording) -> Bool {
        lhs.id == rhs.id
    }
}
