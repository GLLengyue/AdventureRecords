import Foundation
import SwiftUI
import UniformTypeIdentifiers
import CoreData
import UIKit

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    private let fileManager = FileManager.default
    private let backupDirectoryName = "Backups"
    private let backupFileExtension = "adrbackup"
    
    // MARK: - 初始化
    
    private init() {
        createBackupDirectoryIfNeeded()
    }
    
    // MARK: - 备份功能
    
    /// 创建应用数据的备份
    /// - Parameters:
    ///   - name: 备份名称
    ///   - date: 备份日期
    /// - Returns: 成功返回true，失败返回false
    func createBackup(name: String, date: Date) -> Bool {
        do {
            // 获取应用文档目录
            let documentsDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            
            // 创建备份文件名
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
            let dateString = dateFormatter.string(from: date)
            let backupFileName = "\(name)_\(dateString).\(backupFileExtension)"
            
            // 备份目录路径
            let backupDirectory = documentsDirectory.appendingPathComponent(backupDirectoryName)
            let backupFilePath = backupDirectory.appendingPathComponent(backupFileName)
            
            // 获取需要备份的数据
            let backupData = try createBackupData()
            
            // 写入备份文件
            try backupData.write(to: backupFilePath)
            
            print("备份成功: \(backupFilePath.path)")
            return true
        } catch {
            print("备份失败: \(error.localizedDescription)")
            return false
        }
    }
    
    /// 从备份文件恢复数据
    /// - Parameter backupFile: 备份文件URL
    /// - Returns: 成功返回true，失败返回false
    func restoreFromBackup(backupFile: URL) -> Bool {
        do {
            // 读取备份文件
            let backupData = try Data(contentsOf: backupFile)
            
            // 解析备份数据
            try restoreFromBackupData(backupData)
            
            print("恢复成功")
            return true
        } catch {
            print("恢复失败: \(error.localizedDescription)")
            return false
        }
    }
    
    /// 获取所有备份文件
    /// - Returns: 备份文件列表
    func getAllBackups() -> [BackupFile] {
        do {
            // 获取应用文档目录
            let documentsDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            
            // 备份目录路径
            let backupDirectory = documentsDirectory.appendingPathComponent(backupDirectoryName)
            
            // 获取所有备份文件
            let backupFiles = try fileManager.contentsOfDirectory(at: backupDirectory, includingPropertiesForKeys: [.creationDateKey], options: [.skipsHiddenFiles])
            
            // 过滤出备份文件
            let validBackups = backupFiles.filter { $0.pathExtension == backupFileExtension }
            
            // 转换为BackupFile对象
            return validBackups.compactMap { url in
                let attributes = try? fileManager.attributesOfItem(atPath: url.path)
                let creationDate = attributes?[.creationDate] as? Date ?? Date()
                let fileName = url.deletingPathExtension().lastPathComponent
                
                // 解析文件名，格式为: 名称_日期时间
                let components = fileName.split(separator: "_")
                let name = components.count > 0 ? String(components[0]) : fileName
                
                return BackupFile(url: url, name: name, creationDate: creationDate)
            }.sorted { $0.creationDate > $1.creationDate } // 按创建日期降序排序
        } catch {
            print("获取备份文件失败: \(error.localizedDescription)")
            return []
        }
    }
    
    // MARK: - 导出功能
    
    /// 导出数据为指定格式
    /// - Parameters:
    ///   - type: 导出类型
    ///   - includeCharacters: 是否包含角色数据
    ///   - includeScenes: 是否包含场景数据
    ///   - includeNotes: 是否包含笔记数据
    /// - Returns: 导出文档
    func exportData(type: ExportType, includeCharacters: Bool, includeScenes: Bool, includeNotes: Bool) -> ExportDocument? {
        do {
            // 根据不同的导出类型生成不同的数据
            let exportData: Data
            let fileName: String
            
            switch type {
            case .pdf:
                exportData = try generatePDFData(includeCharacters: includeCharacters, includeScenes: includeScenes, includeNotes: includeNotes)
                fileName = "冒险记录_\(getCurrentDateString()).pdf"
            case .text:
                exportData = try generateTextData(includeCharacters: includeCharacters, includeScenes: includeScenes, includeNotes: includeNotes)
                fileName = "冒险记录_\(getCurrentDateString()).txt"
            case .json:
                exportData = try generateJSONData(includeCharacters: includeCharacters, includeScenes: includeScenes, includeNotes: includeNotes)
                fileName = "冒险记录_\(getCurrentDateString()).json"
            }
            
            return ExportDocument(data: exportData, filename: fileName, contentType: type.utType)
        } catch {
            print("导出数据失败: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - 数据清理功能
    
    /// 清理数据
    /// - Parameter type: 清理类型
    /// - Returns: 成功返回true，失败返回false
    func cleanupData(type: CleanupType) -> Bool {
        // 创建一个新的NSPersistentContainer实例
        let container = NSPersistentContainer(name: "AdventureRecords")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                print("加载持久化存储失败: \(error), \(error.userInfo)")
                return
            }
        }
        
        let context = container.viewContext
        
        do {
            switch type {
            case .all:
                // 清理所有数据
                try cleanupAllData(context: context)
            case .character:
                // 清理角色数据
                try cleanupCharacterData(context: context)
            case .scene:
                // 清理场景数据
                try cleanupSceneData(context: context)
            case .note:
                // 清理笔记数据
                try cleanupNoteData(context: context)
            }
            
            // 保存更改
            try context.save()
            
            return true
        } catch {
            print("清理数据失败: \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - 私有辅助方法
    
    /// 创建备份目录（如果不存在）
    private func createBackupDirectoryIfNeeded() {
        do {
            // 获取应用文档目录
            let documentsDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            
            // 备份目录路径
            let backupDirectory = documentsDirectory.appendingPathComponent(backupDirectoryName)
            
            // 如果备份目录不存在，则创建
            if !fileManager.fileExists(atPath: backupDirectory.path) {
                try fileManager.createDirectory(at: backupDirectory, withIntermediateDirectories: true, attributes: nil)
            }
        } catch {
            print("创建备份目录失败: \(error.localizedDescription)")
        }
    }
    
    /// 创建备份数据
    private func createBackupData() throws -> Data {
        // 创建一个新的NSPersistentContainer实例
        let container = NSPersistentContainer(name: "AdventureRecords")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                print("加载持久化存储失败: \(error), \(error.userInfo)")
                return
            }
        }
        
        // 创建备份数据结构
        let backup = BackupData(
            version: "1.0.0",
            timestamp: Date(),
            characters: fetchCharacters(),
            scenes: fetchScenes(),
            notes: fetchNotes(),
            settings: fetchSettings()
        )
        
        // 编码为JSON数据
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(backup)
    }
    
    /// 从备份数据恢复
    private func restoreFromBackupData(_ data: Data) throws {
        // 解码备份数据
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let backup = try decoder.decode(BackupData.self, from: data)
        
        // 检查版本兼容性
        if !isBackupVersionCompatible(backup.version) {
            throw NSError(domain: "DataManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "备份版本不兼容"])
        }
        
        // 创建一个新的NSPersistentContainer实例
        let container = NSPersistentContainer(name: "AdventureRecords")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                print("加载持久化存储失败: \(error), \(error.userInfo)")
                return
            }
        }
        
        let context = container.viewContext
        
        // 清理现有数据
        try cleanupAllData(context: context)
        
        // 恢复数据
        // 注意：这里需要根据实际的数据模型实现具体的恢复逻辑
        
        // 保存更改
        try context.save()
    }
    
    /// 检查备份版本兼容性
    private func isBackupVersionCompatible(_ version: String) -> Bool {
        // 实现版本兼容性检查逻辑
        // 简单示例：只接受1.x版本的备份
        return version.starts(with: "1.")
    }
    
    /// 生成PDF数据
    private func generatePDFData(includeCharacters: Bool, includeScenes: Bool, includeNotes: Bool) throws -> Data {
        // 这里需要实现PDF生成逻辑
        // 简单示例：返回一个包含文本的PDF
        let pdfData = Data("PDF数据导出示例".utf8)
        return pdfData
    }
    
    /// 生成文本数据
    private func generateTextData(includeCharacters: Bool, includeScenes: Bool, includeNotes: Bool) throws -> Data {
        var textContent = "冒险记录导出\n"
        textContent += "导出时间: \(getCurrentDateString())\n\n"
        
        if includeCharacters {
            textContent += "== 角色 ==\n"
            // 添加角色数据
            let characters = fetchCharacters()
            for character in characters {
                textContent += "角色: \(character.name)\n"
                textContent += "描述: \(character.description)\n\n"
            }
        }
        
        if includeScenes {
            textContent += "== 场景 ==\n"
            // 添加场景数据
            let scenes = fetchScenes()
            for scene in scenes {
                textContent += "场景: \(scene.name)\n"
                textContent += "描述: \(scene.description)\n\n"
            }
        }
        
        if includeNotes {
            textContent += "== 笔记 ==\n"
            // 添加笔记数据
            let notes = fetchNotes()
            for note in notes {
                textContent += "笔记: \(note.title)\n"
                textContent += "内容: \(note.content)\n\n"
            }
        }
        
        return Data(textContent.utf8)
    }
    
    /// 生成JSON数据
    private func generateJSONData(includeCharacters: Bool, includeScenes: Bool, includeNotes: Bool) throws -> Data {
        // 创建导出数据结构
        var exportData: [String: Any] = [
            "version": "1.0.0",
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        
        if includeCharacters {
            exportData["characters"] = fetchCharacters().map { $0.toDictionary() }
        }
        
        if includeScenes {
            exportData["scenes"] = fetchScenes().map { $0.toDictionary() }
        }
        
        if includeNotes {
            exportData["notes"] = fetchNotes().map { $0.toDictionary() }
        }
        
        // 编码为JSON
        let jsonData = try JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted)
        return jsonData
    }
    
    /// 清理所有数据
    private func cleanupAllData(context: NSManagedObjectContext) throws {
        try cleanupCharacterData(context: context)
        try cleanupSceneData(context: context)
        try cleanupNoteData(context: context)
    }
    
    /// 清理角色数据
    private func cleanupCharacterData(context: NSManagedObjectContext) throws {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "CharacterEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try context.execute(deleteRequest)
    }
    
    /// 清理场景数据
    private func cleanupSceneData(context: NSManagedObjectContext) throws {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "SceneEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try context.execute(deleteRequest)
    }
    
    /// 清理笔记数据
    private func cleanupNoteData(context: NSManagedObjectContext) throws {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "NoteEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try context.execute(deleteRequest)
    }
    
    /// 获取当前日期字符串
    private func getCurrentDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        return dateFormatter.string(from: Date())
    }
    
    // MARK: - 数据获取方法
    
    /// 获取角色数据
    private func fetchCharacters() -> [CharacterData] {
        // 这里需要实现从CoreData获取角色数据的逻辑
        // 简单示例：返回一些示例数据
        return [
            CharacterData(id: "1", name: "示例角色1", description: "这是一个示例角色"),
            CharacterData(id: "2", name: "示例角色2", description: "这是另一个示例角色")
        ]
    }
    
    /// 获取场景数据
    private func fetchScenes() -> [SceneData] {
        // 这里需要实现从CoreData获取场景数据的逻辑
        // 简单示例：返回一些示例数据
        return [
            SceneData(id: "1", name: "示例场景1", description: "这是一个示例场景"),
            SceneData(id: "2", name: "示例场景2", description: "这是另一个示例场景")
        ]
    }
    
    /// 获取笔记数据
    private func fetchNotes() -> [NoteData] {
        // 这里需要实现从CoreData获取笔记数据的逻辑
        // 简单示例：返回一些示例数据
        return [
            NoteData(id: "1", title: "示例笔记1", content: "这是一个示例笔记"),
            NoteData(id: "2", title: "示例笔记2", content: "这是另一个示例笔记")
        ]
    }
    
    /// 获取设置数据
    private func fetchSettings() -> [String: Any] {
        // 这里需要实现获取应用设置的逻辑
        // 简单示例：返回一些示例设置
        return [
            "isDarkMode": UserDefaults.standard.bool(forKey: "isDarkMode"),
            "debugMode": UserDefaults.standard.bool(forKey: "debugMode")
        ]
    }
}

