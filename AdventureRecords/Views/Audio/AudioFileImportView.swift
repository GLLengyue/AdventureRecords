import SwiftUI
import UniformTypeIdentifiers
import AVFoundation

// 创建一个类来处理音频播放和代理
class AudioPreviewController: NSObject, AVAudioPlayerDelegate, ObservableObject {
    @Published var isPlaying: Bool = false
    private var audioPlayer: AVAudioPlayer?
    
    func play(url: URL) {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            isPlaying = true
        } catch {
            print("播放预览失败: \(error)")
        }
    }
    
    func stop() {
        audioPlayer?.stop()
        isPlaying = false
    }
    
    // MARK: - AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
    }
    
    // 获取音频时长
    func getDuration(for url: URL) -> TimeInterval? {
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            return player.duration
        } catch {
            print("无法获取音频时长: \(error)")
            return nil
        }
    }
}

struct AudioFileImportView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel = AudioViewModel.shared
    @StateObject private var audioController = AudioPreviewController()
    
    let characterID: UUID?
    var onSave: (() -> Void)?
    
    @State private var title: String = ""
    @State private var isImporting: Bool = false
    @State private var importedAudioURL: URL? = nil
    @State private var showingPreview: Bool = false
    @State private var errorMessage: String? = nil
    @State private var audioDuration: TimeInterval = 0
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("音频文件")) {
                    Button(action: {
                        isImporting = true
                    }) {
                        HStack {
                            Image(systemName: "doc.badge.plus")
                                .foregroundColor(.blue)
                            Text(importedAudioURL == nil ? "选择音频文件" : "更换音频文件")
                        }
                    }
                    
                    if let url = importedAudioURL {
                        HStack {
                            Text("已选择: \(url.lastPathComponent)")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                            Spacer()
                            
                            if showingPreview {
                                Button(action: {
                                    togglePlayback()
                                }) {
                                    Image(systemName: audioController.isPlaying ? "stop.circle.fill" : "play.circle.fill")
                                        .foregroundColor(audioController.isPlaying ? .red : .blue)
                                        .font(.title2)
                                }
                            }
                        }
                        
                        if audioDuration > 0 {
                            Text("时长: \(formatDuration(audioDuration))")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section(header: Text("标题")) {
                    TextField("输入音频标题", text: $title)
                }
                
                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                }
                
                Section {
                    Button(action: saveImportedAudio) {
                        Text("保存")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(canSave ? Color.blue : Color.gray)
                            )
                    }
                    .disabled(!canSave)
                    .listRowInsets(EdgeInsets())
                    .padding(.horizontal)
                }
            }
            .navigationTitle("导入音频")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        audioController.stop()
                        dismiss()
                    }
                }
            }
            .fileImporter(
                isPresented: $isImporting,
                allowedContentTypes: [.audio, .mp3, .wav, .mpeg4Audio],
                allowsMultipleSelection: false
            ) { result in
                handleFileImport(result)
            }
        }
    }
    
    private var canSave: Bool {
        return !title.isEmpty && importedAudioURL != nil
    }
    
    private func handleFileImport(_ result: Result<[URL], Error>) {
        do {
            guard let selectedURL = try result.get().first else { return }
            
            // 创建一个安全的文件URL访问
            if selectedURL.startAccessingSecurityScopedResource() {
                defer { selectedURL.stopAccessingSecurityScopedResource() }
                
                // 尝试读取文件数据以验证权限
                do {
                    // 先尝试读取文件头部数据，验证是否有读取权限
                    let _ = try Data(contentsOf: selectedURL, options: .alwaysMapped)
                    
                    // 验证文件是否为有效的音频文件
                    if let duration = audioController.getDuration(for: selectedURL) {
                        audioDuration = duration
                        importedAudioURL = selectedURL
                        showingPreview = true
                        errorMessage = nil
                    } else {
                        errorMessage = "无法读取音频文件，文件格式可能不受支持"
                        print("音频文件预览失败")
                    }
                } catch {
                    errorMessage = "无法读取文件: \(error.localizedDescription)"
                    print("文件读取失败: \(error)")
                }
            } else {
                errorMessage = "无法获取文件访问权限"
            }
        } catch {
            errorMessage = "导入失败: \(error.localizedDescription)"
            print("文件导入失败: \(error)")
        }
    }
    
    private func togglePlayback() {
        guard let url = importedAudioURL else { return }
        
        if audioController.isPlaying {
            audioController.stop()
        } else {
            audioController.play(url: url)
        }
    }
    
    private func saveImportedAudio() {
        guard let sourceURL = importedAudioURL, !title.isEmpty else { return }
        
        if let newRecording = viewModel.importAudioFile(from: sourceURL, withTitle: title) {
            viewModel.saveRecording(recordingToSave: newRecording, forCharacterID: characterID)
            onSave?()
            audioController.stop()
            dismiss()
        } else {
            errorMessage = "导入音频文件失败"
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// 扩展UTType以支持更多音频格式
extension UTType {
    static var mp3: UTType { UTType(filenameExtension: "mp3")! }
    static var wav: UTType { UTType(filenameExtension: "wav")! }
    static var mpeg4Audio: UTType { UTType(filenameExtension: "m4a")! }
}
