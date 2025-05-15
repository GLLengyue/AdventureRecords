//
//  ContentView.swift
//  AdventureRecords
//
//  Created by Lengyue's Macbook on 2025/5/10.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    // ViewModel 初始化 (如果它们是 StateObjects，通常在这里或App结构中创建)
    @StateObject var characterViewModel = CharacterViewModel() // 或者您的初始化方式
    @StateObject var noteViewModel = NoteViewModel()             // 或者您的初始化方式
    @StateObject var sceneViewModel = SceneViewModel()             // 或者您的初始化方式

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
            } else { // 假设 selectedTab == 3 是设置
                // TODO: 实现设置视图
                // SettingsView()
            }
            
            ModuleTabBar(selectedTab: $selectedTab)
        }
        // 将 ViewModels 注入到环境中，所有子视图都可以访问
        .environmentObject(characterViewModel)
        .environmentObject(noteViewModel)
        .environmentObject(sceneViewModel)
    }
}