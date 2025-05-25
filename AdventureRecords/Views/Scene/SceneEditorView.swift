import SwiftUI
import PhotosUI

struct SceneEditorView: View {
    @Environment(\.dismiss) var dismiss

    @State private var title: String
    @State private var description: String
    @State private var showImagePicker = false
    @State private var coverImage: UIImage?
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var atmosphere: SceneAtmosphere
    @State private var showAudioPicker = false
    @State private var showImmersiveMode = false // 控制沉浸模式显示
    @State private var tags: [String] = []
    @State private var tagSuggestions: [String] = []
    @State private var showTagSuggestions: Bool = false
    @State private var newTag: String
    
    private var onSave: (AdventureScene) -> Void
    private var onCancel: () -> Void
    private var isEditing: Bool
    private var existingScene: AdventureScene?
    
    // 创建新场景
    init(onSave: @escaping (AdventureScene) -> Void, onCancel: @escaping () -> Void) {
        self._title = State(initialValue: "")
        self._description = State(initialValue: "")
        self.onSave = onSave
        self.onCancel = onCancel
        self.isEditing = false
        self.existingScene = nil
        self._atmosphere = State(initialValue: .default)
        self._tags = State(initialValue: [])
        self._tagSuggestions = State(initialValue: SceneViewModel.shared.getAllTags())
        self._newTag = State(initialValue: "")
    }
    
    // 编辑现有场景
    init(scene: AdventureScene? = nil, onSave: @escaping (AdventureScene) -> Void, onCancel: @escaping () -> Void) {
        self.onSave = onSave
        self.onCancel = onCancel
        
        if let scene = scene {
            self._title = State(initialValue: scene.title)
            self._description = State(initialValue: scene.description)
            self._coverImage = State(initialValue: scene.coverImage)
            self._tags = State(initialValue: scene.tags)
            self._atmosphere = State(initialValue: scene.atmosphere)
            self.isEditing = true
            self.existingScene = scene
        } else {
            self._title = State(initialValue: "")
            self._description = State(initialValue: "")
            self._coverImage = State(initialValue: nil)
            self._tags = State(initialValue: [])
            self._atmosphere = State(initialValue: .default)
            self.isEditing = false
            self.existingScene = nil
        }
        
        self._tagSuggestions = State(initialValue: SceneViewModel.shared.getAllTags())
        self._newTag = State(initialValue: "")
    }
    
    // 标签建议相关方法
    var filteredTagSuggestions: [String] {
        if newTag.isEmpty {
            // 当输入为空时，显示所有尚未添加的标签
            return tagSuggestions.filter { !tags.contains($0) }
        } else {
            // 当有输入时，过滤出匹配的标签
            return tagSuggestions.filter { 
                $0.localizedCaseInsensitiveContains(newTag) && !tags.contains($0)
            }
        }
    }
    
