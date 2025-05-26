import AVFoundation
import Combine
import Foundation
import SwiftUI

class AudioViewModel: NSObject, ObservableObject, AVAudioPlayerDelegate {
    static let shared = AudioViewModel()

    @Published var recordings: [AudioRecording] = []
    @Published var isRecording: Bool = false
    @Published var currentRecording: AudioRecording? // Represents the recording being actively captured or just
    // captured
    @Published var isPlayingAudio: Bool = false
    @Published var currentlyPlayingAudioID: UUID? = nil

    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var cancellables = Set<AnyCancellable>()
    private let coreDataManager = CoreDataManager.shared

    // 添加音频文件目录常量
    private let audioDirectoryName = "AudioRecordings"

    override private init() {
        super.init()
        createAudioDirectoryIfNeeded()
        loadRecordings()
    }

    // 创建专用的音频文件目录
    private func createAudioDirectoryIfNeeded() {
        let fileManager = FileManager.default
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioDirectoryPath = documentsPath.appendingPathComponent(audioDirectoryName)

        if !fileManager.fileExists(atPath: audioDirectoryPath.path) {
            do {
                try fileManager.createDirectory(at: audioDirectoryPath, withIntermediateDirectories: true)
                print("创建音频目录: \(audioDirectoryPath.path)")
            } catch {
                print("创建音频目录失败: \(error)")
            }
        }
    }

