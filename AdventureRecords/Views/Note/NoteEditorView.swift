//  NoteEditorView.swift
//  AdventureRecords
//  笔记编辑视图
import SwiftUI

struct NoteEditorView: View {
    @Environment(\.dismiss) var dismiss
    
    // 使用单例
    @StateObject private var noteViewModel = NoteViewModel.shared
    @StateObject private var characterViewModel = CharacterViewModel.shared
    @StateObject private var sceneViewModel = SceneViewModel.shared

    @State private var title: String
    @State private var content: String
    @State private var selectedCharacterIDs: [UUID]
    @State private var selectedSceneIDs: [UUID]
    
    @State private var showCharacterPicker = false
    @State private var showScenePicker = false
    @State private var showingSceneEditor = false
    @State private var showingCharacterEditor = false
    @State private var showImmersiveMode = false // 控制沉浸模式显示
    
    private var onSave: (NoteBlock) -> Void
    private var onCancel: () -> Void
    private var existingNote: NoteBlock?
    private var isEditing: Bool
    
    init(onSave: @escaping (NoteBlock) -> Void, onCancel: @escaping () -> Void) {
        self._title = State(initialValue: "")
        self._content = State(initialValue: "")
        self._selectedCharacterIDs = State(initialValue: [])
        self._selectedSceneIDs = State(initialValue: [])
        self.onSave = onSave
        self.onCancel = onCancel
        self.existingNote = nil
        self.isEditing = false
    }
    

    init(preselectedCharacterID: UUID? = nil, onSave: @escaping (NoteBlock) -> Void, onCancel: @escaping () -> Void) {
        self._title = State(initialValue: "")
        self._content = State(initialValue: "")
        self._selectedCharacterIDs = State(initialValue: preselectedCharacterID != nil ? [preselectedCharacterID!] : [])
        self._selectedSceneIDs = State(initialValue: [])
        self.onSave = onSave
        self.onCancel = onCancel
        self.existingNote = nil
        self.isEditing = false
    }

    init(preselectedSceneID: UUID? = nil, onSave: @escaping (NoteBlock) -> Void, onCancel: @escaping () -> Void) {
        self._title = State(initialValue: "")
        self._content = State(initialValue: "")
        self._selectedCharacterIDs = State(initialValue: [])
        self._selectedSceneIDs = State(initialValue: preselectedSceneID != nil ? [preselectedSceneID!] : [])
        self.onSave = onSave
        self.onCancel = onCancel
        self.existingNote = nil
        self.isEditing = false
    }
    
    // Initializer for editing an existing note
    init(note: NoteBlock, preselectedCharacterID: UUID? = nil, onSave: @escaping (NoteBlock) -> Void, onCancel: @escaping () -> Void) {
        self._title = State(initialValue: note.title)
        self._content = State(initialValue: note.content)
        var initialCharIDs = note.relatedCharacterIDs
        if let preID = preselectedCharacterID, !initialCharIDs.contains(preID) {
            initialCharIDs.append(preID)
        }
        self._selectedCharacterIDs = State(initialValue: initialCharIDs)
        self._selectedSceneIDs = State(initialValue: note.relatedSceneIDs)
        self.onSave = onSave
        self.onCancel = onCancel
        self.existingNote = note
        self.isEditing = true
    }
    
