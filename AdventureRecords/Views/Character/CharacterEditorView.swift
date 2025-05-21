//  CharacterEditorView.swift
//  AdventureRecords
//  角色编辑视图
import SwiftUI
import PhotosUI

struct CharacterEditorView: View {
    @Environment(\.dismiss) var dismiss
    
    // 使用单例
    private let audioViewModel = AudioViewModel.shared
    
    // 状态变量
    @State private var name: String
    @State private var description: String
    @State private var tags: [String]
    @State private var avatar: UIImage?
    @State private var selectedItem: PhotosPickerItem?
    @State private var showRecordingSheet: Bool
    @State private var newTag: String
    @State private var recordingForRenameSheet: AudioRecording? = nil
    @State private var recordingForDeleteSheet: AudioRecording? = nil
    @State private var newRecordingName: String = ""
    @State private var showingDeleteConfirmationFor: AudioRecording? = nil
    @State private var showImmersiveMode = false // 新增状态：控制沉浸模式显示

    // Original Character card, if editing
    private var existingCharacter: Character?
    
    private var relatedRecordings: [AudioRecording] {
        guard let ids = existingCharacter?.audioRecordings?.map({ $0.id }) else { return [] }
        return audioViewModel.recordings.filter { ids.contains($0.id) }
    }
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

        self._showRecordingSheet = State(initialValue: false)
        self._newTag = State(initialValue: "")
        self.existingCharacter = card
    }
    
    var body: some View {
        EditorContainer(
            module: .character,
            title: existingCharacter == nil ? "新建角色" : "编辑角色",
            cancelAction: {
                onCancel()
            },
            saveAction: {
                if var editedCharacter = existingCharacter {
                    editedCharacter.name = name
                    editedCharacter.description = description
                    editedCharacter.avatar = avatar
                    editedCharacter.tags = tags
                    onSave(editedCharacter)
                } else {
                    let cardToSave = Character(
                        name: name,
                        description: description,
                        avatar: avatar,
                        tags: tags
                    )
                    onSave(cardToSave)
                }
            },
            saveDisabled: name.isEmpty
        ) {
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
                        HStack{
                            TextEditor(text: $description)
                                .frame(minHeight: 100)
                        Button(action: { showImmersiveMode = true }) {
                            Image(systemName: "arrow.up.left.and.arrow.down.right")
                                .foregroundColor(ThemeManager.shared.accentColor(for: .character))
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        }
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

                if existingCharacter != nil {
                    Section(header: Text("录音")) {
                        if relatedRecordings.isEmpty {
                            Text("暂无录音")
                                .foregroundColor(.secondary)
                        }
                        ForEach(relatedRecordings) { recording in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(recording.title)
                                        .font(.headline)
                                    Text("录制于: \(recording.date, style: .date) \(recording.date, style: .time)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .contentShape(Rectangle()) // 确保整个 HStack 区域对上下文菜单交互响应
                                .contextMenu {
                                    Button {
                                        self.newRecordingName = recording.title // 为重命名 sheet 预填名称
                                        self.recordingForRenameSheet = recording // 触发重命名 sheet
                                    } label: {
                                        Label("重命名", systemImage: "pencil")
                                    }

                                    Button(role: .destructive) {
                                        self.recordingForDeleteSheet = recording // 触发删除确认 sheet
                                    } label: {
                                        Label("删除", systemImage: "trash")
                                    }
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
                            }
                        }
                        Button("添加录音") {
                            showRecordingSheet = true
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showRecordingSheet) {
            AudioRecordingCreationView(characterID: existingCharacter!.id)
        }
        .sheet(item: $recordingForRenameSheet) { recordingToRename in
            VStack(spacing: 20) {
                Text("重命名录音")
                    .font(.title2).bold()
                Text("当前名称: \(recordingToRename.title)")
                TextField("新名称", text: $newRecordingName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                HStack(spacing: 20) {
                    Button("取消") {
                        recordingForRenameSheet = nil
                        newRecordingName = "" // Clear the name
                    }
                    .padding()
                    .contentShape(Rectangle())
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.primary)
                    .cornerRadius(10)
                    
                    Button("保存") {
                        var recordingToUpdate = recordingToRename
                        recordingToUpdate.title = newRecordingName.trimmingCharacters(in: .whitespacesAndNewlines)
                        print("new title: \(recordingToUpdate.title)")
                        audioViewModel.updateRecording(recordingToUpdate)
                        recordingForRenameSheet = nil
                        newRecordingName = "" // Clear the name
                    }
                    .padding()
                    .contentShape(Rectangle())
                    .frame(maxWidth: .infinity)
                    .background(newRecordingName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray.opacity(0.5) : Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .disabled(newRecordingName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal)
            }
            .padding()
            .presentationDetents([.height(280)])
        }
        .sheet(item: $recordingForDeleteSheet) { recordingToDelete in
            VStack(spacing: 20) {
                Text("确认删除")
                    .font(.title2).bold()
                Text("您确定要删除录音 \"\(recordingToDelete.title)\" 吗？此操作无法撤销。")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                HStack(spacing: 20) {
                    Button("取消") {
                        recordingForDeleteSheet = nil
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.primary)
                    .cornerRadius(10)
                    
                    Button("删除") {
                        audioViewModel.deleteRecording(recordingToDelete)
                        // if let charId = existingCharacter?.id {
                        //     viewModel.refreshCharacter(charId)
                        // }
                        recordingForDeleteSheet = nil
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .padding()
            .presentationDetents([.height(240)])
        }
        .fullScreenCover(isPresented: $showImmersiveMode) { // 使用 fullScreenCover 展示沉浸模式
            ImmersiveEditorView(isPresented: $showImmersiveMode, content: $description)
        }
    }
}