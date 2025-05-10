//  SceneView.swift
//  AdventureRecords
//  场景管理列表视图
import SwiftUI

struct SceneView: View {
    @State private var scenes: [AdventureScene] = DataModule.availableScenes
    @State private var selectedScene: AdventureScene?
    @State private var showDetail = false
    @State private var showEditor = false
    @State private var isCreatingNew = false
    @State private var showDeleteAlert = false
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(scenes, id: \.id) { scene in
                    Button(action: {
                        selectedScene = scene
                        showDetail = true
                    }) {
                        HStack {
                            // 这里可以添加场景的缩略图
                            Image(systemName: "map")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.blue)
                            
                            VStack(alignment: .leading) {
                                Text(scene.title).font(.headline)
                                Text(scene.description).font(.subheadline).foregroundColor(.secondary)
                                
                                // 显示关联的角色和笔记数量
                                HStack {
                                    if !scene.relatedCharacterIDs.isEmpty {
                                        Label("\(scene.relatedCharacterIDs.count)", systemImage: "person.2")
                                            .font(.caption)
                                    }
                                    
                                    if !scene.relatedNoteIDs.isEmpty {
                                        Label("\(scene.relatedNoteIDs.count)", systemImage: "note.text")
                                            .font(.caption)
                                    }
                                }
                            }
                        }
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            selectedScene = scene
                            showDeleteAlert = true
                        } label: {
                            Label("删除", systemImage: "trash")
                        }
                        
                        Button {
                            selectedScene = scene
                            isCreatingNew = false
                            showEditor = true
                        } label: {
                            Label("编辑", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
                }
            }
            .navigationTitle("场景管理")
            .toolbar {
                Button(action: {
                    isCreatingNew = true
                    showEditor = true
                }) {
                    Label("新建场景", systemImage: "plus")
                }
            }
            .sheet(isPresented: $showDetail) {
                if let scene = selectedScene {
                    SceneDetailView(AdventureScene: scene)
                }
            }
            .sheet(isPresented: $showEditor) {
                if isCreatingNew {
                    SceneEditorView(onSave: { newScene in
                        scenes.append(newScene)
                        showEditor = false
                    }, onCancel: {
                        showEditor = false
                    })
                } else if let index = scenes.firstIndex(where: { $0.id == selectedScene?.id }) {
                    SceneEditorView(scene: scenes[index], onSave: { updatedScene in
                        scenes[index] = updatedScene
                        showEditor = false
                    }, onCancel: {
                        showEditor = false
                    })
                }
            }
            .alert("确认删除", isPresented: $showDeleteAlert) {
                Button("取消", role: .cancel) {}
                Button("删除", role: .destructive) {
                    if let selectedScene = selectedScene, let index = scenes.firstIndex(where: { $0.id == selectedScene.id }) {
                        scenes.remove(at: index)
                    }
                }
            } message: {
                Text("确定要删除场景 \(selectedScene?.title ?? "") 吗？此操作无法撤销。")
            }
        }
    }
}

// 场景编辑器视图
struct SceneEditorView: View {
    @State private var title: String
    @State private var description: String
    @State private var relatedCharacterIDs: [UUID]
    @State private var relatedNoteIDs: [UUID]
    @State private var showImagePicker = false
    @State private var sceneImage: UIImage?
    
    private var onSave: (AdventureScene) -> Void
    private var onCancel: () -> Void
    private var isEditing: Bool
    
    // 创建新场景
    init(onSave: @escaping (AdventureScene) -> Void, onCancel: @escaping () -> Void) {
        self._title = State(initialValue: "")
        self._description = State(initialValue: "")
        self._relatedCharacterIDs = State(initialValue: [])
        self._relatedNoteIDs = State(initialValue: [])
        self.onSave = onSave
        self.onCancel = onCancel
        self.isEditing = false
    }
    
    // 编辑现有场景
    init(scene: AdventureScene, onSave: @escaping (AdventureScene) -> Void, onCancel: @escaping () -> Void) {
        self._title = State(initialValue: scene.title)
        self._description = State(initialValue: scene.description)
        self._relatedCharacterIDs = State(initialValue: scene.relatedCharacterIDs)
        self._relatedNoteIDs = State(initialValue: scene.relatedNoteIDs)
        self.onSave = onSave
        self.onCancel = onCancel
        self.isEditing = true
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("基本信息")) {
                    TextField("场景名称", text: $title)
                    
                    ZStack(alignment: .topLeading) {
                        if description.isEmpty {
                            Text("场景描述")
                                .foregroundColor(Color(UIColor.placeholderText))
                                .padding(.top, 8)
                                .padding(.leading, 5)
                        }
                        TextEditor(text: $description)
                            .frame(minHeight: 100)
                    }
                }
                
                Section(header: Text("场景图片")) {
                    Button(action: {
                        showImagePicker = true
                    }) {
                        HStack {
                            if let image = sceneImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 100)
                            } else {
                                Label("添加图片", systemImage: "photo")
                            }
                        }
                    }
                }
                
                // 这里可以添加关联角色和笔记的选择器
                Section(header: Text("关联角色")) {
                    Text("已关联 \(relatedCharacterIDs.count) 个角色")
                    // 实际项目中应该有角色选择器
                }
                
                Section(header: Text("关联笔记")) {
                    Text("已关联 \(relatedNoteIDs.count) 个笔记")
                    // 实际项目中应该有笔记选择器
                }
            }
            .navigationTitle(isEditing ? "编辑场景" : "新建场景")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        onCancel()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        let scene = AdventureScene(
                            id: UUID(),
                            title: title,
                            description: description,
                            relatedCharacterIDs: relatedCharacterIDs,
                            relatedNoteIDs: relatedNoteIDs
                        )
                        onSave(scene)
                    }
                    .disabled(title.isEmpty)
                }
            }
            .sheet(isPresented: $showImagePicker) {
                // 图片选择器
                Text("图片选择器将在这里实现")
            }
        }
    }
}

#Preview {
    SceneView()
}