    var body: some View {
        EditorContainer(
            module: .note,
            title: isEditing ? "编辑笔记" : "新建笔记",
            cancelAction: {
                onCancel()
            },
            saveAction: {
                saveNoteAction()
            },
            saveDisabled: title.isEmpty
        ) {
            Form {
                // 基本信息区域
                Section {
                    VStack(alignment: .leading, spacing: 16) {
                        // 笔记标题
                        VStack(alignment: .leading, spacing: 8) {
                            Text("笔记标题").font(.caption).foregroundColor(.secondary)
                            
                            TextField("输入笔记标题", text: $title)
                                .font(.headline)
                                .padding(12)
                                .background(ThemeManager.shared.secondaryBackgroundColor)
                                .cornerRadius(10)
                        }
                        
                        // 笔记内容
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("笔记内容").font(.caption).foregroundColor(.secondary)
                                Spacer()
                                Button(action: { showImmersiveMode = true }) {
                                    Label("全屏编辑", systemImage: "arrow.up.left.and.arrow.down.right")
                                        .font(.caption)
                                        .foregroundColor(ThemeManager.shared.accentColor(for: .note))
                                }
                            }
                            
                            ZStack(alignment: .topLeading) {
                                if content.isEmpty {
                                    Text("在这里记录你的笔记内容……")
                                        .foregroundColor(Color(UIColor.placeholderText))
                                        .padding(12)
                                }
                                TextEditor(text: $content)
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
                
                // 关联角色区域
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Label("关联角色", systemImage: "person.2")
                                    .font(.headline)
                                    .foregroundColor(ThemeManager.shared.accentColor(for: .character))
                                
                                Spacer()
                                
                                if !selectedCharacterIDs.isEmpty {
                                    Text("\(selectedCharacterIDs.count)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(10)
                                }
                            }
                            
                            if selectedCharacterIDs.isEmpty {
                                HStack {
                                    Text("尚未选择任何角色")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                                .padding(12)
                                .background(ThemeManager.shared.secondaryBackgroundColor.opacity(0.5))
                                .cornerRadius(10)
                            } else {
                                // 显示已选角色
                                VStack(spacing: 10) {
                                    ForEach(selectedCharacterIDs, id: \.self) { charID in
                                        if let character = characterViewModel.getCharacter(id: charID) {
                                            HStack {
                                                CharacterAvatarView(character: character, size: 36)
                                                
                                                Text(character.name)
                                                    .font(.subheadline)
                                                    .fontWeight(.medium)
                                                
                                                Spacer()
                                                
                                                Button(action: {
                                                    selectedCharacterIDs.removeAll { $0 == charID }
                                                }) {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .foregroundColor(.secondary)
                                                }
                                                .buttonStyle(BorderlessButtonStyle())
                                            }
                                            .padding(8)
                                            .background(ThemeManager.shared.secondaryBackgroundColor)
                                            .cornerRadius(10)
                                        }
                                    }
                                }
                            }
                        }
                        
                        HStack {
                            Button(action: { showCharacterPicker = true }) {
                                Label("选择角色", systemImage: "person.badge.plus")
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 12)
                                    .background(ThemeManager.shared.accentColor(for: .character).opacity(0.1))
                                    .foregroundColor(ThemeManager.shared.accentColor(for: .character))
                                    .cornerRadius(8)
                            }
                            .buttonStyle(ScaleButtonStyle())
                            
                            Button(action: { showingCharacterEditor = true }) {
                                Label("创建新角色", systemImage: "plus.circle.fill")
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 12)
                                    .background(ThemeManager.shared.accentColor(for: .character).opacity(0.05))
                                    .foregroundColor(ThemeManager.shared.accentColor(for: .character))
                                    .cornerRadius(8)
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                    }
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                
                // 关联场景区域
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Label("关联场景", systemImage: "film")
                                    .font(.headline)
                                    .foregroundColor(ThemeManager.shared.accentColor(for: .scene))
                                
                                Spacer()
                                
                                if !selectedSceneIDs.isEmpty {
                                    Text("\(selectedSceneIDs.count)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(10)
                                }
                            }
                            
                            if selectedSceneIDs.isEmpty {
                                HStack {
                                    Text("尚未选择任何场景")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                                .padding(12)
                                .background(ThemeManager.shared.secondaryBackgroundColor.opacity(0.5))
                                .cornerRadius(10)
                            } else {
                                // 显示已选场景
                                VStack(spacing: 10) {
                                    ForEach(selectedSceneIDs, id: \.self) { sceneID in
                                        if let scene = sceneViewModel.scenes.first(where: { $0.id == sceneID }) {
                                            HStack {
                                                SceneThumbView(scene: scene, size: 36)
                                                
                                                Text(scene.title)
                                                    .font(.subheadline)
                                                    .fontWeight(.medium)
                                                
                                                Spacer()
                                                
                                                Button(action: {
                                                    selectedSceneIDs.removeAll { $0 == sceneID }
                                                }) {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .foregroundColor(.secondary)
                                                }
                                                .buttonStyle(BorderlessButtonStyle())
                                            }
                                            .padding(8)
                                            .background(ThemeManager.shared.secondaryBackgroundColor)
                                            .cornerRadius(10)
                                        }
                                    }
                                }
                            }
                        }
                        
                        HStack {
                            Button(action: { showScenePicker = true }) {
                                Label("选择场景", systemImage: "map.badge.plus")
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 12)
                                    .background(ThemeManager.shared.accentColor(for: .scene).opacity(0.1))
                                    .foregroundColor(ThemeManager.shared.accentColor(for: .scene))
                                    .cornerRadius(8)
                            }
                            .buttonStyle(ScaleButtonStyle())
                            
                            Button(action: { showingSceneEditor = true }) {
                                Label("创建新场景", systemImage: "plus.circle.fill")
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 12)
                                    .background(ThemeManager.shared.accentColor(for: .scene).opacity(0.05))
                                    .foregroundColor(ThemeManager.shared.accentColor(for: .scene))
                                    .cornerRadius(8)
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                    }
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
            .sheet(isPresented: $showCharacterPicker) {
                CharacterPickerView(selectedCharacterIDs: $selectedCharacterIDs)
            }
            .sheet(isPresented: $showScenePicker) {
                ScenePickerView(selectedSceneIDs: $selectedSceneIDs)
            }
            .sheet(isPresented: $showingSceneEditor) {
                SceneEditorView(
                    onSave: { savedScene in
                        sceneViewModel.addScene(savedScene)
                        showingSceneEditor = false
                    },
                    onCancel: {
                        showingSceneEditor = false
                    }
                )
            }
            .sheet(isPresented: $showingCharacterEditor) {
                CharacterEditorView(
                    onSave: { savedCard in
                        characterViewModel.addCharacter(savedCard)
                        showingCharacterEditor = false
                    },
                    onCancel: {
                        showingCharacterEditor = false
                    }
                )
            }
            .fullScreenCover(isPresented: $showImmersiveMode) {
                ImmersiveEditorView(
                    isPresented: $showImmersiveMode,
                    content: $content,
                    title: title.isEmpty ? "笔记编辑" : title
                )
            }
            
        }
    }
    
    private func saveNoteAction() {
        if var noteToUpdate = existingNote {
            noteToUpdate.title = title
            noteToUpdate.content = content
            noteToUpdate.relatedCharacterIDs = selectedCharacterIDs
            noteToUpdate.relatedSceneIDs = selectedSceneIDs
            noteToUpdate.date = Date() // Update timestamp
            onSave(noteToUpdate)
        } else {
            let newNote = NoteBlock(
                id: UUID(),
                title: title,
                content: content,
                relatedCharacterIDs: selectedCharacterIDs,
                relatedSceneIDs: selectedSceneIDs,
                date: Date()
            )
            onSave(newNote)
        }
    }
}

// 辅助视图组件

// // 按钮缩放动画样式
// struct ScaleButtonStyle: ButtonStyle {
//     func makeBody(configuration: Configuration) -> some View {
//         configuration.label
//             .scaleEffect(configuration.isPressed ? 0.97 : 1)
//             .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
//     }
// }

// 角色头像视图
struct CharacterAvatarView: View {
    let character: Character
    let size: CGFloat
    
