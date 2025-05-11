//  AudioRecordingView.swift
//  AdventureRecords
//  音频录制视图
import SwiftUI

struct AudioRecordingView: View {
    @StateObject private var viewModel = AudioRecordingViewModel()
    @State private var isRecording = false
    @State private var showRecordingSheet = false
    @State private var selectedRecording: AudioRecording? = nil
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.recordings) { recording in
                    AudioRecordingRow(recording: recording)
                        .onTapGesture {
                            selectedRecording = recording
                        }
                }
            }
            .navigationTitle("录音")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showRecordingSheet = true }) {
                        Image(systemName: "mic.circle")
                    }
                }
            }
            .sheet(isPresented: $showRecordingSheet) {
                AudioRecordingCreationView()
            }
            .onAppear {
                viewModel.loadRecordings()
            }
        }
    }
}

struct AudioRecordingRow: View {
    let recording: AudioRecording
    @StateObject private var viewModel = AudioRecordingViewModel()
    @State private var showDeleteAlert = false
    @State private var isPlaying = false
    
    var body: some View {
        HStack {
            Button(action: {
                isPlaying.toggle()
                // TODO: 实现音频播放逻辑
            }) {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.title)
                    .foregroundColor(.blue)
            }
            
            VStack(alignment: .leading) {
                Text(recording.title)
                    .font(.headline)
                Text(recording.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {
                showDeleteAlert = true
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 8)
        .alert("确认删除", isPresented: $showDeleteAlert) {
            Button("取消", role: .cancel) {}
            Button("删除", role: .destructive) {
                viewModel.deleteRecording(recording)
            }
        } message: {
            Text("确定要删除录音 \(recording.title) 吗？此操作无法撤销。")
        }
    }
}

struct AudioRecordingCreationView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = AudioRecordingViewModel()
    @State private var title = ""
    @State private var isRecording = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("录音信息")) {
                    TextField("标题", text: $title)
                }
                
                Section {
                    Button(action: {
                        isRecording.toggle()
                        // TODO: 实现录音逻辑
                    }) {
                        Label(
                            isRecording ? "停止录音" : "开始录音",
                            systemImage: isRecording ? "stop.circle.fill" : "mic.circle.fill"
                        )
                        .foregroundColor(isRecording ? .red : .blue)
                    }
                }
            }
            .navigationTitle("新建录音")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        // TODO: 保存录音
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AudioRecordingView()
}