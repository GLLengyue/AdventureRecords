//  CharacterEditorView.swift
//  AdventureRecords
//  角色编辑视图
import SwiftUI
import PhotosUI

struct CharacterEditorView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: CharacterViewModel
    @EnvironmentObject var audioViewModel: AudioViewModel // Added for audio playback
    
    // 状态变量
    @State private var name: String
    @State private var description: String
    @State private var tags: [String]
    @State private var avatar: UIImage?
    @State private var selectedItem: PhotosPickerItem?
    @State private var audioRecordings: [AudioRecording]
    @State private var showRecordingSheet: Bool
    @State private var newTag: String
    
    // Original Character card, if editing
    private var existingCharacter: Character?
    
    // 回调闭包
    var onSave: (Character) -> Void
    var onCancel: () -> Void
    
    // 创建新角色卡
    init(onSave: @escaping (Character) -> Void, onCancel: @escaping () -> Void) {
        self.onSave = onSave
        self.onCancel = onCancel
        self._name = State(initialValue: "")
        self._description = State(initialValue: "")
        self._tags = State(initialValue: [])
        self._avatar = State(initialValue: nil)
        self._selectedItem = State(initialValue: nil)
        self._audioRecordings = State(initialValue: [])
        self._showRecordingSheet = State(initialValue: false)
        self._newTag = State(initialValue: "")
        self.existingCharacter = nil
    }
    
    // 编辑现有角色卡
    init(card: Character!, onSave: @escaping (Character) -> Void, onCancel: @escaping () -> Void) {
        self.onSave = onSave
        self.onCancel = onCancel
        self._name = State(initialValue: card.name)
        self._description = State(initialValue: card.description)
        self._tags = State(initialValue: card.tags)
        self._avatar = State(initialValue: card.avatar)
        self._selectedItem = State(initialValue: nil)
        self._audioRecordings = State(initialValue: card.audioRecordings ?? [])
        self._showRecordingSheet = State(initialValue: false)
        self._newTag = State(initialValue: "")
        self.existingCharacter = card
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("基本信息")) {
                    TextField("名称", text: $name)
                    
                    ZStack(alignment: .topLeading) {
                        if description.isEmpty {
                            Text("描述")
                                .foregroundColor(Color(UIColor.placeholderText))
                                .padding(.top, 8)
                                .padding(.leading, 5)
                        }
                        TextEditor(text: $description)
                            .frame(minHeight: 100)
                    }
                }
                
                Section(header: Text("头像")) {
                    PhotosPicker(
                        selection: $selectedItem,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        HStack {
                            if let image = avatar {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 100)
                            } else {
                                Label("添加头像", systemImage: "person.crop.circle.badge.plus")
                            }
                        }
                    }
                    .onChange(of: selectedItem) {
                        Task {
                            if let data = try? await selectedItem?.loadTransferable(type: Data.self),
                               let uiImage = UIImage(data: data) {
                                avatar = uiImage
                            }
                        }
                    }
                }
                
                Section(header: Text("标签")) {
                    ForEach(tags, id: \.self) { tag in
                        HStack {
                            Text(tag)
                            Spacer()
                            Button(action: {
                                if let index = tags.firstIndex(of: tag) {
                                    tags.remove(at: index)
                                }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    
                    HStack {
                        TextField("新标签", text: $newTag)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button(action: {
                            if !newTag.isEmpty && !tags.contains(newTag) {
                                tags.append(newTag)
                                newTag = ""
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                        }
                        .disabled(newTag.isEmpty)
                    }
                }

                Section(header: Text("录音")) {
                    if audioRecordings.isEmpty {
                        Text("暂无录音")
                            .foregroundColor(.secondary)
                    }
                    ForEach(audioRecordings) { recording in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(recording.title)
                                    .font(.headline)
                                Text("录制于: \(recording.date, style: .date) \(recording.date, style: .time)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Button {
                                if audioViewModel.currentlyPlayingAudioID == recording.id && audioViewModel.isPlayingAudio {
                                    audioViewModel.stopPlayback()
                                } else {
                                    audioViewModel.playRecording(recording: recording)
                                }
                            } label: {
                                Image(systemName: audioViewModel.currentlyPlayingAudioID == recording.id && audioViewModel.isPlayingAudio ? "stop.circle.fill" : "play.circle.fill")
                                    .foregroundColor(.blue)
                            }
                            // TODO: Add delete recording button here later
                        }
                    }
                    Button("添加录音") {
                        showRecordingSheet = true
                    }
                }
            }
            .navigationTitle(avatar == nil ? "新建角色" : "编辑角色")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        onCancel()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        if var editedCharacter = existingCharacter {
                            editedCharacter.name = name
                            editedCharacter.description = description
                            editedCharacter.avatar = avatar
                            editedCharacter.audioRecordings = audioRecordings
                            editedCharacter.tags = tags
                            onSave(editedCharacter)
                        }
                        else {
                            let cardToSave = Character(
                                id: UUID(),
                                name: name,
                                description: description,
                                avatar: avatar,
                                audioRecordings: audioRecordings.isEmpty ? nil : audioRecordings,
                                tags: tags,
                                noteIDs: [],
                                sceneIDs: []
                            )
                            onSave(cardToSave)

                        }
                    }
                    .disabled(name.isEmpty)
                }
            }
            .sheet(isPresented: $showRecordingSheet) {
                // Pass the character ID if available (editing existing character)
                // For new characters, ID isn't available until save, so pass nil initially.
                AudioRecordingCreationView(characterID: existingCharacter?.id)
                    .environmentObject(audioViewModel) // Pass AudioViewModel to the sheet
            }
            .onAppear {
                // Reload audio recordings for the character when the view appears or re-appears
                // This is important if recordings were added/deleted in the sheet
                if let charId = existingCharacter?.id {
                    viewModel.refreshCharacter(id: charId)
                    // Update local state if selectedCharacter matches
                    if let updatedCharacter = viewModel.characters.first(where: { $0.id == charId }) {
                         self.audioRecordings = updatedCharacter.audioRecordings ?? []
                    } else if let selChar = viewModel.selectedCharacter, selChar.id == charId {
                         self.audioRecordings = selChar.audioRecordings ?? []
                    }
                }
            }
        }
    }
}