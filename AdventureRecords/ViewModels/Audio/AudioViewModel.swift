import Foundation
import SwiftUI
import Combine
import AVFoundation

class AudioViewModel: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var recordings: [AudioRecording] = []
    @Published var isRecording: Bool = false
    @Published var currentRecording: AudioRecording? // Represents the recording being actively captured or just captured
    @Published var isPlayingAudio: Bool = false
    @Published var currentlyPlayingAudioID: UUID? = nil
    
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var cancellables = Set<AnyCancellable>()
    private let coreDataManager = CoreDataManager.shared
    
    override init() {
        super.init()
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
        coreDataManager.updateAudioRecording(recording)
        loadRecordings() // Refresh the list after updating
    }

    func saveRecording(recordingToSave: AudioRecording, forCharacterID characterID: UUID? = nil) {
        // Ensure title is not empty, this should ideally be validated in the View or ViewModel before calling
        guard !recordingToSave.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("Recording title cannot be empty.")
            // Optionally, set currentRecording to nil or handle error appropriately
            return
        }
        coreDataManager.saveAudioRecording(recordingToSave, forCharacterID: characterID)
        loadRecordings() // Refresh the list
        currentRecording = nil // Clear after saving
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
    
    func playRecording(recording: AudioRecording) {
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