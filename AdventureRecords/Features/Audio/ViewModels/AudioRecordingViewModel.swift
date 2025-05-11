import Foundation
import Combine

class AudioRecordingViewModel: ObservableObject {
    @Published var recordings: [AudioRecording] = []
    private let coreDataManager = CoreDataManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadRecordings()
    }
    
    func loadRecordings() {
        recordings = coreDataManager.fetchAudioRecordings()
    }
    
    func addRecording(_ recording: AudioRecording) {
        coreDataManager.saveAudioRecording(recording)
        loadRecordings()
    }
    
    func updateRecording(_ recording: AudioRecording) {
        coreDataManager.saveAudioRecording(recording)
        loadRecordings()
    }
    
    func deleteRecording(_ recording: AudioRecording) {
        coreDataManager.deleteAudioRecording(recording.id)
        loadRecordings()
    }
} 