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
    private let characterViewModel = CharacterViewModel.shared
    private let sceneViewModel = SceneViewModel.shared
    private let noteViewModel = NoteViewModel.shared
    private let audioViewModel = AudioViewModel.shared
    
    // 主题管理器
    private let themeManager = ThemeManager.shared
    
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
        }
    }
}
