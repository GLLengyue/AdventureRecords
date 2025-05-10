//  NoteEditorView.swift
//  AdventureRecords
//  笔记编辑视图
import SwiftUI

struct NoteEditorView: View {
    @State var note: NoteBlock?
    @Environment(\.dismiss) var dismiss
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var selectedCharacters: [UUID] = []
    @State private var selectedScenes: [UUID] = []
    @State private var showCharacterPicker = false
    @State private var showScenePicker = false
    @State private var showCreateScene = false
    
    // 示例数据，实际应用中应从数据存储中获取
    @State private var availableCharacters: [CharacterCard] = DataModule.characterCards
    
    @State private var availableScenes: [AdventureScene] = DataModule.availableScenes
    
    // 可选参数，用于从角色详情页创建笔记时预选角色
    var preselectedCharacterID: UUID? = nil
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("基本信息")) {
                    TextField("标题", text: $title)
                    TextEditor(text: $content)
                        .frame(height: 120)
                }
                
                Section(header: Text("关联角色")) {
                    ForEach(selectedCharacters, id: \.self) { characterID in
                        if let character = availableCharacters.first(where: { $0.id == characterID }) {
                            HStack {
                                Text(character.name)
                                Spacer()
                                Button(action: {
                                    selectedCharacters.removeAll(where: { $0 == characterID })
                                }) {
                                    Image(systemName: "minus.circle")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                    
                    Button(action: {
                        showCharacterPicker = true
                    }) {
                        Label("添加角色", systemImage: "person.badge.plus")
                    }
                }
                
                Section(header: Text("关联场景")) {
                    ForEach(selectedScenes, id: \.self) { sceneID in
                        if let scene = availableScenes.first(where: { $0.id == sceneID }) {
                            HStack {
                                Text(scene.title)
                                Spacer()
                                Button(action: {
                                    selectedScenes.removeAll(where: { $0 == sceneID })
                                }) {
                                    Image(systemName: "minus.circle")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                    
                    Button(action: {
                        showScenePicker = true
                    }) {
                        Label("选择已有场景", systemImage: "map.badge.plus")
                    }
                    
                    Button(action: {
                        showCreateScene = true
                    }) {
                        Label("创建新场景", systemImage: "plus.square")
                    }
                }
            }
            .navigationTitle(note == nil ? "新建笔记" : "编辑笔记")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveNote()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
            }
            .onAppear {
                if let note = note {
                    title = note.title
                    content = note.content
                    selectedCharacters = note.relatedCharacterIDs
                    selectedScenes = note.relatedSceneIDs
                }
                
                // 如果有预选角色，添加到选中列表
                if let preselectedID = preselectedCharacterID {
                    if !selectedCharacters.contains(preselectedID) {
                        selectedCharacters.append(preselectedID)
                    }
                }
            }
            .sheet(isPresented: $showCharacterPicker) {
                CharacterPickerView(selectedCharacters: $selectedCharacters, availableCharacters: availableCharacters)
            }
            .sheet(isPresented: $showScenePicker) {
                ScenePickerView(selectedScenes: $selectedScenes, availableScenes: availableScenes)
            }
            .sheet(isPresented: $showCreateScene) {
                SceneCreationView(onSave: { newScene in
                    availableScenes.append(newScene)
                    selectedScenes.append(newScene.id)
                    showCreateScene = false
                })
            }
        }
    }
    
    private func saveNote() {
        let newNote = NoteBlock(
            id: note?.id ?? UUID(),
            title: title,
            content: content,
            relatedCharacterIDs: selectedCharacters,
            relatedSceneIDs: selectedScenes,
            date: Date()
        )
        
        // 这里应该实现保存到数据存储的逻辑
        // 同时更新关联的角色和场景的引用
        updateCharacterReferences(noteID: newNote.id)
        updateSceneReferences(noteID: newNote.id)
    }
    
    private func updateCharacterReferences(noteID: UUID) {
        // 更新角色的笔记引用
        for characterID in selectedCharacters {
            if let index = availableCharacters.firstIndex(where: { $0.id == characterID }) {
                if !availableCharacters[index].noteIDs.contains(noteID) {
                    availableCharacters[index].noteIDs.append(noteID)
                }
            }
        }
    }
    
    private func updateSceneReferences(noteID: UUID) {
        // 更新场景的笔记引用
        for sceneID in selectedScenes {
            if let index = availableScenes.firstIndex(where: { $0.id == sceneID }) {
                if !availableScenes[index].relatedNoteIDs.contains(noteID) {
                    availableScenes[index].relatedNoteIDs.append(noteID)
                }
                
                // 同时更新场景关联的角色
                for characterID in selectedCharacters {
                    if !availableScenes[index].relatedCharacterIDs.contains(characterID) {
                        availableScenes[index].relatedCharacterIDs.append(characterID)
                    }
                }
            }
        }
    }
}

#Preview {
    NoteEditorView()
}