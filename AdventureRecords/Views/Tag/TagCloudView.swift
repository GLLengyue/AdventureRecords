import SwiftUI

struct TagCloudView: View {
    @StateObject private var characterViewModel = CharacterViewModel.shared
    @StateObject private var sceneViewModel = SceneViewModel.shared
    @StateObject private var noteViewModel = NoteViewModel.shared
    
    @State private var selectedTag: String? = nil
    @State private var selectedCharacter: Character? = nil
    @State private var selectedScene: AdventureScene? = nil
    @State private var selectedNote: NoteBlock? = nil
    
    // 获取所有标签
    var allTags: [String] {
        var tags = Set<String>()
        
        // 收集角色标签
        for character in characterViewModel.characters {
            for tag in character.tags {
                tags.insert(tag)
            }
        }
        
        // 收集场景标签
        for scene in sceneViewModel.scenes {
            for tag in scene.tags {
                tags.insert(tag)
            }
        }
        
        // 收集笔记标签
        for note in noteViewModel.notes {
            for tag in note.tags {
                tags.insert(tag)
            }
        }
        
        return Array(tags).sorted()
    }
    
    // 获取与标签相关的内容
    var filteredCharacters: [Character] {
        guard let tag = selectedTag else { return [] }
        return characterViewModel.characters.filter { $0.tags.contains(tag) }
    }
    
    var filteredScenes: [AdventureScene] {
        guard let tag = selectedTag else { return [] }
        return sceneViewModel.scenes.filter { $0.tags.contains(tag) }
    }
    
    var filteredNotes: [NoteBlock] {
        guard let tag = selectedTag else { return [] }
        return noteViewModel.notes.filter { $0.tags.contains(tag) }
    }
    
    var body: some View {
        ListContainer(
            module: .note,
            title: "标签云",
            searchText: .constant(""),
            content: {
                // 标签云
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("标签云")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if allTags.isEmpty {
                            VStack(spacing: 20) {
                                Spacer()
                                
                                Image(systemName: "tag.slash")
                                    .font(.system(size: 64))
                                    .foregroundColor(.gray.opacity(0.6))
                                
                                Text("暂无标签")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, minHeight: 200)
                        } else {
                            FlowLayout(spacing: 10) {
                                ForEach(allTags, id: \.self) { tag in
                                    TagButton(
                                        tag: tag,
                                        isSelected: selectedTag == tag,
                                        onTap: {
                                            if selectedTag == tag {
                                                selectedTag = nil
                                            } else {
                                                selectedTag = tag
                                            }
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
                
                // 分隔线
                Divider()
                
                // 内容区域
                if let selectedTag = selectedTag {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            Text("标签：\(selectedTag)")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            // 角色部分
                            if !filteredCharacters.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Label("角色", systemImage: "person.2")
                                            .font(.headline)
                                            .foregroundColor(ThemeManager.shared.accentColor(for: .character))
                                        
                                        Spacer()
                                        
                                        Text("\(filteredCharacters.count)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.gray.opacity(0.1))
                                            .cornerRadius(10)
                                    }
                                    .padding(.horizontal)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 12) {
                                            ForEach(filteredCharacters) { character in
                                                CharacterItemView(character: character) {
                                                    selectedCharacter = character
                                                }
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                                .padding(.bottom, 8)
                                
                                Divider()
                            }
                            
                            // 场景部分
                            if !filteredScenes.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Label("场景", systemImage: "film")
                                            .font(.headline)
                                            .foregroundColor(ThemeManager.shared.accentColor(for: .scene))
                                        
                                        Spacer()
                                        
                                        Text("\(filteredScenes.count)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.gray.opacity(0.1))
                                            .cornerRadius(10)
                                    }
                                    .padding(.horizontal)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 12) {
                                            ForEach(filteredScenes) { scene in
                                                SceneItemView(scene: scene) {
                                                    selectedScene = scene
                                                }
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                                .padding(.bottom, 8)
                                
                                Divider()
                            }
                            
                            // 笔记部分
                            if !filteredNotes.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Label("笔记", systemImage: "note.text")
                                            .font(.headline)
                                            .foregroundColor(ThemeManager.shared.accentColor(for: .note))
                                        
                                        Spacer()
                                        
                                        Text("\(filteredNotes.count)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.gray.opacity(0.1))
                                            .cornerRadius(10)
                                    }
                                    .padding(.horizontal)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 12) {
                                            ForEach(filteredNotes) { note in
                                                NoteItemView(note: note) {
                                                    selectedNote = note
                                                }
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                                .padding(.bottom, 8)
                            }
                            
                            if filteredCharacters.isEmpty && filteredScenes.isEmpty && filteredNotes.isEmpty {
                                VStack(spacing: 20) {
                                    Spacer()
                                    
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 64))
                                        .foregroundColor(.gray.opacity(0.6))
                                    
                                    Text("没有找到相关内容")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity, minHeight: 200)
                            }
                        }
                        .padding(.vertical)
                    }
                } else {
                    VStack(spacing: 20) {
                        Spacer()
                        
                        Image(systemName: "tag")
                            .font(.system(size: 64))
                            .foregroundColor(.gray.opacity(0.6))
                        
                        Text("请选择一个标签查看相关内容")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        )
        .sheet(item: $selectedCharacter) { character in
            NavigationStack {
                CharacterDetailView(CharacterID: character.id)
            }
        }
        .sheet(item: $selectedScene) { scene in
            NavigationStack {
                SceneDetailView(sceneID: scene.id)
            }
        }
        .sheet(item: $selectedNote) { note in
            NoteBlockDetailView(noteID: note.id)
        }
    }
}

// 标签按钮组件
struct TagButton: View {
    let tag: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 4) {
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10))
                }
                
                Text(tag)
                    .lineLimit(1)
            }
            .font(.subheadline)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                isSelected ?
                Color.accentColor.opacity(0.2) :
                ThemeManager.shared.secondaryBackgroundColor
            )
            .foregroundColor(
                isSelected ?
                Color.accentColor :
                ThemeManager.shared.primaryTextColor
            )
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ?
                        Color.accentColor :
                        Color.gray.opacity(0.3),
                        lineWidth: 1
                    )
            )
        }
    }
}

