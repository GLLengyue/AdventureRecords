//  CharacterEditorView.swift
//  AdventureRecords
//  角色编辑视图
import SwiftUI
import PhotosUI

struct CharacterEditorView: View {
    var card: CharacterCard? = nil
    var onSave: (CharacterCard) -> Void
    var onCancel: () -> Void

    @State private var character: CharacterCard
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var tagsInput: String = ""
    @State private var selectedImage: UIImage? = nil
    @State private var showImagePicker = false
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var audioRecordings: [AudioRecording] = DataModule.audioRecordings
    @State private var isRecording = false
    @State private var recordingTitle = ""
    @State private var showRecordingSheet = false

    init(card: CharacterCard? = nil, onSave: @escaping (CharacterCard) -> Void, onCancel: @escaping () -> Void) {
        self.card = card
        self.onSave = onSave
        self.onCancel = onCancel

        if let card = card {
            _name = State(initialValue: card.name)
            _description = State(initialValue: card.description)
            _tagsInput = State(initialValue: card.tags.joined(separator: ", "))
            _selectedImage = State(initialValue: card.avatar)
            _audioRecordings = State(initialValue: card.audioRecordings ?? [])
            character = card
        } else {
            character = CharacterCard(id: UUID(), name: "未知角色", description: "", avatar: nil, audioRecordings: nil, tags: [], noteIDs: [], sceneIDs: [])
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("基本信息")) {
                    TextField("角色名称", text: $name)
                    TextField("角色描述", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                    TextField("标签 (用逗号分隔)", text: $tagsInput)
                }

                Section(header: Text("角色头像")) {
                    VStack {
                        if let selectedImage = selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 150, height: 150)
                                .clipShape(Circle())
                                .padding()
                        } else {
                            Image(systemName: "person.crop.circle")
                                .resizable()
                                .frame(width: 150, height: 150)
                                .padding()
                        }

                        PhotosPicker(
                            selection: $selectedItem,
                            matching: .images,
                            photoLibrary: .shared()) {
                                Text("选择头像")
                            }
                            .onChange(of: selectedItem) {
                                Task {
                                    if let data = try? await selectedItem?.loadTransferable(type: Data.self),
                                       let uiImage = UIImage(data: data) {
                                        selectedImage = uiImage
                                    }
                                }
                            }
                    }
                    .frame(maxWidth: .infinity)
                }

                Section(header: Text("语音记录")) {
                    ForEach(audioRecordings) { recording in
                        HStack {
                            Image(systemName: "waveform")
                                .foregroundColor(.blue)
                            VStack(alignment: .leading) {
                                Text(recording.title)
                                    .font(.headline)
                                Text(recording.date, style: .date)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Button(action: {
                                // 播放录音功能
                                // 实际项目中需要实现音频播放器
                            }) {
                                Image(systemName: "play.circle")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    .onDelete { indexSet in
                        audioRecordings.remove(atOffsets: indexSet)
                    }

                    Button(action: {
                        showRecordingSheet = true
                    }) {
                        Label("添加语音记录", systemImage: "mic")
                    }
                }
            }
            .navigationTitle(card == nil ? "创建角色" : "编辑角色")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        onCancel()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        let tags = tagsInput.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) }

                        let newCard = CharacterCard(
                            id: card?.id ?? UUID(),
                            name: name,
                            description: description,
                            avatar: selectedImage,
                            audioRecordings: audioRecordings.isEmpty ? nil : audioRecordings,
                            tags: tags,
                            noteIDs: card?.noteIDs ?? [],
                            sceneIDs: card?.sceneIDs ?? []
                        )

                        onSave(newCard)
                    }
                    .disabled(name.isEmpty)
                }
            }
            .sheet(isPresented: $showRecordingSheet) {
                AudioRecordingView { newRecording in
                    audioRecordings.append(newRecording)
                    showRecordingSheet = false
                } onCancel: {
                    showRecordingSheet = false
                }
            }
        }
    }
}

#Preview {
    CharacterEditorView(
        onSave: { _ in },
        onCancel: {}
    )
}