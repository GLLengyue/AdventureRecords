//  CharacterEditorView.swift
//  AdventureRecords
//  角色编辑视图
import SwiftUI
import PhotosUI

struct CharacterEditorView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: CharacterViewModel
    
    // 状态变量
    @State private var name: String
    @State private var description: String
    @State private var tags: [String]
    @State private var avatar: UIImage?
    @State private var selectedItem: PhotosPickerItem?
    @State private var audioRecordings: [AudioRecording]
    @State private var showRecordingSheet: Bool
    
    // Original Character card, if editing
    private var existingCharacterCard: CharacterCard?
    
    // 回调闭包
    var onSave: (CharacterCard) -> Void
    var onCancel: () -> Void
    
    // 创建新角色卡
    init(onSave: @escaping (CharacterCard) -> Void, onCancel: @escaping () -> Void) {
        self.onSave = onSave
        self.onCancel = onCancel
        self._name = State(initialValue: "")
        self._description = State(initialValue: "")
        self._tags = State(initialValue: [])
        self._avatar = State(initialValue: nil)
        self._selectedItem = State(initialValue: nil)
        self._audioRecordings = State(initialValue: [])
        self._showRecordingSheet = State(initialValue: false)
        self.existingCharacterCard = nil
    }
    
    // 编辑现有角色卡
    init(card: CharacterCard!, onSave: @escaping (CharacterCard) -> Void, onCancel: @escaping () -> Void) {
        self.onSave = onSave
        self.onCancel = onCancel
        self._name = State(initialValue: card.name)
        self._description = State(initialValue: card.description)
        self._tags = State(initialValue: card.tags)
        self._avatar = State(initialValue: card.avatar)
        self._selectedItem = State(initialValue: nil)
        self._audioRecordings = State(initialValue: card.audioRecordings ?? [])
        self._showRecordingSheet = State(initialValue: false)
        self.existingCharacterCard = card
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
                        Text(tag)
                    }
                    Button("添加标签") {
                        // TODO: 实现标签添加功能
                    }
                }

                Section(header: Text("录音")) {
                    ForEach(audioRecordings) { recording in
                        Text(recording.title)
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
                        if var editedCharacterCard = existingCharacterCard {
                            editedCharacterCard.name = name
                            editedCharacterCard.description = description
                            editedCharacterCard.avatar = avatar
                            editedCharacterCard.audioRecordings = audioRecordings
                            editedCharacterCard.tags = tags
                            onSave(editedCharacterCard)
                        }
                        else {
                            let cardToSave = CharacterCard(
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
                AudioRecordingView()
            }
        }
    }
}

#Preview {
    NavigationStack {
        CharacterEditorView(
            onSave: { _ in print("Preview Save") },
            onCancel: { print("Preview Cancel") }
        )
        .environmentObject(CharacterViewModel())
    }
} 