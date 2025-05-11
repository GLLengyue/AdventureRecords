import Foundation
import SwiftUI
import Combine
import AVFoundation

class AudioViewModel: ObservableObject {
    @Published var recordings: [AudioRecording] = []
    @Published var isRecording: Bool = false
    @Published var currentRecording: AudioRecording?
    
    private var audioRecorder: AVAudioRecorder?
    private var cancellables = Set<AnyCancellable>()
    private let coreDataManager = CoreDataManager.shared
    
    init() {
        loadRecordings()
    }
    
    func loadRecordings() {
        recordings = coreDataManager.fetchAudioRecordings()
    }
    
    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let audioFilename = documentsPath.appendingPathComponent("\(UUID().uuidString).m4a")
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.record()
            isRecording = true
            
            // 创建新的录音记录
            currentRecording = AudioRecording(
                id: UUID(),
                title: "新录音",
                recordingURL: audioFilename,
                date: Date()
            )
        } catch {
            print("录音失败: \(error)")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        
        if let recording = currentRecording {
            coreDataManager.saveAudioRecording(recording)
            loadRecordings()
        }
    }
    
    func deleteRecording(_ recording: AudioRecording) {
        // 删除音频文件
        do {
            try FileManager.default.removeItem(at: recording.recordingURL)
        } catch {
            print("删除音频文件失败: \(error)")
        }
        
        // 删除数据库记录
        coreDataManager.deleteAudioRecording(recording.id)
        loadRecordings()
    }
    
    func playRecording(_ recording: AudioRecording) {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)
            
            let player = try AVAudioPlayer(contentsOf: recording.recordingURL)
            player.play()
        } catch {
            print("播放录音失败: \(error)")
        }
    }
} 