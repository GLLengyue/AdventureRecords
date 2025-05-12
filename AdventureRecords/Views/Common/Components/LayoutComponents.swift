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
                title: "角色卡",
                icon: "person.3",
                module: .character,
                isSelected: selectedTab == 0
            ) {
                selectedTab = 0
            }
            
            TabButton(
                title: "笔记块",
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
                title: "沉浸模式",
                icon: "eye",
                module: .character, // 使用角色模块的颜色
                isSelected: selectedTab == 3
            ) {
                selectedTab = 3
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
public struct ListContainer<Content: View>: View {
    let module: ModuleType
    let title: String
    let content: Content
    var addAction: (() -> Void)? = nil
    
    init(module: ModuleType, title: String, addAction: (() -> Void)? = nil, @ViewBuilder content: () -> Content) {
        self.module = module
        self.title = title
        self.addAction = addAction
        self.content = content()
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            ModuleNavigationBar(title: title, module: module) {
                if let addAction = addAction {
                    Button(action: addAction) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(ThemeManager.shared.accentColor(for: module))
                    }
                }
            }
            
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
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
            ModuleNavigationBar(title: title, module: module, backAction: backAction) {
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
    
    init(module: ModuleType, title: String, cancelAction: @escaping () -> Void, saveAction: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.module = module
        self.title = title
        self.cancelAction = cancelAction
        self.saveAction = saveAction
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
            }
            
            ScrollView {
                content
                    .padding()
            }
        }
    }
}

/// 预览
struct LayoutComponents_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State private var selectedTab = 0
        
        var body: some View {
            VStack(spacing: 0) {
                if selectedTab == 0 {
                    ListContainer(module: .character, title: "角色卡", addAction: {}) {
                        Text("角色卡列表内容")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.gray.opacity(0.1))
                    }
                } else if selectedTab == 1 {
                    ListContainer(module: .note, title: "笔记块", addAction: {}) {
                        Text("笔记块列表内容")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.gray.opacity(0.1))
                    }
                } else if selectedTab == 2 {
                    ListContainer(module: .scene, title: "场景", addAction: {}) {
                        Text("场景列表内容")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.gray.opacity(0.1))
                    }
                } else {
                    DetailContainer(module: .character, title: "沉浸模式", backAction: {}) {
                        Text("沉浸模式内容")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.gray.opacity(0.1))
                    }
                }
                
                ModuleTabBar(selectedTab: $selectedTab)
            }
        }
    }
    
    static var previews: some View {
        PreviewWrapper()
    }
}