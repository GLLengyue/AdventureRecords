//
//  AdventureRecordsApp.swift
//  AdventureRecords
//
//  Created by Lengyue's Macbook on 2025/5/10.
//

import SwiftUI

@main
struct AdventureRecordsApp: App {
    let persistenceController = CoreDataManager.shared
    @StateObject private var characterViewModel = CharacterViewModel()
    @StateObject private var sceneViewModel = SceneViewModel()
    @StateObject private var noteViewModel = NoteViewModel()
    @StateObject private var audioViewModel = AudioViewModel()
    
    // 初始化主题管理器
    @StateObject private var themeManager = ThemeManager.shared
    
    init() {
        // 检查并初始化示例数据
        SampleDataGenerator.checkAndInitializeIfNeeded()
        
        // 打印组件库信息
        ComponentLibrary.printInfo()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.viewContext)
                .environmentObject(characterViewModel)
                .environmentObject(sceneViewModel)
                .environmentObject(noteViewModel)
                .environmentObject(audioViewModel)
        }
    }
}