    var body: some View {
        if let avatar = character.avatar {
            Image(uiImage: avatar)
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
                .clipShape(Circle())
                .overlay(Circle().stroke(ThemeManager.shared.accentColor(for: .character).opacity(0.3), lineWidth: 1))
        } else {
            ZStack {
                Circle()
                    .fill(ThemeManager.shared.accentColor(for: .character).opacity(0.1))
                    .frame(width: size, height: size)
                
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: size/2, height: size/2)
                    .foregroundColor(ThemeManager.shared.accentColor(for: .character))
            }
        }
    }
}

// 场景缩略图视图
struct SceneThumbView: View {
    let scene: AdventureScene
    let size: CGFloat
    
    var body: some View {
        if let coverImage = scene.coverImage {
            Image(uiImage: coverImage)
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: size/5))
                .overlay(RoundedRectangle(cornerRadius: size/5).stroke(ThemeManager.shared.accentColor(for: .scene).opacity(0.3), lineWidth: 1))
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: size/5)
                    .fill(ThemeManager.shared.accentColor(for: .scene).opacity(0.1))
                    .frame(width: size, height: size)
                
                Image(systemName: "film")
                    .resizable()
                    .scaledToFit()
                    .frame(width: size/2, height: size/2)
                    .foregroundColor(ThemeManager.shared.accentColor(for: .scene))
            }
        }
    }
}