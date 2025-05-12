//
//  ContentView.swift
//  AdventureRecords
//
//  Created by Lengyue's Macbook on 2025/5/10.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // 根据选中的标签显示不同的内容
            if selectedTab == 0 {
                ListContainer(module: .character, title: "角色卡", addAction: {}) {
                    CharacterView()
                }
            } else if selectedTab == 1 {
                ListContainer(module: .note, title: "笔记块", addAction: {}) {
                    NoteBlockView()
                }
            } else if selectedTab == 2 {
                ListContainer(module: .scene, title: "场景", addAction: {}) {
                    SceneView()
                }
            } else {
                ImmersiveModeView(content: "沉浸模式示例内容")
            }
            
            // 使用自定义底部标签栏
            ModuleTabBar(selectedTab: $selectedTab)
        }
    }
}

#Preview {
    ContentView()
}
