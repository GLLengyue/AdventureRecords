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
    
    init() {
        // 检查并初始化示例数据
        SampleDataGenerator.checkAndInitializeIfNeeded()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.viewContext)
        }
    }
}
