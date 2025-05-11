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

#Preview {
    AudioRecordingView()
}