// 角色项目视图
struct TagCloudCharacterItemView: View {
    let character: Character
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // 头像
                ZStack {
                    Circle()
                        .fill(ThemeManager.shared.accentColor(for: .character).opacity(0.1))
                        .frame(width: 70, height: 70)
                    
                    if let avatar = character.avatar {
                        Image(uiImage: avatar)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 64, height: 64)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(ThemeManager.shared.accentColor(for: .character).opacity(0.3), lineWidth: 2)
                            )
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(ThemeManager.shared.accentColor(for: .character))
                    }
                }
                
                // 名称
                Text(character.name)
                    .font(.caption)
                    .foregroundColor(ThemeManager.shared.primaryTextColor)
                    .lineLimit(1)
                    .frame(width: 80)
            }
            .padding(.vertical, 8)
        }
    }
}

// 场景项目视图
struct TagCloudSceneItemView: View {
    let scene: AdventureScene
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // 封面
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(ThemeManager.shared.accentColor(for: .scene).opacity(0.1))
                        .frame(width: 100, height: 70)
                    
                    if let coverImage = scene.coverImage {
                        Image(uiImage: coverImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 94, height: 64)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(ThemeManager.shared.accentColor(for: .scene).opacity(0.3), lineWidth: 2)
                            )
                    } else {
                        Image(systemName: "photo.on.rectangle.angled.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundColor(ThemeManager.shared.accentColor(for: .scene))
                    }
                }
                
                // 标题
                Text(scene.title)
                    .font(.caption)
                    .foregroundColor(ThemeManager.shared.primaryTextColor)
                    .lineLimit(1)
                    .frame(width: 100)
            }
            .padding(.vertical, 8)
        }
    }
}

// 笔记项目视图
struct TagCloudNoteItemView: View {
    let note: NoteBlock
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // 图标
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(ThemeManager.shared.accentColor(for: .note).opacity(0.1))
                        .frame(width: 100, height: 70)
                    
                    if false {
                        // Image(uiImage: image)
                        //     .resizable()
                        //     .scaledToFill()
                        //     .frame(width: 94, height: 64)
                        //     .clipShape(RoundedRectangle(cornerRadius: 6))
                        //     .overlay(
                        //         RoundedRectangle(cornerRadius: 6)
                        //             .stroke(ThemeManager.shared.accentColor(for: .note).opacity(0.3), lineWidth: 2)
                        //     )
                    } else {
                        Image(systemName: "note.text")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundColor(ThemeManager.shared.accentColor(for: .note))
                    }
                }
                
                // 标题
                Text(note.title)
                    .font(.caption)
                    .foregroundColor(ThemeManager.shared.primaryTextColor)
                    .lineLimit(1)
                    .frame(width: 100)
            }
            .padding(.vertical, 8)
        }
    }
}
