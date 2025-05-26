import Foundation

struct AudioRecording: Identifiable, Hashable {
    let id: UUID
    var title: String
    var recordingURL: URL
    var date: Date

    // 文件名，用于相对路径存储
    var fileName: String {
        return recordingURL.lastPathComponent
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: AudioRecording, rhs: AudioRecording) -> Bool {
        lhs.id == rhs.id
    }
}
