import SwiftUI

struct TagCloudView: View {
    @StateObject private var characterViewModel = CharacterViewModel.shared
    @StateObject private var sceneViewModel = SceneViewModel.shared
    @StateObject private var noteViewModel = NoteViewModel.shared
    
    @State private var searchText: String = ""
    @State private var selectedTag: String? = nil
    @State private var selectedCharacter: Character? = nil
    @State private var selectedScene: AdventureScene? = nil
    @State private var selectedNote: NoteBlock? = nil
    @State private var sortOrder: SortOrder = .alphabetical
    
    // 获取所有标签
    // 根据搜索文本过滤并排序标签
    var filteredTags: [String] {
        let filtered = searchText.isEmpty ? allTags : allTags.filter { $0.localizedCaseInsensitiveContains(searchText) }
        
        switch sortOrder {
        case .alphabetical:
            return filtered.sorted()
        case .popularity:
            // 按标签出现频率排序
            let tagFrequency = getTagFrequency()
            return filtered.sorted { tagFrequency[$0, default: 0] > tagFrequency[$1, default: 0] }
        case .count:
            // 按每个标签相关项目数量排序
            return filtered.sorted {
                let count1 = countItemsForTag($0)
                let count2 = countItemsForTag($1)
                return count1 > count2
            }
        }
    }
    
    // 排序选项
    enum SortOrder: String, CaseIterable, Identifiable {
        case alphabetical = "按字母排序"
        case popularity = "按热度排序"
        case count = "按数量排序"
        var id: String { self.rawValue }
    }
    
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
    