// MARK: - 数据模型

/// 备份文件
struct BackupFile: Identifiable {
    let id = UUID()
    let url: URL
    let name: String
    let creationDate: Date
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: creationDate)
    }
}

/// 备份数据结构
struct BackupData: Codable {
    let version: String
    let timestamp: Date
    let characters: [CharacterData]
    let scenes: [SceneData]
    let notes: [NoteData]
    let settings: [String: Any]
    
    enum CodingKeys: String, CodingKey {
        case version, timestamp, characters, scenes, notes, settings
    }
    
    init(version: String, timestamp: Date, characters: [CharacterData], scenes: [SceneData], notes: [NoteData], settings: [String: Any]) {
        self.version = version
        self.timestamp = timestamp
        self.characters = characters
        self.scenes = scenes
        self.notes = notes
        self.settings = settings
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        version = try container.decode(String.self, forKey: .version)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        characters = try container.decode([CharacterData].self, forKey: .characters)
        scenes = try container.decode([SceneData].self, forKey: .scenes)
        notes = try container.decode([NoteData].self, forKey: .notes)
        
        // 解码设置
        if let settingsData = try? container.decode(Data.self, forKey: .settings),
           let decodedSettings = try? JSONSerialization.jsonObject(with: settingsData, options: []) as? [String: Any] {
            settings = decodedSettings
        } else {
            settings = [:]
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(version, forKey: .version)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(characters, forKey: .characters)
        try container.encode(scenes, forKey: .scenes)
        try container.encode(notes, forKey: .notes)
        
        // 编码设置
        if let settingsData = try? JSONSerialization.data(withJSONObject: settings, options: []) {
            try container.encode(settingsData, forKey: .settings)
        }
    }
}

/// 角色数据
struct CharacterData: Codable {
    let id: String
    let name: String
    let description: String
    
    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "name": name,
            "description": description
        ]
    }
}

/// 场景数据
struct SceneData: Codable {
    let id: String
    let name: String
    let description: String
    
    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "name": name,
            "description": description
        ]
    }
}

/// 笔记数据
struct NoteData: Codable {
    let id: String
    let title: String
    let content: String
    
    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "title": title,
            "content": content
        ]
    }
}
