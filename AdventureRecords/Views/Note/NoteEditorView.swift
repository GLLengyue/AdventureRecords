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
    @State private var showCreateScene = false
    
    private var onSave: (NoteBlock) -> Void
    private var onCancel: () -> Void
    private var existingNoteID: UUID?
    private var isEditing: Bool
    
    init(preselectedCharacterID: UUID? = nil, onSave: @escaping (NoteBlock) -> Void, onCancel: @escaping () -> Void) {
        self._title = State(initialValue: "")
        self._content = State(initialValue: "")
        self._selectedCharacterIDs = State(initialValue: preselectedCharacterID != nil ? [preselectedCharacterID!] : [])
        self._selectedSceneIDs = State(initialValue: [])
        self.onSave = onSave
        self.onCancel = onCancel
        self.existingNoteID = nil
        self.isEditing = false
    }
    
    init(note: NoteBlock?, preselectedCharacterID: UUID? = nil, onSave: @escaping (NoteBlock) -> Void, onCancel: @escaping () -> Void) {
        self._title = State(initialValue: note?.title ?? "")
        self._content = State(initialValue: note?.content ?? "")
        var initialCharIDs = note?.relatedCharacterIDs ?? []
        if let preID = preselectedCharacterID, !initialCharIDs.contains(preID) {
            initialCharIDs.append(preID)
        }
        self._selectedCharacterIDs = State(initialValue: initialCharIDs)
        self._selectedSceneIDs = State(initialValue: note?.relatedSceneIDs ?? [])
        self.onSave = onSave
        self.onCancel = onCancel
        self.existingNoteID = note?.id
        self.isEditing = true
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("基本信息")) {
                    TextField("标题", text: $title)
                    TextEditor(text: $content)
                        .frame(height: 100)
                }
                
                Section(header: Text("关联角色")) {
                    ForEach(selectedCharacterIDs, id: \.self) { charID in
                        Text(characterViewModel.characters.first(where: { $0.id == charID })?.name ?? "未知角色")
                    }
                    Button(action: { showCharacterPicker = true }) {
                        Label("选择角色", systemImage: "person.badge.plus")
                    }
                }
                
                Section(header: Text("关联场景")) {
                    ForEach(selectedSceneIDs, id: \.self) { sceneID in
                        Text(sceneViewModel.scenes.first(where: { $0.id == sceneID })?.title ?? "未知场景")
                    }
                    Button(action: { showScenePicker = true }) {
                        Label("选择场景", systemImage: "map.badge.plus")
                    }
                    Button(action: { showCreateScene = true }) {
                        Label("创建新场景", systemImage: "plus.circle.fill")
                    }
                }
            }
            .navigationTitle(isEditing ? "编辑笔记" : "新建笔记")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        onCancel()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveNoteAction()
                    }
                    .disabled(title.isEmpty)
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
            .sheet(isPresented: $showCreateScene) {
                SceneCreationView {
                    newScene in
                    sceneViewModel.addScene(newScene)
                    selectedSceneIDs.append(newScene.id)
                }
                .environmentObject(sceneViewModel)
            }
        }
    }
    
    private func saveNoteAction() {
        let noteToSave = NoteBlock(
            id: existingNoteID ?? UUID(),
            title: title,
            content: content,
            relatedCharacterIDs: selectedCharacterIDs,
            relatedSceneIDs: selectedSceneIDs,
            date: Date()
        )
        onSave(noteToSave)
    }
}

#Preview {
    NavigationStack {
        NoteEditorView(onSave: { _ in print("Preview Save") }, onCancel: { print("Preview Cancel") })
            .environmentObject(NoteViewModel())
            .environmentObject(CharacterViewModel())
            .environmentObject(SceneViewModel())
    }
}