    func updateTagSuggestions() {
        // 更新标签建议列表
        tagSuggestions = SceneViewModel.shared.getAllTags()
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
                    sceneToUpdate.coverImage = coverImage
                    sceneToUpdate.atmosphere = atmosphere
                    sceneToUpdate.tags = tags
                    onSave(sceneToUpdate)
                } else {
                    let newScene = AdventureScene(
                        id: UUID(),
                        title: title,
                        description: description,
                        coverImage: coverImage,
                        atmosphere: atmosphere,
                        tags: tags
                    )
                    onSave(newScene)
                }
            },
            saveDisabled: title.isEmpty
        ) {
            Form {
                // 基本信息区域
                Section {
                    VStack(alignment: .leading, spacing: 16) {
                        // 场景名称
                        VStack(alignment: .leading, spacing: 8) {
                            Text("场景名称").font(.caption).foregroundColor(.secondary)
                            
                            TextField("输入场景名称", text: $title)
                                .font(.headline)
                                .padding(12)
                                .background(ThemeManager.shared.secondaryBackgroundColor)
                                .cornerRadius(10)
                        }
                        
                        // 场景描述
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("场景描述").font(.caption).foregroundColor(.secondary)
                                Spacer()
                                Button(action: { showImmersiveMode = true }) {
                                    Label("扩展编辑", systemImage: "arrow.up.left.and.arrow.down.right")
                                        .font(.caption)
                                        .foregroundColor(ThemeManager.shared.accentColor(for: .scene))
                                }
                            }
                            
                            ZStack(alignment: .topLeading) {
                                if description.isEmpty {
                                    Text("请输入场景的描述内容……")
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
                
                // 场景图片区域
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("场景封面").font(.caption).foregroundColor(.secondary)
                        
                        PhotosPicker(
                            selection: $selectedItem,
                            matching: .images,
                            photoLibrary: .shared()
                        ) {
                            if let image = coverImage {
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(height: 200)
                                        .clipShape(RoundedRectangle(cornerRadius: 15))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 15)
                                                .stroke(ThemeManager.shared.accentColor(for: .scene).opacity(0.4), lineWidth: 1)
                                        )
                                    
                                    // 更换图片图标
                                    Image(systemName: "photo.badge.plus.fill")
                                        .font(.title3)
                                        .foregroundColor(.white)
                                        .padding(8)
                                        .background(
                                            Circle()
                                                .fill(ThemeManager.shared.accentColor(for: .scene).opacity(0.8))
                                                .shadow(radius: 2)
                                        )
                                        .offset(x: -10, y: 10)
                                }
                            } else {
                                HStack {
                                    Spacer()
                                    VStack(spacing: 16) {
                                        Image(systemName: "photo.on.rectangle.angled")
                                            .font(.system(size: 40))
                                            .foregroundColor(ThemeManager.shared.accentColor(for: .scene))
                                        
                                        Text("添加场景图片")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                    }
                                    .padding(30)
                                    Spacer()
                                }
                                .frame(height: 180)
                                .background(ThemeManager.shared.secondaryBackgroundColor)
                                .cornerRadius(15)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(ThemeManager.shared.accentColor(for: .scene).opacity(0.2), lineWidth: 1.5)
                                )
                            }
                        }
                        .buttonStyle(ScaleButtonStyle())
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
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                
                // 场景标签区域
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Label("场景标签", systemImage: "tag")
                                .font(.headline)
                                .foregroundColor(ThemeManager.shared.accentColor(for: .scene))
                            
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
                        VStack(spacing: 8) {
                            HStack {
                                TextField("输入新标签", text: $newTag, onEditingChanged: { isEditing in
                                    showTagSuggestions = isEditing
                                    updateTagSuggestions()
                                })
                                .onChange(of: newTag) { _ in
                                    updateTagSuggestions()
                                }
                                .padding(12)
                                .background(ThemeManager.shared.secondaryBackgroundColor)
                                .cornerRadius(10)
                                
                                Button(action: {
                                    let trimmedTag = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
                                    if !trimmedTag.isEmpty && !tags.contains(trimmedTag) {
                                        withAnimation {
                                            tags.append(trimmedTag)
                                            newTag = ""
                                            updateTagSuggestions()
                                        }
                                    }
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(newTag.isEmpty ? .gray : ThemeManager.shared.accentColor(for: .scene))
                                }
                                .disabled(newTag.isEmpty)
                                .padding(.leading, 8)
                            }
                            
                            // 标签建议
                            if showTagSuggestions && !filteredTagSuggestions.isEmpty {
                                TagSuggestionView(
                                    suggestions: filteredTagSuggestions,
                                    onSelectSuggestion: { suggestion in
                                        if !tags.contains(suggestion) {
                                            withAnimation {
                                                tags.append(suggestion)
                                                newTag = ""
                                                updateTagSuggestions()
                                            }
                                        }
                                    },
                                    accentColor: ThemeManager.shared.accentColor(for: .scene)
                                )
                            }
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
                                        .background(ThemeManager.shared.accentColor(for: .scene).opacity(0.15))
                                        .foregroundColor(ThemeManager.shared.accentColor(for: .scene))
                                        .cornerRadius(16)
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                            .frame(maxHeight: 120)
                        }
                    }
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
            .fullScreenCover(isPresented: $showImmersiveMode) {
                ImmersiveEditorView(
                    isPresented: $showImmersiveMode,
                    content: $description,
                    title: title.isEmpty ? "场景编辑" : title
                )
            }
        }
    }
}

// 按钮缩放动画样式
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}