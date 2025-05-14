import SwiftUI

struct SceneEditorView: View {
    @EnvironmentObject var viewModel: SceneViewModel
    @Environment(\.dismiss) var dismiss

    @State private var title: String
    @State private var description: String
    @State private var relatedCharacterIDs: [UUID]
    @State private var relatedNoteIDs: [UUID]
    @State private var showImagePicker = false
    @State private var sceneImage: UIImage?
    
    private var onSave: (AdventureScene) -> Void
    private var onCancel: () -> Void
    private var isEditing: Bool
    private var existingScene: AdventureScene?
    
    // 创建新场景
    init(onSave: @escaping (AdventureScene) -> Void, onCancel: @escaping () -> Void) {
        self._title = State(initialValue: "")
        self._description = State(initialValue: "")
        self._relatedCharacterIDs = State(initialValue: [])
        self._relatedNoteIDs = State(initialValue: [])
        self.onSave = onSave
        self.onCancel = onCancel
        self.isEditing = false
        self.existingScene = nil
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
        self.existingScene = scene
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
                    NavigationLink(destination: CharacterPickerView(selectedCharacterIDs: $relatedCharacterIDs).environmentObject(CharacterViewModel())) {
                        Text("已关联 \(relatedCharacterIDs.count) 个角色")
                    }
                }
                
                Section(header: Text("关联笔记")) {
                    Text("已关联 \(relatedNoteIDs.count) 个笔记")
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
                        if var sceneToUpdate = existingScene {
                            sceneToUpdate.title = title
                            sceneToUpdate.description = description
                            sceneToUpdate.relatedCharacterIDs = relatedCharacterIDs
                            sceneToUpdate.relatedNoteIDs = relatedNoteIDs
                            onSave(sceneToUpdate)
                        } else {
                            let newScene = AdventureScene(
                                id: UUID(),
                                title: title,
                                description: description,
                                relatedCharacterIDs: relatedCharacterIDs,
                                relatedNoteIDs: relatedNoteIDs,
                            )
                            onSave(newScene)
                        }
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