    // 获取音频文件目录
    private func getAudioDirectory() -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsPath.appendingPathComponent(audioDirectoryName)
    }

    func loadRecordings() {
        let allRecordings = coreDataManager.fetchAudioRecordings()

        // 验证每个录音文件是否存在
        recordings = allRecordings.filter { recording in
            let fileExists = FileManager.default.fileExists(atPath: recording.recordingURL.path)
            if !fileExists {
                print("警告: 录音文件不存在: \(recording.recordingURL.path)")
                // 可选：删除不存在文件的数据库记录
                // coreDataManager.deleteAudioRecording(recording.id)
            }
            return fileExists
        }

        self.objectWillChange.send()
    }

    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)

            // 使用专用目录存储音频文件
            let audioDirectory = getAudioDirectory()
            let fileName = "\(UUID().uuidString).m4a"
            let audioFilename = audioDirectory.appendingPathComponent(fileName)

            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
            ]

            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.record()
            isRecording = true

            // 创建新的录音记录
            currentRecording = AudioRecording(id: UUID(),
                                              title: "新录音",
                                              recordingURL: audioFilename,
                                              date: Date())
        } catch {
            print("录音失败: \(error)")
        }
    }

    func stopRecording(save: Bool) {
        audioRecorder?.stop()
        isRecording = false

        if save, let recording = currentRecording {
            // The actual saving will be handled by saveRecording or by the creation view explicitly calling save.
            // Here we mainly ensure the recording process is finalized.
            print("Recording stopped, ready to be saved: \(recording.title)")
        } else if !save, let recordingURL = currentRecording?.recordingURL {
            // If not saving, delete the temporary file
            do {
                try FileManager.default.removeItem(at: recordingURL)
                print("Temporary recording file deleted: \(recordingURL.lastPathComponent)")
            } catch {
                print("Failed to delete temporary recording file: \(error)")
            }
            currentRecording = nil // Discard the recording
        }
    }

    func updateRecording(_ recording: AudioRecording) {
        print("Update recording.")
        // 检查文件是否存在
        if FileManager.default.fileExists(atPath: recording.recordingURL.path) {
            coreDataManager.updateAudioRecording(recording)
            loadRecordings() // Refresh the list after updating
        } else {
            print("警告: 尝试更新不存在的录音文件: \(recording.recordingURL.path)")
        }
    }

    func saveRecording(recordingToSave: AudioRecording, forCharacterID characterID: UUID? = nil) {
        // Ensure title is not empty, this should ideally be validated in the View or ViewModel before calling
        guard !recordingToSave.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("Recording title cannot be empty.")
            // Optionally, set currentRecording to nil or handle error appropriately
            return
        }

        // 确保文件存在
        guard FileManager.default.fileExists(atPath: recordingToSave.recordingURL.path) else {
            print("警告: 尝试保存不存在的录音文件: \(recordingToSave.recordingURL.path)")
            return
        }

        coreDataManager.saveAudioRecording(recordingToSave, forCharacterID: characterID)
        loadRecordings() // Refresh the list
        currentRecording = nil // Clear after saving
    }

    func deleteRecording(_ recording: AudioRecording) {
        // 删除音频文件
        if FileManager.default.fileExists(atPath: recording.recordingURL.path) {
            do {
                try FileManager.default.removeItem(at: recording.recordingURL)
                print("已删除音频文件: \(recording.recordingURL.path)")
            } catch {
                print("删除音频文件失败: \(error)")
            }
        } else {
            print("警告: 尝试删除不存在的录音文件: \(recording.recordingURL.path)")
        }

        // 删除数据库记录
        coreDataManager.deleteAudioRecording(recording.id)
        loadRecordings()
    }

    func playRecording(recording: AudioRecording) {
        // 检查文件是否存在
        guard FileManager.default.fileExists(atPath: recording.recordingURL.path) else {
            print("警告: 尝试播放不存在的录音文件: \(recording.recordingURL.path)")
            return
        }

        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)

            // Stop any currently playing audio first
            if audioPlayer?.isPlaying == true {
                audioPlayer?.stop()
            }

            audioPlayer = try AVAudioPlayer(contentsOf: recording.recordingURL)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            isPlayingAudio = true
            currentlyPlayingAudioID = recording.id
        } catch {
            print("播放录音失败: \(error)")
            isPlayingAudio = false
            currentlyPlayingAudioID = nil
        }
    }

    // 导入外部音频文件
    func importAudioFile(from sourceURL: URL, withTitle title: String) -> AudioRecording? {
        let fileManager = FileManager.default
        let audioDirectory = getAudioDirectory()
        let fileName = "\(UUID().uuidString).\(sourceURL.pathExtension)"
        let destinationURL = audioDirectory.appendingPathComponent(fileName)

        do {
            // 如果是安全范围的URL，需要先获取访问权限
            var hasSecurityAccess = false
            if sourceURL.startAccessingSecurityScopedResource() {
                hasSecurityAccess = true
                defer {
                    if hasSecurityAccess {
                        sourceURL.stopAccessingSecurityScopedResource()
                    }
                }

                print("尝试从 \(sourceURL.path) 导入音频文件")

                // 使用Data读取文件内容而不是直接复制文件
                do {
                    let audioData = try Data(contentsOf: sourceURL)
                    print("成功读取音频数据，大小: \(audioData.count) 字节")

                    // 将数据写入到目标文件
                    try audioData.write(to: destinationURL)
                    print("成功写入音频数据到: \(destinationURL.path)")

                    // 创建新的录音记录
                    let newRecording = AudioRecording(id: UUID(),
                                                      title: title,
                                                      recordingURL: destinationURL,
                                                      date: Date())

                    return newRecording
                } catch let dataError {
                    print("读取或写入音频数据失败: \(dataError)")

                    // 尝试使用AVAsset复制音频数据
                    if let audioAsset = try? AVURLAsset(url: sourceURL) {
                        print("尝试使用AVAsset读取音频")

                        // 使用AVAssetExportSession导出音频
                        if let exportSession = AVAssetExportSession(asset: audioAsset,
                                                                    presetName: AVAssetExportPresetAppleM4A)
                        {
                            exportSession.outputURL = destinationURL
                            exportSession.outputFileType = .m4a

                            // 同步等待导出完成
                            let semaphore = DispatchSemaphore(value: 0)
                            exportSession.exportAsynchronously {
                                semaphore.signal()
                            }
                            _ = semaphore.wait(timeout: .now() + 30.0)

                            if exportSession.status == .completed {
                                print("成功使用AVAsset导出音频到: \(destinationURL.path)")

                                // 创建新的录音记录
                                let newRecording = AudioRecording(id: UUID(),
                                                                  title: title,
                                                                  recordingURL: destinationURL,
                                                                  date: Date())

                                return newRecording
                            } else {
                                print("AVAsset导出失败: \(exportSession.error?.localizedDescription ?? "未知错误")")
                            }
                        }
                    }
                }
            } else {
                print("无法获取文件访问权限: \(sourceURL.path)")
            }

            return nil
        } catch {
            print("导入音频文件失败: \(error)")
            return nil
        }
    }

    func stopPlayback() {
        audioPlayer?.stop()
        isPlayingAudio = false
        currentlyPlayingAudioID = nil
        // It's good practice to deactivate the audio session when not in use for long periods
        // or to allow other apps to play audio. However, for quick play/stop, it might be too disruptive.
        // Consider deactivating based on app lifecycle or specific user actions.
        // do {
        //     try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        // } catch {
        //     print("Failed to deactivate audio session: \(error)")
        // }
    }

    // MARK: - AVAudioPlayerDelegate

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlayingAudio = false
        currentlyPlayingAudioID = nil
        // Optionally, deactivate audio session here if desired
        // do {
        //     try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        // } catch {
        //     print("Failed to deactivate audio session after playback: \(error)")
        // }
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("Audio player decode error: \(String(describing: error))")
        isPlayingAudio = false
        currentlyPlayingAudioID = nil
    }
}
