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
        TabView(selection: $selectedTab) {
            CharacterCardView()
                .tabItem {
                    Label("角色卡", systemImage: "person.3")
                }.tag(0)
            NoteBlockView()
                .tabItem {
                    Label("笔记块", systemImage: "note.text")
                }.tag(1)
            SceneView()
                .tabItem {
                    Label("场景", systemImage: "map")
                }.tag(2)
            ImmersiveModeView(content: "沉浸模式示例内容")
                .tabItem {
                    Label("沉浸模式", systemImage: "eye")
                }.tag(3)
        }
    }
}

#Preview {
    ContentView()
}
