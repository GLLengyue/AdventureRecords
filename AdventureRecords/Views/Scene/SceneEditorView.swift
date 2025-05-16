import SwiftUI
import PhotosUI

struct SceneEditorView: View {
    @EnvironmentObject var viewModel: SceneViewModel
    @Environment(\.dismiss) var dismiss

    @State private var title: String
    @State private var description: String
    @State private var relatedCharacterIDs: [UUID]
    @State private var relatedNoteIDs: [UUID]
    @State private var showImagePicker = false
    @State private var coverImage: UIImage?
    @State private var selectedItem: PhotosPickerItem?
    @State private var atmosphere: SceneAtmosphere
    @State private var showAudioPicker = false
    
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
        self._atmosphere = State(initialValue: .default)
    }
    
    // 编辑现有场景
    init(scene: AdventureScene, onSave: @escaping (AdventureScene) -> Void, onCancel: @escaping () -> Void) {
        self._title = State(initialValue: scene.title)
        self._description = State(initialValue: scene.description)
        self._relatedCharacterIDs = State(initialValue: scene.relatedCharacterIDs)
        self._relatedNoteIDs = State(initialValue: scene.relatedNoteIDs)
        self._coverImage = State(initialValue: scene.coverImage)
        self.onSave = onSave
        self.onCancel = onCancel
        self.isEditing = true
        self.existingScene = scene
        self._atmosphere = State(initialValue: scene.atmosphere)
    }
    
    var body: some View {
        EditorContainer(
            module: .scene,
            title: isEditing ? "编辑场景" : "新建场景",
            cancelAction: {
                onCancel()
            },
            saveAction: {
                if var sceneToUpdate = existingScene {
                    sceneToUpdate.title = title
                    sceneToUpdate.description = description
                    sceneToUpdate.relatedCharacterIDs = relatedCharacterIDs
                    sceneToUpdate.relatedNoteIDs = relatedNoteIDs
                    sceneToUpdate.coverImage = coverImage
                    sceneToUpdate.atmosphere = atmosphere
                    onSave(sceneToUpdate)
                } else {
                    let newScene = AdventureScene(
                        id: UUID(),
                        title: title,
                        description: description,
                        relatedCharacterIDs: relatedCharacterIDs,
                        relatedNoteIDs: relatedNoteIDs,
                        coverImage: coverImage,
                        atmosphere: atmosphere
                    )
                    onSave(newScene)
                }
            },
            saveDisabled: title.isEmpty
        ) {
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
                    PhotosPicker(
                        selection: $selectedItem,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        HStack {
                            if let image = coverImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 200)
                            } else {
                                Label("添加场景图片", systemImage: "photo")
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 100)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .onChange(of: selectedItem) {
                        Task {
                            if let data = try? await selectedItem?.loadTransferable(type: Data.self),
                               let uiImage = UIImage(data: data) {
                                coverImage = uiImage
                            }
                        }
                    }
                }
                Section(header: Text("场景氛围")) {
                    // 背景颜色选择
                    ColorPicker("背景颜色", selection: Binding(
                        get: { atmosphere.backgroundColor },
                        set: { newColor in
                            atmosphere.backgroundColor = newColor
                        }
                    ))
                    
                    // 光照效果选择
                    Picker("光照效果", selection: $atmosphere.lightingEffect) {
                        ForEach(LightingEffect.allCases, id: \.self) { effect in
                            Text(effect.rawValue).tag(effect)
                        }
                    }
                    
                    // 粒子效果选择
                    Picker("粒子效果", selection: $atmosphere.particleEffect) {
                        ForEach(ParticleEffect.allCases, id: \.self) { effect in
                            Text(effect.rawValue).tag(effect)
                        }
                    }
                    
                    // 环境音效选择
                    Button(action: {
                        showAudioPicker = true
                    }) {
                        HStack {
                            Text("环境音效")
                            Spacer()
                            if atmosphere.ambientSound != nil {
                                Text("已选择")
                                    .foregroundColor(.secondary)
                            } else {
                                Text("未选择")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .sheet(isPresented: $showAudioPicker) {
                        AudioPickerView { selectedAudio in
                            atmosphere.ambientSound = selectedAudio
                        }
                    }
                }
            }
        }
    }
}