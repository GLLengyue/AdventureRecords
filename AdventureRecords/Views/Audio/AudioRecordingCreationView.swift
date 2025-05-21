import SwiftUI

struct AudioRecordingCreationView: View {
    @Environment(\.dismiss) var dismiss
    
    // 使用单例
    @StateObject private var viewModel = AudioViewModel.shared
    @State private var title: String = ""
    // Timer to update recording duration display
    @State private var timer: Timer? = nil
    @State private var recordingDuration: TimeInterval = 0
    let characterID: UUID? // To associate the recording with a character
    var onSave: () -> Void

    var body: some View {
        NavigationStack {
    //         Form {
            Form {
                Section(header: Text("录音信息")) {
                    TextField("标题", text: $title)
                    if viewModel.isRecording {
                        Text("录音中: \(formattedDuration(recordingDuration))")
                            .foregroundColor(.red)
                            .onAppear(perform: startTimer)
                            .onDisappear(perform: stopTimer)
                    } else if let currentRec = viewModel.currentRecording, title.isEmpty {
                        Text("录音已完成，准备保存")
                            .onAppear {
                                // Pre-fill title if a recording was just made
                                self.title = currentRec.title
                                self.recordingDuration = 0 // Reset for next potential recording in this view
                            }
                    }
                }

                Section {
                    Button(action: {
                        toggleRecording()
                    }) {
                        Label(
                            viewModel.isRecording ? "停止录音" : "开始录音",
                            systemImage: viewModel.isRecording ? "stop.circle.fill" : "mic.circle.fill"
                        )
                        .foregroundColor(viewModel.isRecording ? .red : .blue)
                    }
                }
            }
            .navigationTitle("新建录音")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        if viewModel.isRecording {
                            viewModel.stopRecording(save: false)
                        }
                        stopTimer()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveRecording()
                        dismiss()
                    }
                    .disabled(title.isEmpty || viewModel.isRecording || viewModel.currentRecording == nil)
                }
            }
            .onAppear {
                // Reset state when view appears, in case it's reused
                if !viewModel.isRecording {
                   viewModel.currentRecording = nil // Clear any previous recording state
                   title = ""
                   recordingDuration = 0
                }
            }
        }
    }

    private func toggleRecording() {
        if viewModel.isRecording {
            viewModel.stopRecording(save: true)
            stopTimer()
            if let currentRec = viewModel.currentRecording {
                 // Use a default title if the user hasn't entered one yet, 
                 // or update the existing currentRecording's title
                self.title = title.isEmpty ? currentRec.title : title
            }
        } else {
            recordingDuration = 0 // Reset duration
            viewModel.startRecording()
            // Initialize title for new recording if it's empty
            if title.isEmpty {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm"
                title = "录音 \(formatter.string(from: Date()))"
            }
            startTimer()
        }
    }

    private func saveRecording() {
        guard !title.isEmpty, let recordingToSave = viewModel.currentRecording else {
            // Optionally show an alert to the user
            print("Cannot save: Title is empty or no recording available.")
            return
        }
        var finalRecording = recordingToSave
        finalRecording.title = self.title // Ensure the latest title from the text field is used
        viewModel.saveRecording(recordingToSave: finalRecording, forCharacterID: characterID)
        stopTimer()
        // Reset for next potential recording
        viewModel.currentRecording = nil
        self.title = ""
        self.recordingDuration = 0
        onSave()
    }

    private func startTimer() {
        stopTimer() // Ensure any existing timer is stopped
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if viewModel.isRecording {
                recordingDuration += 0.1
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func formattedDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        let millis = Int((duration - Double(minutes * 60) - Double(seconds)) * 10)
        return String(format: "%02d:%02d.%01d", minutes, seconds, millis)
    }
}