//  CharacterEditorView.swift
//  AdventureRecords
//  角色编辑视图
import SwiftUI
import PhotosUI

struct CharacterEditorView: View {
    @Environment(\.dismiss) var dismiss
    
    // 使用单例
    @StateObject private var audioViewModel = AudioViewModel.shared
    @StateObject private var audioPlayerManager = AudioPlayerManager()
    
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
    
    func actionOnSave() {
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
    }

    var body: some View {
        EditorContainer(
            module: .character,
            title: existingCharacter == nil ? "新建角色" : "编辑角色",
            cancelAction: {
                onCancel()
            },
            saveAction: {
                actionOnSave()
            },
            saveDisabled: name.isEmpty
        ) {
            Form {
                // 基本信息区域
                Section {
                    VStack(alignment: .leading, spacing: 16) {
                        // 角色名称
                        VStack(alignment: .leading, spacing: 8) {
                            Text("角色名称").font(.caption).foregroundColor(.secondary)
                            
                            TextField("输入角色名称", text: $name)
                                .font(.headline)
                                .padding(12)
                                .background(ThemeManager.shared.secondaryBackgroundColor)
                                .cornerRadius(10)
                        }
                        
                        // 角色描述
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("角色描述").font(.caption).foregroundColor(.secondary)
                                Spacer()
                                Button(action: { showImmersiveMode = true }) {
                                    Label("扩展编辑", systemImage: "arrow.up.left.and.arrow.down.right")
                                        .font(.caption)
                                        .foregroundColor(ThemeManager.shared.accentColor(for: .character))
                                }
                            }
                            
                            ZStack(alignment: .topLeading) {
                                if description.isEmpty {
                                    Text("请输入角色的描述内容……")
                                        .foregroundColor(Color(UIColor.placeholderText))
                                        .padding(12)
                                }
                                TextEditor(text: $description)
                                    .frame(minHeight: 120)
                                    .padding(6)
                                    .background(ThemeManager.shared.secondaryBackgroundColor)
                                    .cornerRadius(10)
                            }
                        }
                    }
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                
                // 头像区域
                Section {
                    VStack(alignment: .center, spacing: 12) {
                        Text("角色头像").font(.caption).foregroundColor(.secondary)
                        
                        PhotosPicker(
                            selection: $selectedItem,
                            matching: .images,
                            photoLibrary: .shared()
                        ) {
                            VStack(spacing: 16) {
                                ZStack {
                                    if let image = avatar {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 160, height: 160)
                                            .clipShape(Circle())
                                            .overlay(
                                                Circle()
                                                    .stroke(ThemeManager.shared.accentColor(for: .character), lineWidth: 2)
                                            )
                                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                                    } else {
                                        Circle()
                                            .fill(ThemeManager.shared.accentColor(for: .character).opacity(0.1))
                                            .frame(width: 160, height: 160)
                                            .overlay(
                                                Circle()
                                                    .stroke(ThemeManager.shared.accentColor(for: .character).opacity(0.3), lineWidth: 1.5)
                                            )
                                        
                                        Image(systemName: "person.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 80, height: 80)
                                            .foregroundColor(ThemeManager.shared.accentColor(for: .character).opacity(0.8))
                                    }
                                    
                                    // 更换图片图标
                                    Circle()
                                        .fill(ThemeManager.shared.accentColor(for: .character).opacity(0.8))
                                        .frame(width: 44, height: 44)
                                        .overlay(
                                            Image(systemName: avatar == nil ? "plus" : "arrow.triangle.2.circlepath")
                                                .font(.system(size: 18, weight: .bold))
                                                .foregroundColor(.white)
                                        )
                                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                                        .offset(x: 50, y: 50)
                                }
                                
                                Text(avatar == nil ? "添加头像" : "更换头像")
                                    .font(.subheadline)
                                    .foregroundColor(ThemeManager.shared.accentColor(for: .character))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                        }
                        .buttonStyle(ScaleButtonStyle())
                        .onChange(of: selectedItem) {
                            Task {
                                if let data = try? await selectedItem?.loadTransferable(type: Data.self),
                                   let uiImage = UIImage(data: data) {
                                    avatar = uiImage
                                }
                            }
                        }
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                
                // 标签区域
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Label("角色标签", systemImage: "tag")
                                .font(.headline)
                                .foregroundColor(ThemeManager.shared.accentColor(for: .character))
                            
                            Spacer()
                            
                            if !tags.isEmpty {
                                Text("\(tags.count)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(10)
                            }
                        }
                        
                        // 标签输入区
                        HStack {
                            TextField("输入新标签", text: $newTag)
                                .padding(12)
                                .background(ThemeManager.shared.secondaryBackgroundColor)
                                .cornerRadius(10)
                            
                            Button(action: {
                                let trimmedTag = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
                                if !trimmedTag.isEmpty && !tags.contains(trimmedTag) {
                                    withAnimation {
                                        tags.append(trimmedTag)
                                        newTag = ""
                                    }
                                }
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(newTag.isEmpty ? .gray : ThemeManager.shared.accentColor(for: .character))
                            }
                            .disabled(newTag.isEmpty)
                            .padding(.leading, 8)
                        }
                        
                        // 现有标签显示
                        if tags.isEmpty {
                            Text("没有添加标签")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 20)
                        } else {
                            ScrollView {
                                FlowLayout(spacing: 8) {
                                    ForEach(tags, id: \.self) { tag in
                                        HStack(spacing: 4) {
                                            Text(tag)
                                                .font(.subheadline)
                                            
                                            Button(action: {
                                                withAnimation {
                                                    if let index = tags.firstIndex(of: tag) {
                                                        tags.remove(at: index)
                                                    }
                                                }
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                            .buttonStyle(BorderlessButtonStyle())
                                        }
                                        .padding(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 8))
                                        .background(ThemeManager.shared.accentColor(for: .character).opacity(0.15))
                                        .foregroundColor(ThemeManager.shared.accentColor(for: .character))
                                        .clipShape(Capsule())
                                        .overlay(
                                            Capsule()
                                                .stroke(ThemeManager.shared.accentColor(for: .character).opacity(0.3), lineWidth: 1)
                                        )
                                    }
                                }
                                .padding(.top, 8)
                            }
                            .frame(minHeight: 60)
                        }
                    }
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                
                // 录音区域
                if existingCharacter != nil {
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Label("录音列表", systemImage: "waveform")
                                    .font(.headline)
                                    .foregroundColor(ThemeManager.shared.accentColor(for: .character))
                                
                                Spacer()
                                
                                Text("\(relatedRecordings.count)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(10)
                            }
                            
                            if relatedRecordings.isEmpty {
                                VStack(spacing: 10) {
                                    Image(systemName: "waveform.slash")
                                        .font(.system(size: 32))
                                        .foregroundColor(.secondary.opacity(0.7))
                                        .padding(.bottom, 6)
                                    
                                    Text("暂无录音")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 24)
                                .background(ThemeManager.shared.secondaryBackgroundColor.opacity(0.5))
                                .cornerRadius(12)
                            }
                            
                            ForEach(relatedRecordings) { recording in
                                HStack {
                                    // 录音项视图（左侧主区域）
                                    RecordingItemView(recording: recording, 
                                                    isPlaying: audioPlayerManager.isPlaying && audioPlayerManager.currentlyPlayingURL == recording.recordingURL,
                                                    onPlayPause: {
                                        let audioURL = recording.recordingURL
                                        if audioPlayerManager.isPlaying && audioPlayerManager.currentlyPlayingURL == audioURL {
                                            audioPlayerManager.pause()
                                        } else {
                                            guard audioURL.isFileURL, FileManager.default.fileExists(atPath: audioURL.path) else {
                                                print("Audio file not found at \(audioURL.path)")
                                                return
                                            }
                                            audioPlayerManager.play(url: audioURL)
                                        }
                                    })                                    
                                    Spacer(minLength: 8)
                                    
                                    // 重命名按钮
                                    ZStack {
                                        Color.clear
                                            .frame(width: 44, height: 44)
                                            .contentShape(Rectangle())
                                        
                                        Button(action: {
                                            newRecordingName = recording.title
                                            recordingForRenameSheet = recording
                                        }) {
                                            Image(systemName: "pencil")
                                                .frame(width: 44, height: 44)
                                        }
                                        .buttonStyle(BorderlessButtonStyle())
                                    }
                                    
                                    // 删除按钮
                                    ZStack {
                                        Color.clear
                                            .frame(width: 44, height: 44)
                                            .contentShape(Rectangle())
                                        
                                        Button(action: {
                                            recordingForDeleteSheet = recording
                                        }) {
                                            Image(systemName: "trash")
                                                .foregroundColor(.red)
                                                .frame(width: 44, height: 44)
                                        }
                                        .buttonStyle(BorderlessButtonStyle())
                                    }
                                }
                            }
                        }
                        Button("添加录音") {
                            showRecordingSheet = true
                        }
                        .font(.headline)
                        .foregroundColor(ThemeManager.shared.accentColor(for: .character))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 12)
                        .background(ThemeManager.shared.secondaryBackgroundColor)
                        .cornerRadius(12)
                    }
                }
            }
        }
        .sheet(isPresented: $showRecordingSheet) {
            AudioRecordingCreationView(characterID: existingCharacter!.id, onSave: {
                actionOnSave()
            })
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