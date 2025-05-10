//  AudioRecordingView.swift
//  AdventureRecords
//  音频录制视图
import SwiftUI

struct AudioRecordingView: View {
    var onSave: (AudioRecording) -> Void
    var onCancel: () -> Void
    
    @State private var isRecording = false
    @State private var recordingTitle = ""
    @State private var recordingURL: URL? = nil
    @State private var audioRecordings: [AudioRecording] = DataModule.audioRecordings
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("录音标题")) {
                    TextField("输入标题", text: $recordingTitle)
                }
                
                Section {
                    HStack {
                        Spacer()
                        Button(action: {
                            isRecording.toggle()
                            if isRecording {
                                // 开始录音
                                startRecording()
                            } else {
                                // 停止录音
                                stopRecording()
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(isRecording ? Color.red : Color.blue)
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.white)
                            }
                        }
                        Spacer()
                    }
                    .padding()
                    
                    if isRecording {
                        Text("正在录音...")
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            .navigationTitle("添加语音记录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        onCancel()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        if let url = recordingURL {
                            let newRecording = AudioRecording(
                                id: UUID(),
                                title: recordingTitle.isEmpty ? "录音 \(Date())" : recordingTitle,
                                recordingURL: url,
                                date: Date()
                            )
                            onSave(newRecording)
                        }
                    }
                    .disabled(recordingURL == nil || isRecording)
                }
            }
        }
    }
    
    // 在实际应用中，这些方法需要实现真正的录音功能
    private func startRecording() {
        // 实现录音开始逻辑
        // 使用AVAudioRecorder等
    }
    
    private func stopRecording() {
        // 实现录音停止逻辑
        // 保存录音文件并获取URL
        // 这里模拟一个URL
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        recordingURL = documentsDirectory.appendingPathComponent("recording_\(Date().timeIntervalSince1970).m4a")
    }
}

#Preview {
    AudioRecordingView(
        onSave: { _ in },
        onCancel: {}
    )
}