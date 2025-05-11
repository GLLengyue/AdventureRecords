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
    
    init() {
        // 检查并初始化示例数据
        SampleDataGenerator.checkAndInitializeIfNeeded()
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
