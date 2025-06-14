import AVFoundation
import Combine
import Foundation

class AudioPlayerManager: ObservableObject {
    private var audioPlayer: AVAudioPlayer?
    private var delegateWrapper: DelegateWrapper? // Keep a strong reference to the delegate
    private var audioSession: AVAudioSession = .sharedInstance()

    @Published var isPlaying: Bool = false
    @Published var currentlyPlayingURL: URL? = nil
    @Published var playbackProgress: Double = 0.0 // 0.0 to 1.0
    @Published var playbackDuration: TimeInterval = 0.0

    private var progressTimer: Timer?

    init() {
        setupAudioSession()
    }

    private func setupAudioSession() {
        do {
            try audioSession.setCategory(.playback, mode: .default)
            // No need to activate session here, player will activate it on play.
        } catch {
            debugPrint("Failed to set up audio session: \(error.localizedDescription)")
        }
    }

    func play(url: URL) {
        // Stop any currently playing audio first
        if audioPlayer != nil {
            stop()
        }

        do {
            try audioSession.setActive(true) // Activate session before playing
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            delegateWrapper = DelegateWrapper(manager: self)
            audioPlayer?.delegate = delegateWrapper // Using a wrapper for delegate
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()

            currentlyPlayingURL = url
            isPlaying = true
            playbackDuration = audioPlayer?.duration ?? 0.0
            startProgressTimer()
            debugPrint("AudioPlayerManager: Started playing \(url.lastPathComponent)")
        } catch {
            debugPrint("Failed to play audio: \(error.localizedDescription)")
            isPlaying = false
            currentlyPlayingURL = nil
            playbackDuration = 0.0
        }
    }

    func pause() {
        guard let player = audioPlayer, player.isPlaying else { return }
        player.pause()
        isPlaying = false
        stopProgressTimer()
        debugPrint("AudioPlayerManager: Paused \(currentlyPlayingURL?.lastPathComponent ?? "audio")")
    }

    func resume() {
        guard let player = audioPlayer, !player.isPlaying, currentlyPlayingURL != nil else { return }
        do {
            try audioSession.setActive(true) // Re-activate session if needed
            player.play()
            isPlaying = true
            startProgressTimer()
            debugPrint("AudioPlayerManager: Resumed \(currentlyPlayingURL?.lastPathComponent ?? "audio")")
        } catch {
            debugPrint("Failed to resume audio: \(error.localizedDescription)")
            isPlaying = false
        }
    }

    func stop() {
        guard let player = audioPlayer else { return }
        player.stop()
        isPlaying = false
        currentlyPlayingURL = nil
        playbackProgress = 0.0
        playbackDuration = 0.0
        stopProgressTimer()
        debugPrint("AudioPlayerManager: Stopped audio")
        // Deactivate session when stopping if desired, or keep it active for quick resume
        // deactivateAudioSession() // Optional: if you want to release the session immediately
    }

    func stopAndDeactivateSession() {
        stop()
        deactivateAudioSession()
        debugPrint("AudioPlayerManager: Stopped audio and deactivated session")
    }

    private func deactivateAudioSession() {
        do {
            try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            debugPrint("Failed to deactivate audio session: \(error.localizedDescription)")
        }
    }

    private func startProgressTimer() {
        stopProgressTimer() // Ensure no existing timer is running
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.audioPlayer, player.isPlaying else { return }
            self.playbackProgress = player.duration > 0 ? player.currentTime / player.duration : 0.0
        }
    }

    private func stopProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }

    // Called by the delegate wrapper when playback finishes
    fileprivate func audioDidFinishPlaying() {
        isPlaying = false
        currentlyPlayingURL = nil
        playbackProgress = 0.0
        // Do not reset playbackDuration here, might be useful to see total duration
        stopProgressTimer()
        debugPrint("AudioPlayerManager: Finished playing")
        // Optional: Deactivate session after playback finishes
        // deactivateAudioSession()
    }

    deinit {
        stopProgressTimer()
        audioPlayer?.delegate = nil // Clean up delegate
        debugPrint("AudioPlayerManager deinitialized")
    }
}

// AVAudioPlayerDelegate requires NSObjectProtocol, so we use a helper class
private class DelegateWrapper: NSObject, AVAudioPlayerDelegate {
    weak var manager: AudioPlayerManager?

    init(manager: AudioPlayerManager) {
        self.manager = manager
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        manager?.audioDidFinishPlaying()
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        debugPrint("AudioPlayerManager: Decode error - \(error?.localizedDescription ?? "Unknown error")")
        manager?.audioDidFinishPlaying() // Treat as finished to reset state
    }
}