    // 获取热门标签（使用频率最高的5个标签）
    // 根据搜索文本过滤热门标签
    var filteredPopularTags: [String] {
        if searchText.isEmpty {
            return popularTags
        } else {
            return popularTags.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    // 获取标签频率字典
    func getTagFrequency() -> [String: Int] {
        var tagFrequency: [String: Int] = [:]
        
        // 计算角色标签频率
        for character in characterViewModel.characters {
            for tag in character.tags {
                tagFrequency[tag, default: 0] += 1
            }
        }
        
        // 计算场景标签频率
        for scene in sceneViewModel.scenes {
            for tag in scene.tags {
                tagFrequency[tag, default: 0] += 1
            }
        }
        
        // 计算笔记标签频率
        for note in noteViewModel.notes {
            for tag in note.tags {
                tagFrequency[tag, default: 0] += 1
            }
        }
        
        return tagFrequency
    }
    
    // 计算标签相关项目数量
    func countItemsForTag(_ tag: String) -> Int {
        let characterCount = characterViewModel.characters.filter { $0.tags.contains(tag) }.count
        let sceneCount = sceneViewModel.scenes.filter { $0.tags.contains(tag) }.count
        let noteCount = noteViewModel.notes.filter { $0.tags.contains(tag) }.count
        return characterCount + sceneCount + noteCount
    }
    
    // 获取热门标签（使用频率最高的5个标签）
    var popularTags: [String] {
        // 按频率排序并取前5个
        let tagFrequency = getTagFrequency()
        let sortedTags = tagFrequency.sorted { $0.value > $1.value }.prefix(5).map { $0.key }
        return sortedTags
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
            searchText: $searchText,
            onSearch: { _ in },
            addAction: nil,
            trailingContent: {
                Menu {
                    ForEach(SortOrder.allCases) { order in
                        Button(action: {
                            withAnimation {
                                sortOrder = order
                            }
                        }) {
                            HStack {
                                Text(order.rawValue)
                                    .font(.system(.body))
                                Spacer()
                                if sortOrder == order {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(ThemeManager.shared.accentColor(for: .note))
                                }
                            }
                            .contentShape(Rectangle())
                        }
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 16, weight: .semibold))
                        .padding(8)
                        .background(ThemeManager.shared.accentColor(for: .note).opacity(0.1))
                        .clipShape(Circle())
                }
            },
            content: {
                // 标签云
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                            // 标签云标题
                            HStack {
                                if !filteredTags.isEmpty {
                                    Text(searchText.isEmpty ? "共 \(allTags.count) 个标签" : "找到 \(filteredTags.count) 个标签")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(10)
                                }
                            }
                            .padding(.horizontal)
                            
                            if searchText.isEmpty && allTags.isEmpty {
                                // 无标签时的提示
                                VStack(spacing: 20) {
                                    Spacer()
                                    
                                    ZStack {
                                        Circle()
                                            .fill(Color.gray.opacity(0.1))
                                            .frame(width: 120, height: 120)
                                        
                                        Image(systemName: "tag.slash")
                                            .font(.system(size: 50))
                                            .foregroundColor(.gray.opacity(0.6))
                                    }
                                    
                                    Text("暂无标签")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                    
                                    Text("在编辑角色、场景或笔记时添加标签")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary.opacity(0.8))
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal)
                                    
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity, minHeight: 300)
                            } else if !searchText.isEmpty && filteredTags.isEmpty {
                                // 搜索无结果时的提示
                                VStack(spacing: 20) {
                                    Spacer()
                                    
                                    ZStack {
                                        Circle()
                                            .fill(Color.gray.opacity(0.1))
                                            .frame(width: 120, height: 120)
                                        
                                        Image(systemName: "magnifyingglass")
                                            .font(.system(size: 50))
                                            .foregroundColor(.gray.opacity(0.6))
                                    }
                                    
                                    Text("没有找到相关标签")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                    
                                    Text("尝试使用其他关键词搜索")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary.opacity(0.8))
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal)
                                    
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity, minHeight: 300)
                            } else {
                                // 标签组
                                VStack(alignment: .leading, spacing: 16) {
                                    // 热门标签区域
                                    if !filteredPopularTags.isEmpty {
                                        VStack(alignment: .leading, spacing: 12) {
                                            Text("热门标签")
                                                .font(.headline)
                                                .foregroundColor(ThemeManager.shared.primaryTextColor)
                                                .padding(.horizontal)
                                            
                                            ScrollView(.horizontal, showsIndicators: false) {
                                                HStack(spacing: 10) {
                                                    ForEach(filteredPopularTags, id: \.self) { tag in
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
                                        .padding(.bottom, 8)
                                        
                                        Divider()
                                            .padding(.horizontal)
                                    }
                                    
                                    // 所有标签区域
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("所有标签")
                                            .font(.headline)
                                            .foregroundColor(ThemeManager.shared.primaryTextColor)
                                            .padding(.horizontal)
                                        
                                        FlowLayout(spacing: 10) {
                                            ForEach(filteredTags, id: \.self) { tag in
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
                            }
                        }
                        .padding(.vertical)
                    // }
                    
                    // 分隔线
                    // Divider()
                    //     .padding(.horizontal)
                    
                    // 内容区域
                    if let selectedTag = selectedTag {
                        // ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // 标签标题
                            HStack {
                                Label("标签：\(selectedTag)", systemImage: "tag.circle.fill")
                                    .font(.title3.bold())
                                    .foregroundColor(tagColor(for: selectedTag))
                                
                                Spacer()
                                
                                // 总数统计
                                let totalItems = filteredCharacters.count + filteredScenes.count + filteredNotes.count
                                Text("\(totalItems) 个相关项目")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal)
                            
                            // 内容统计卡片
                            HStack(spacing: 12) {
                                // 角色统计
                                StatCard(
                                    title: "角色",
                                    count: filteredCharacters.count,
                                    icon: "person.2",
                                    color: ThemeManager.shared.accentColor(for: .character)
                                )
                                
                                // 场景统计
                                StatCard(
                                    title: "场景",
                                    count: filteredScenes.count,
                                    icon: "film",
                                    color: ThemeManager.shared.accentColor(for: .scene)
                                )
                                
                                // 笔记统计
                                StatCard(
                                    title: "笔记",
                                    count: filteredNotes.count,
                                    icon: "note.text",
                                    color: ThemeManager.shared.accentColor(for: .note)
                                )
                            }
                            .padding(.horizontal)
                            
                            // 角色部分
                            if !filteredCharacters.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Label("角色", systemImage: "person.2")
                                            .font(.headline)
                                            .foregroundColor(ThemeManager.shared.accentColor(for: .character))
                                        
                                        Spacer()
                                    }
                                    .padding(.horizontal)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 12) {
                                            ForEach(filteredCharacters) { character in
                                                TagCloudCharacterItemView(character: character) {
                                                    selectedCharacter = character
                                                }
                                                .transition(.scale)
                                            }
                                        }
                                        .padding(.horizontal)
                                        .animation(.spring(), value: filteredCharacters.count)
                                    }
                                }
                                .padding(.vertical, 8)
                                .background(Color.gray.opacity(0.05))
                                .cornerRadius(12)
                                .padding(.horizontal)
                                
                                Divider()
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                            }
                            
                            // 场景部分
                            if !filteredScenes.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Label("场景", systemImage: "film")
                                            .font(.headline)
                                            .foregroundColor(ThemeManager.shared.accentColor(for: .scene))
                                        
                                        Spacer()
                                    }
                                    .padding(.horizontal)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 12) {
                                            ForEach(filteredScenes) { scene in
                                                TagCloudSceneItemView(scene: scene) {
                                                    selectedScene = scene
                                                }
                                                .transition(.scale)
                                            }
                                        }
                                        .padding(.horizontal)
                                        .animation(.spring(), value: filteredScenes.count)
                                    }
                                }
                                .padding(.vertical, 8)
                                .background(Color.gray.opacity(0.05))
                                .cornerRadius(12)
                                .padding(.horizontal)
                                
                                Divider()
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                            }
                            
                            // 笔记部分
                            if !filteredNotes.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Label("笔记", systemImage: "note.text")
                                            .font(.headline)
                                            .foregroundColor(ThemeManager.shared.accentColor(for: .note))
                                        
                                        Spacer()
                                    }
                                    .padding(.horizontal)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 12) {
                                            ForEach(filteredNotes) { note in
                                                TagCloudNoteItemView(note: note) {
                                                    selectedNote = note
                                                }
                                                .transition(.scale)
                                            }
                                        }
                                        .padding(.horizontal)
                                        .animation(.spring(), value: filteredNotes.count)
                                    }
                                }
                                .padding(.vertical, 8)
                                .background(Color.gray.opacity(0.05))
                                .cornerRadius(12)
                                .padding(.horizontal)
                            }
                            
                            if filteredCharacters.isEmpty && filteredScenes.isEmpty && filteredNotes.isEmpty {
                                VStack(spacing: 20) {
                                    Spacer()
                                    
                                    ZStack {
                                        Circle()
                                            .fill(Color.gray.opacity(0.1))
                                            .frame(width: 120, height: 120)
                                        
                                        Image(systemName: "magnifyingglass")
                                            .font(.system(size: 50))
                                            .foregroundColor(.gray.opacity(0.6))
                                    }
                                    
                                    Text("没有找到相关内容")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                    
                                    Text("尝试选择其他标签")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary.opacity(0.8))
                                    
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity, minHeight: 300)
                                .padding(.top, 20)
                            }
                        }
                        .padding(.vertical)
                    }
                    else {
                        VStack(spacing: 20) {
                            Spacer()
                            
                            ZStack {
                                Circle()
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(width: 120, height: 120)
                                
                                Image(systemName: "hand.tap")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray.opacity(0.6))
                            }
                            
                            Text("请选择一个标签查看相关内容")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text("点击上方的标签以查看相关的角色、场景和笔记")
                                .font(.subheadline)
                                .foregroundColor(.secondary.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 20)
                    }
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

