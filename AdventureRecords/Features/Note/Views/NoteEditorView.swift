//  NoteEditorView.swift
//  AdventureRecords
//  笔记编辑视图
import SwiftUI

struct NoteEditorView: View {
    var note: NoteBlock? = nil
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = NoteViewModel()
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var selectedCharacterIDs: [UUID] = []
    @State private var selectedSceneIDs: [UUID] = []
    @State private var showCharacterPicker = false
    @State private var showScenePicker = false
    @State private var showCreateScene = false
    
    // 可选参数，用于从角色详情页创建笔记时预选角色
    var preselectedCharacterID: UUID? = nil
    
    var body: some View {
        Form {
            Section(header: Text("基本信息")) {
                TextField("标题", text: $title)
                TextEditor(text: $content)
                    .frame(height: 100)
            }
            
            Section(header: Text("关联角色")) {
                ForEach(viewModel.getRelatedCharacters(for: note ?? NoteBlock(id: UUID(), title: "", content: "", relatedCharacterIDs: [], relatedSceneIDs: [], date: Date()))) { character in
                    Text(character.name)
                }
                Button(action: { showCharacterPicker = true }) {
                    Label("选择角色", systemImage: "person.badge.plus")
                }
            }
            
            Section(header: Text("关联场景")) {
                ForEach(viewModel.getRelatedScenes(for: note ?? NoteBlock(id: UUID(), title: "", content: "", relatedCharacterIDs: [], relatedSceneIDs: [], date: Date()))) { scene in
                    Text(scene.title)
                }
                Button(action: { showScenePicker = true }) {
                    Label("选择场景", systemImage: "map.badge.plus")
                }
                Button(action: { showCreateScene = true }) {
                    Label("创建新场景", systemImage: "plus.circle.fill")
                }
            }
        }
        .navigationTitle(note == nil ? "新建笔记" : "编辑笔记")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("取消") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("保存") {
                    saveNote()
                }
            }
        }
        .sheet(isPresented: $showCharacterPicker) {
            CharacterPickerView(selectedCharacterIDs: $selectedCharacterIDs)
        }
        .sheet(isPresented: $showScenePicker) {
            ScenePickerView(selectedSceneIDs: $selectedSceneIDs)
        }
        .sheet(isPresented: $showCreateScene) {
            SceneCreationView {
                newScene in
                // TODO: 在这里处理新创建的场景
                // 例如: sceneViewModel.addScene(newScene)
                //       selectedSceneIDs.append(newScene.id)
                // 当前 NoteViewModel 没有直接添加场景的方法，这里仅关闭 sheet
                // showCreateScene = false // sheet 会自动处理
            }
        }
        .onAppear {
            if let note = note {
                title = note.title
                content = note.content
                selectedCharacterIDs = note.relatedCharacterIDs
                selectedSceneIDs = note.relatedSceneIDs
            }
            if let preselectedID = preselectedCharacterID {
                selectedCharacterIDs = [preselectedID]
            }
        }
    }
    
    private func saveNote() {
        let noteToSave = NoteBlock(
            id: note?.id ?? UUID(),
            title: title,
            content: content,
            relatedCharacterIDs: selectedCharacterIDs,
            relatedSceneIDs: selectedSceneIDs,
            date: Date()
        )
        
        if note != nil {
            viewModel.updateNote(noteToSave)
        } else {
            viewModel.addNote(noteToSave)
        }
        
        dismiss()
    }
}



#Preview {
    NavigationStack {
        NoteEditorView()
    }
}