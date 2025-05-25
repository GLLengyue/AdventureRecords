//
//  LayoutComponents.swift
//  AdventureRecords
//
//  Created by Trae AI on 2025/5/15.
//

import SwiftUI

/// 底部标签栏组件
public struct ModuleTabBar: View {
    @Binding var selectedTab: Int
    
    public var body: some View {
        HStack(spacing: 0) {
            TabButton(
                title: "角色",
                icon: "person.3",
                module: .character,
                isSelected: selectedTab == 0
            ) {
                selectedTab = 0
            }
            
            TabButton(
                title: "笔记",
                icon: "note.text",
                module: .note,
                isSelected: selectedTab == 1
            ) {
                selectedTab = 1
            }
            
            TabButton(
                title: "场景",
                icon: "map",
                module: .scene,
                isSelected: selectedTab == 2
            ) {
                selectedTab = 2
            }
            
            TabButton(
                title: "标签云",
                icon: "tag",
                module: .note, // 使用笔记模块的颜色
                isSelected: selectedTab == 3
            ) {
                selectedTab = 3
            }
            
            TabButton(
                title: "更多",
                icon: "ellipsis",
                module: .character, // 使用角色模块的颜色
                isSelected: selectedTab == 4
            ) {
                selectedTab = 4
            }
        }
        .padding(.vertical, 8)
        .background(
            Rectangle()
                .fill(ThemeManager.shared.secondaryBackgroundColor)
                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: -2)
        )
    }
}

/// 顶部导航栏组件
public struct ModuleNavigationBar<TrailingContent: View>: View {
    let title: String
    let module: ModuleType
    var backAction: (() -> Void)? = nil
    let trailingContent: TrailingContent
    
    init(title: String, module: ModuleType, backAction: (() -> Void)? = nil, @ViewBuilder trailingContent: () -> TrailingContent = { EmptyView() }) {
        self.title = title
        self.module = module
        self.backAction = backAction
        self.trailingContent = trailingContent()
    }
    
    public var body: some View {
        HStack {
            if let backAction = backAction {
                Button(action: backAction) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(ThemeManager.shared.accentColor(for: module))
                }
                .padding(.trailing, 8)
            }
            
            Text(title)
                .font(.headline)
                .foregroundColor(ThemeManager.shared.primaryTextColor)
            
            Spacer()
            
            trailingContent
        }
        .padding()
        .background(
            Rectangle()
                .fill(ThemeManager.shared.backgroundColor)
                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
        )
    }
}

/// 列表布局容器
public struct ListContainer<Content: View, TrailingContent: View>: View {
    let module: ModuleType
    let title: String
    let content: Content
    var addAction: (() -> Void)? = nil
    let trailingContent: TrailingContent
    @Binding var searchText: String
    var onSearch: ((String) -> Void)?
    @FocusState private var isSearchFieldFocused: Bool
    @State private var showSearchField = false

    init(
        module: ModuleType,
        title: String,
        searchText: Binding<String>,
        onSearch: ((String) -> Void)? = nil,
        addAction: (() -> Void)? = nil,
        @ViewBuilder trailingContent: () -> TrailingContent = { EmptyView() },
        @ViewBuilder content: () -> Content
    ) {
        self.module = module
        self.title = title
        self._searchText = searchText
        self.onSearch = onSearch
        self.addAction = addAction
        self.trailingContent = trailingContent()
        self.content = content()
        self.isSearchFieldFocused = false
    }

    public var body: some View {
        VStack(spacing: 0) {
            ModuleNavigationBar(title: title, module: module) {
                HStack(spacing: 8) {
                    trailingContent                    
                    if showSearchField {
                        TextField("请输入关键词", text: $searchText, onCommit: {dismissSearch()})
                            .padding(10)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .focused($isSearchFieldFocused)
                            .transition(.move(edge: .top).combined(with: .opacity)) // 动画效果
                    }

                    Button(action: {
                        withAnimation {
                            showSearchField = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            withAnimation {
                                isSearchFieldFocused = true
                            }
                        }
                    }) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(ThemeManager.shared.accentColor(for: module))
                    }
                    .onChange(of: isSearchFieldFocused) {
                        if isSearchFieldFocused {
                            withAnimation {
                                showSearchField = true
                            }
                        } else {
                            withAnimation {
                                showSearchField = false
                            }
                        }
                    }
                    if let addAction = addAction {
                        Button(action: addAction) {
                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(ThemeManager.shared.accentColor(for: module))
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal)
        }
    }

    private func dismissSearch() {
        withAnimation {
            showSearchField = false
        }
        searchText = ""
        withAnimation {
            isSearchFieldFocused = false
        }
    }
}

/// 详情页布局容器
public struct DetailContainer<Content: View>: View {
    let module: ModuleType
    let title: String
    let content: Content
    let backAction: () -> Void
    var editAction: (() -> Void)? = nil
    
    init(module: ModuleType, title: String, backAction: @escaping () -> Void, editAction: (() -> Void)? = nil, @ViewBuilder content: () -> Content) {
        self.module = module
        self.title = title
        self.backAction = backAction
        self.editAction = editAction
        self.content = content()
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            ModuleNavigationBar(title: title, module: module) {
                if let editAction = editAction {
                    Button(action: editAction) {
                        Image(systemName: "pencil")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(ThemeManager.shared.accentColor(for: module))
                    }
                }
            }
            
            ScrollView {
                content
                    .padding()
            }
        }
    }
}

/// 编辑页布局容器
public struct EditorContainer<Content: View>: View {
    let module: ModuleType
    let title: String
    let content: Content
    let cancelAction: () -> Void
    let saveAction: () -> Void
    let saveDisabled: Bool
    
    init(module: ModuleType, title: String, cancelAction: @escaping () -> Void, saveAction: @escaping () -> Void, saveDisabled: Bool = false, @ViewBuilder content: () -> Content) {
        self.module = module
        self.title = title
        self.cancelAction = cancelAction
        self.saveAction = saveAction
        self.saveDisabled = saveDisabled
        self.content = content()
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            ModuleNavigationBar(title: title, module: module, backAction: cancelAction) {
                Button(action: saveAction) {
                    Text("保存")
                        .font(.headline)
                        .foregroundColor(ThemeManager.shared.accentColor(for: module))
                }
                .disabled(saveDisabled)

            }
            
            content
                .padding()
        }
    }
}


// 流式布局
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        let containerWidth = proposal.width ?? .infinity
        var height: CGFloat = 0
        var currentX: CGFloat = 0
        var currentRowHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if currentX + size.width > containerWidth && currentX > 0 {
                // 开始新的一行
                height += currentRowHeight + spacing
                currentX = 0
                currentRowHeight = size.height
            } else {
                currentRowHeight = max(currentRowHeight, size.height)
            }
            
            currentX += size.width + spacing
        }
        
        height += currentRowHeight
        
        return CGSize(width: containerWidth, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        var currentX: CGFloat = bounds.minX
        var currentY: CGFloat = bounds.minY
        var rowHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if currentX + size.width > bounds.maxX && currentX > bounds.minX {
                // 开始新的一行
                currentX = bounds.minX
                currentY += rowHeight + spacing
                rowHeight = 0
            }
            
            subview.place(
                at: CGPoint(x: currentX, y: currentY),
                proposal: ProposedViewSize(size)
            )
            
            currentX += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
