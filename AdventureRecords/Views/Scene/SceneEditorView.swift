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
    }
    
    // 编辑现有场景
    init(scene: AdventureScene, onSave: @escaping (AdventureScene) -> Void, onCancel: @escaping () -> Void) {
        self._title = State(initialValue: scene.title)
        self._description = State(initialValue: scene.description)
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
                    sceneToUpdate.coverImage = coverImage
                    sceneToUpdate.atmosphere = atmosphere
                    onSave(sceneToUpdate)
                } else {
                    let newScene = AdventureScene(
                        id: UUID(),
                        title: title,
                        description: description,
                        coverImage: coverImage,
                        atmosphere: atmosphere
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