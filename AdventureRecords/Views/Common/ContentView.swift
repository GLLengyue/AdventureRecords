//
//  ContentView.swift
//  AdventureRecords
//
//  Created by Lengyue's Macbook on 2025/5/10.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    // 使用单例
    @StateObject private var audioViewModel = AudioViewModel.shared
    @StateObject private var characterViewModel = CharacterViewModel.shared
    @StateObject private var noteViewModel = NoteViewModel.shared
    @StateObject private var sceneViewModel = SceneViewModel.shared
    @StateObject private var themeManager = ThemeManager.shared
    
    // 控制各个模块编辑器 Sheet 显示的状态变量
    @State private var showingCharacterEditorSheet = false
    @State private var showingNoteEditorSheet = false
    @State private var showingSceneEditorSheet = false
    
    var body: some View {
        VStack(spacing: 0) {
            // 根据选中的标签显示不同的内容
            if selectedTab == 0 {
                CharacterListView(showingCharacterEditor: $showingCharacterEditorSheet)
            } else if selectedTab == 1 {
                NoteListView(showingNoteEditor: $showingNoteEditorSheet)
            } else if selectedTab == 2 {
                SceneListView(showingSceneEditor: $showingSceneEditorSheet)
            } else if selectedTab == 3 { // 标签云视图
                TagCloudView()
            } else { // 假设 selectedTab == 4 是设置
                // TODO: 实现设置视图
                Text("设置")
                    .font(.largeTitle)
                    .foregroundColor(themeManager.primaryTextColor)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(themeManager.backgroundColor)
            }
            
            ModuleTabBar(selectedTab: $selectedTab)
        }
        // 将 ViewModels 注入到环境中，所有子视图都可以访问
    }
}
