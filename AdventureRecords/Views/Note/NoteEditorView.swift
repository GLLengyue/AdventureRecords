//  NoteEditorView.swift
//  AdventureRecords
//  笔记编辑视图
import SwiftUI

struct NoteEditorView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var noteViewModel: NoteViewModel
    @EnvironmentObject var characterViewModel: CharacterViewModel
    @EnvironmentObject var sceneViewModel: SceneViewModel

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
                Section(header: Text("基本信息")) {
                    TextField("标题", text: $title)
                    HStack {
                        TextEditor(text: $content)
                            .frame(height: 100)
                        
                        Button(action: { showImmersiveMode = true }) {
                            Image(systemName: "arrow.up.left.and.arrow.down.right")
                                .foregroundColor(ThemeManager.shared.accentColor(for: .note))
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
                
                Section(header: Text("关联角色")) {
                    ForEach(selectedCharacterIDs, id: \.self) { charID in
                        Text(characterViewModel.characters.first(where: { $0.id == charID })?.name ?? "未知角色")
                    }
                    Button(action: { showCharacterPicker = true }) {
                        Label("选择角色", systemImage: "person.badge.plus")
                    }
                    Button(action: { showingCharacterEditor = true }) {
                        Label("创建新角色", systemImage: "plus.circle.fill")
                    }
                }
                
                Section(header: Text("关联场景")) {
                    ForEach(selectedSceneIDs, id: \.self) { sceneID in
                        Text(sceneViewModel.scenes.first(where: { $0.id == sceneID })?.title ?? "未知场景")
                    }
                    Button(action: { showScenePicker = true }) {
                        Label("选择场景", systemImage: "map.badge.plus")
                    }
                    Button(action: { showingSceneEditor = true }) {
                        Label("创建新场景", systemImage: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showCharacterPicker) {
                CharacterPickerView(selectedCharacterIDs: $selectedCharacterIDs)
                    .environmentObject(characterViewModel)
            }
            .sheet(isPresented: $showScenePicker) {
                ScenePickerView(selectedSceneIDs: $selectedSceneIDs)
                    .environmentObject(sceneViewModel)
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