// 根据标签生成颜色
func tagColor(for tag: String) -> Color {
    let colors: [Color] = [
        .blue, .purple, .green, .orange, .pink, .teal, .indigo, .cyan
    ]
    
    // 使用标签字符串的哈希值来确定颜色
    let hash = abs(tag.hashValue)
    return colors[hash % colors.count]
}

// 统计卡片组件
struct StatCard: View {
    let title: String
    let count: Int
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                Text(title)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(color)
            
            Text("\(count)")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(count > 0 ? color : .secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

// 标签按钮组件
struct TagButton: View {
    let tag: String
    let isSelected: Bool
    let onTap: () -> Void
    @State private var scale: CGFloat = 1.0
    
    // 根据标签长度生成不同的颜色
    private var tagColor: Color {
        let colors: [Color] = [
            .blue, .purple, .green, .orange, .pink, .teal, .indigo, .cyan
        ]
        
        // 使用标签字符串的哈希值来确定颜色
        let hash = abs(tag.hashValue)
        return colors[hash % colors.count]
    }
    
    // 根据标签长度调整字体大小
    private var fontSize: CGFloat {
        let length = tag.count
        if length <= 2 {
            return 16
        } else if length <= 4 {
            return 14
        } else {
            return 12
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: fontSize - 2))
                        .foregroundColor(tagColor)
                }
                
                Text(tag)
                    .lineLimit(1)
                    .font(.system(size: fontSize, weight: isSelected ? .semibold : .regular))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                isSelected ?
                tagColor.opacity(0.15) :
                ThemeManager.shared.secondaryBackgroundColor
            )
            .foregroundColor(
                isSelected ?
                tagColor :
                ThemeManager.shared.primaryTextColor
            )
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        isSelected ?
                        tagColor :
                        Color.gray.opacity(0.3),
                        lineWidth: isSelected ? 1.5 : 1
                    )
            )
            .shadow(color: isSelected ? tagColor.opacity(0.3) : Color.clear, radius: 3, x: 0, y: 1)
            .scaleEffect(scale)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: scale)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { isHovered in
            scale = isHovered ? 1.05 : 1.0
        }
        .onTapGesture {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                scale = 0.95
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                        scale = 1.0
                    }
                }
            }
            onTap()
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
