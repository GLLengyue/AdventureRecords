import AVFoundation
import SwiftUI

struct AudioPickerView: View {
    @Environment(\.dismiss) var dismiss
    @State private var audioFiles: [URL] = []
    @State private var selectedAudio: URL?
    @State private var isRecording = false
    @State private var audioRecorder: AVAudioRecorder?
    @State private var audioPlayer: AVAudioPlayer?

    var onSelect: (URL?) -> Void

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("录制新音效")) {
                    HStack {
                        Button(action: {
                            if isRecording {
                                stopRecording()
                            } else {
                                startRecording()
                            }
                        }) {
                            Label(isRecording ? "停止录制" : "开始录制",
                                  systemImage: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                                .foregroundColor(isRecording ? .red : .blue)
                        }

                        if isRecording {
                            Text("正在录制...")
                                .foregroundColor(.red)
                        }
                    }
                }

                Section(header: Text("已有音效")) {
                    if audioFiles.isEmpty {
                        Text("暂无音效文件")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(audioFiles, id: \.self) { audioURL in
                            HStack {
                                Button(action: {
                                    playAudio(audioURL)
                                }) {
                                    Label("播放", systemImage: "play.circle.fill")
                                }

                                Text(audioURL.lastPathComponent)

                                Spacer()

                                if selectedAudio == audioURL {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedAudio = audioURL
                            }
                        }
                    }
                }
            }
            .navigationTitle("选择环境音效")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("确定") {
                        onSelect(selectedAudio)
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadAudioFiles()
            }
        }
    }

    private func loadAudioFiles() {
        // 从文档目录加载音频文件
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }

        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsDirectory,
                                                               includingPropertiesForKeys: nil)
            audioFiles = fileURLs.filter { $0.pathExtension == "m4a" }
        } catch {
            print("Error loading audio files: \(error)")
        }
    }

    private func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("\(Date().timeIntervalSince1970).m4a")

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.record()
            isRecording = true
        } catch {
            print("Could not start recording: \(error)")
        }
    }

    private func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        loadAudioFiles()
    }

    private func playAudio(_ url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Could not play audio: \(error)")
        }
    }

    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
