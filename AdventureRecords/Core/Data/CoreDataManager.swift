import CoreData
import Foundation
import SwiftUI
import UIKit
import UniformTypeIdentifiers

// MARK: - 数据模型

/// 清理类型枚举
enum CleanupType {
    case all
    case character
    case scene
    case note
    case none
}

/// 导出类型枚举
enum ExportType {
    case pdf
    case text
    case json
    case none

    var description: String {
        switch self {
        case .pdf:
            return "PDF文档 (.pdf)"
        case .text:
            return "纯文本文件 (.txt)"
        case .json:
            return "JSON文件 (.json)"
        case .none:
            return ""
        }
    }

    var iconName: String {
        switch self {
        case .pdf:
            return "doc.richtext"
        case .text:
            return "doc.text"
        case .json:
            return "curlybraces"
        case .none:
            return ""
        }
    }

    var color: Color {
        switch self {
        case .pdf:
            return .red
        case .text:
            return .gray
        case .json:
            return .blue
        case .none:
            return .gray
        }
    }

    var utType: UTType {
        switch self {
        case .pdf:
            return .pdf
        case .text:
            return .plainText
        case .json:
            return .json
        case .none:
            return .data
        }
    }
}

/// 导出文档结构
struct ExportDocument {
    let data: Data
    let filename: String
    let contentType: UTType
}

/// 备份文件
struct BackupFile: Identifiable, Equatable {
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
    let audioRecordings: [AudioRecordingData]
    let settings: [String: String]
}

/// 角色数据
struct CharacterData: Codable {
    let id: String
    let name: String
    let description: String
    let avatar: Data?
    let tags: [String]
    let relatedNoteIDs: [String]
    let relatedAudioRecordingIDs: [String]
}

/// 场景数据
struct SceneData: Codable {
    let id: String
    let name: String
    let description: String
    let tags: [String]
    let relatedNoteIDs: [String]
    let coverImage: Data?
}

/// 笔记数据
struct NoteData: Codable {
    let id: String
    let title: String
    let content: String
    let tags: [String]
    let relatedCharacterIDs: [String]
    let relatedSceneIDs: [String]
}

/// 音频录音数据
struct AudioRecordingData: Codable {
    let id: String
    let title: String
    let fileName: String
    let date: Date
    let audioData: Data
}

// MARK: - 数据管理器

class CoreDataManager {
    static let shared = CoreDataManager()

    private var persistentContainer: NSPersistentContainer!

    private init() {
        setupPersistentContainer()
        setupBackupDirectory()
    }

    private func setupPersistentContainer() {
        let container = NSPersistentContainer(name: "AdventureRecords")

        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("无法加载 Core Data 存储: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        persistentContainer = container
    }

    func manualSync() {
        saveContext()
    }

    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    // MARK: - 保存上下文

    func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                debugPrint("保存 Core Data 上下文失败: \(error)")
            }
        }
    }

    // MARK: - 角色卡操作

    func createCharacter(name: String, description: String, avatar: Data? = nil) -> Character {
        let entity = CharacterEntity(context: viewContext)
        entity.id = UUID()
        entity.name = name
        entity.characterDescription = description
        entity.avatar = avatar
        entity.tags = []
        entity.relatedNoteIDs = []

        saveContext()

        return Character(id: entity.id ?? UUID(),
                         name: entity.name ?? "",
                         description: entity.characterDescription ?? "",
                         avatar: entity.avatar != nil ? UIImage(data: entity.avatar!) : nil,
                         audioRecordings: nil,
                         tags: [],
                         relatedNoteIDs: [])
    }

    func fetchCharacters() -> [Character] {
        let request: NSFetchRequest<CharacterEntity> = CharacterEntity.fetchRequest()
        do {
            let entities = try viewContext.fetch(request)
            return entities.map { entity in
                Character(id: entity.id ?? UUID(),
                          name: entity.name ?? "",
                          description: entity.characterDescription ?? "",
                          avatar: entity.avatar != nil ? UIImage(data: entity.avatar!) : nil,
                          audioRecordings: fetchAudioRecordings(for: entity.audioIDs ?? []),
                          tags: entity.tags ?? [],
                          relatedNoteIDs: entity.relatedNoteIDs ?? [])
            }
        } catch {
            debugPrint("获取角色数据失败: \(error)")
            return []
        }
    }

    func fetchAudioRecordings(for audioIDs: [UUID]) -> [AudioRecording] {
        guard !audioIDs.isEmpty else { return [] }
        let request: NSFetchRequest<AudioRecordingEntity> = AudioRecordingEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id IN %@", audioIDs)
        do {
            let entities = try viewContext.fetch(request)
            return entities.map { entity in
                let storedURL = entity.recordingURL ?? URL(fileURLWithPath: "unknown.m4a")
                let audioURL = getAbsoluteAudioURL(from: storedURL)

                return AudioRecording(id: entity.id ?? UUID(),
                                      title: entity.title ?? "",
                                      recordingURL: audioURL,
                                      date: entity.date ?? Date())
            }
        } catch {
            debugPrint("获取录音数据失败: \(error)")
            return []
        }
    }

    func fetchCharacters(for characterIDs: [UUID]) -> [Character] {
        let request: NSFetchRequest<CharacterEntity> = CharacterEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id IN %@", characterIDs)
        do {
            let entities = try viewContext.fetch(request)
            return entities.map { entity in
                Character(id: entity.id ?? UUID(),
                          name: entity.name ?? "",
                          description: entity.characterDescription ?? "",
                          avatar: entity.avatar != nil ? UIImage(data: entity.avatar!) : nil,
                          audioRecordings: fetchAudioRecordings(for: entity.audioIDs ?? []),
                          tags: entity.tags ?? [],
                          relatedNoteIDs: entity.relatedNoteIDs ?? [])
            }
        } catch {
            debugPrint("获取角色数据失败: \(error)")
            return []
        }
    }

    func fetchCharacterEntity(by id: UUID) -> CharacterEntity? {
        let request: NSFetchRequest<CharacterEntity> = CharacterEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        do {
            let entities = try viewContext.fetch(request)
            return entities.first
        } catch {
            debugPrint("获取角色失败: \(error)")
            return nil
        }
    }

    func updateCharacter(_ character: Character) {
        if let entity = fetchCharacterEntity(by: character.id) {
            entity.name = character.name
            entity.characterDescription = character.description
            entity.avatar = character.avatar?.pngData()
            entity.tags = character.tags
            entity.relatedNoteIDs = character.relatedNoteIDs
            saveContext()
        } else {
            debugPrint("角色未找到，无法更新")
        }
    }

    // MARK: - 数据管理功能

    // MARK: - 备份与恢复

    /// 获取备份目录
    private var backupDirectory: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("Backups", isDirectory: true)
    }

    /// 创建备份目录
    private func setupBackupDirectory() {
        let fileManager = FileManager.default

        do {
            // 如果备份目录不存在，则创建
            if !fileManager.fileExists(atPath: backupDirectory.path) {
                try fileManager.createDirectory(at: backupDirectory, withIntermediateDirectories: true, attributes: nil)
            }
        } catch {
            debugPrint("创建备份目录失败: \(error.localizedDescription)")
        }
    }

    /// 创建备份
    func createBackup(name: String, date: Date) -> Data? {
        do {
            // 生成备份数据
            let backupData = try createBackupData()

            // 生成文件名
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
            let dateString = dateFormatter.string(from: date)
            let fileName = "\(name)_\(dateString).adrbackup"

            // 创建备份文件
            let backupURL = backupDirectory.appendingPathComponent(fileName)
            try backupData.write(to: backupURL)

            debugPrint("备份成功: \(backupURL.path)")

            return backupData
        } catch {
            debugPrint("创建备份失败: \(error.localizedDescription)")
            return nil
        }
    }

    /// 从备份恢复
    func restoreFromBackup(_ backupFile: BackupFile) -> Bool {
        do {
            // 读取备份文件
            let backupData = try Data(contentsOf: backupFile.url)
            debugPrint("备份数据: \(backupData)")
            // 恢复数据
            try restoreFromBackupData(backupData)

            debugPrint("恢复成功: \(backupFile.name)")
            return true
        } catch {
            debugPrint("恢复失败: \(error.localizedDescription)")
            return false
        }
    }

    /// 获取所有备份
    func getAllBackups() -> [BackupFile] {
        let fileManager = FileManager.default

        do {
            // 获取备份目录中的所有文件
            let fileURLs = try fileManager.contentsOfDirectory(at: backupDirectory,
                                                               includingPropertiesForKeys: [.creationDateKey],
                                                               options: .skipsHiddenFiles)

            // 过滤备份文件
            let backupFiles = fileURLs.filter { $0.pathExtension == "adrbackup" }

            // 创建备份文件对象
            return backupFiles.compactMap { url in
                let name = url.deletingPathExtension().lastPathComponent
                let attributes = try? fileManager.attributesOfItem(atPath: url.path)
                let creationDate = attributes?[.creationDate] as? Date ?? Date()

                return BackupFile(url: url, name: name, creationDate: creationDate)
            }.sorted { $0.creationDate > $1.creationDate } // 按创建时间降序排序
        } catch {
            debugPrint("获取备份列表失败: \(error.localizedDescription)")
            return []
        }
    }

    // MARK: - 数据导出

    /// 导出数据
    func exportData(type: ExportType, includeCharacters: Bool, includeScenes: Bool,
                    includeNotes: Bool) -> ExportDocument?
    {
        do {
            var exportData: Data
            var fileName: String

            switch type {
            case .pdf:
                exportData = try generatePDFData(includeCharacters: includeCharacters, includeScenes: includeScenes,
                                                 includeNotes: includeNotes)
                fileName = "冒险记录_\(getCurrentDateString()).pdf"
            case .text:
                exportData = try generateTextData(includeCharacters: includeCharacters, includeScenes: includeScenes,
                                                  includeNotes: includeNotes)
                fileName = "冒险记录_\(getCurrentDateString()).txt"
            case .json:
                exportData = try generateJSONData(includeCharacters: includeCharacters, includeScenes: includeScenes,
                                                  includeNotes: includeNotes)
                fileName = "冒险记录_\(getCurrentDateString()).json"
            case .none:
                return nil
            }

            return ExportDocument(data: exportData, filename: fileName, contentType: type.utType)
        } catch {
            debugPrint("导出数据失败: \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: - 数据清理

    /// 清理数据
    func cleanupData(type: CleanupType) -> Bool {
        do {
            switch type {
            case .all:
                // 清理所有数据
                try cleanupAllData(context: viewContext)
            case .character:
                // 清理角色数据
                try cleanupCharacterData(context: viewContext)
            case .scene:
                // 清理场景数据
                try cleanupSceneData(context: viewContext)
            case .note:
                // 清理笔记数据
                try cleanupNoteData(context: viewContext)
            case .none:
                return false
            }

            // 保存更改
            saveContext()
            return true
        } catch {
            debugPrint("清理数据失败: \(error.localizedDescription)")
            return false
        }
    }

    /// 创建备份数据
    private func createBackupData() throws -> Data {
        // 从数据库获取真实数据
        let characters = fetchCharacters()
        let scenes = fetchScenes()
        let notes = fetchNotes()
        let audioRecordings = fetchAudioRecordings()
        
        // 准备音频录音数据
        var audioRecordingData: [AudioRecordingData] = []
        for recording in audioRecordings {
            do {
                let audioData = try Data(contentsOf: recording.recordingURL)
                let audioRecording = AudioRecordingData(
                    id: recording.id.uuidString,
                    title: recording.title,
                    fileName: recording.fileName,
                    date: recording.date,
                    audioData: audioData
                )
                audioRecordingData.append(audioRecording)
            } catch {
                debugPrint("读取音频文件失败: \(error.localizedDescription)")
                continue
            }
        }

        // 创建备份数据结构
        let backup = BackupData(version: "1.1.0",  // 更新版本号以反映数据格式变化
                                timestamp: Date(),
                                characters: characters.map { character in
                                    // 获取角色关联的笔记ID和音频录音ID
                                    let noteIDs = character.relatedNoteIDs.map { $0.uuidString }
                                    let audioRecordingIDs = character.audioRecordings?.map { $0.id.uuidString } ?? []
                                    return CharacterData(id: character.id.uuidString,
                                                         name: character.name,
                                                         description: character.description,
                                                         avatar: character.avatar?.jpegData(compressionQuality: 0.8),
                                                         tags: character.tags,
                                                         relatedNoteIDs: noteIDs,
                                                         relatedAudioRecordingIDs: audioRecordingIDs)
                                },
                                scenes: scenes.map { scene in
                                    // 获取场景关联的笔记ID
                                    let noteIDs = scene.relatedNoteIDs.map { $0.uuidString }
                                    return SceneData(id: scene.id.uuidString,
                                                     name: scene.title,
                                                     description: scene.description,
                                                     tags: scene.tags,
                                                     relatedNoteIDs: noteIDs,
                                                     coverImage: scene.coverImage?.jpegData(compressionQuality: 0.8))
                                },
                                notes: notes.map { note in
                                    // 获取笔记关联的场景ID
                                    let sceneIDs = note.relatedSceneIDs.map { $0.uuidString }
                                    let characterIDs = note.relatedCharacterIDs.map { $0.uuidString }
                                    return NoteData(id: note.id.uuidString,
                                                    title: note.title,
                                                    content: note.content,
                                                    tags: note.tags,
                                                    relatedCharacterIDs: characterIDs,
                                                    relatedSceneIDs: sceneIDs)
                                },
                                audioRecordings: audioRecordingData,
                                settings: fetchSettings())

        // 编码为JSON数据
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(backup)
    }

    private func restoreFromBackupData(_ data: Data) throws {
        // 解码备份数据
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            let backup = try decoder.decode(BackupData.self, from: data)

            // 检查版本兼容性
            if !isBackupVersionCompatible(backup.version) {
                throw NSError(domain: "CoreDataManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "备份版本不兼容"])
            }
            
            // 确保音频目录存在
            let audioDirectory = getAudioDirectory()
            debugPrint("音频目录: \(audioDirectory.path)")
            if !FileManager.default.fileExists(atPath: audioDirectory.path) {
                try FileManager.default.createDirectory(at: audioDirectory, withIntermediateDirectories: true)
            }

            // 创建临时上下文进行恢复操作
            let tempContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            tempContext.persistentStoreCoordinator = viewContext.persistentStoreCoordinator

            // 开始恢复过程
            try tempContext.performAndWait {
                // 清理现有数据
                try cleanupAllData(context: tempContext)

                // 恢复设置
                for (key, value) in backup.settings {
                    UserDefaults.standard.set(value, forKey: key)
                }
                
                // 恢复音频录音数据
                for audioData in backup.audioRecordings {
                    let audioURL = audioDirectory.appendingPathComponent(audioData.fileName)
                    
                    // 保存音频文件
                    try audioData.audioData.write(to: audioURL)
                    
                    // 创建录音记录
                    let entity = AudioRecordingEntity(context: tempContext)
                    entity.id = UUID(uuidString: audioData.id) ?? UUID()
                    entity.title = audioData.title
                    // 保存相对路径而不是绝对路径
                    entity.recordingURL = getRelativeAudioURL(from: audioURL)
                    entity.date = audioData.date
                }

                // 恢复数据
                try restoreCharacters(backup.characters, context: tempContext)
                try restoreScenes(backup.scenes, context: tempContext)
                try restoreNotes(backup.notes, context: tempContext)

                if tempContext.hasChanges {
                    try tempContext.save()
                }
            }


            // 在主上下文上保存最终更改
            viewContext.performAndWait {
                if viewContext.hasChanges {
                    try? viewContext.save()
                }
            }
        } catch let error as NSError {
            debugPrint("恢复失败: \(error), \(error.userInfo)")
            throw error
        }
    }

    /// 检查备份版本兼容性
    private func isBackupVersionCompatible(_ version: String) -> Bool {
        // 支持 1.0.0 和 1.1.0 版本的备份
        let compatibleVersions = ["1.0.0", "1.1.0"]
        return compatibleVersions.contains(version)
    }

    /// 生成PDF数据
    private func generatePDFData(includeCharacters: Bool, includeScenes: Bool, includeNotes: Bool) throws -> Data {
        // 这里需要实现PDF生成逻辑
        // 简单示例：返回一个包含文本的PDF
        let pdfData = Data("冒险记录PDF导出".utf8)
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
                textContent += "场景: \(scene.title)\n"
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
            "timestamp": ISO8601DateFormatter().string(from: Date()),
        ]

        if includeCharacters {
            exportData["characters"] = fetchCharacters().map { character in
                return [
                    "id": character.id.uuidString,
                    "name": character.name,
                    "description": character.description,
                ]
            }
        }

        if includeScenes {
            exportData["scenes"] = fetchScenes().map { scene in
                return [
                    "id": scene.id.uuidString,
                    "title": scene.title,
                    "description": scene.description,
                ]
            }
        }

        if includeNotes {
            exportData["notes"] = fetchNotes().map { note in
                return [
                    "id": note.id.uuidString,
                    "title": note.title,
                    "content": note.content,
                ]
            }
        }

        // 编码为JSON
        let jsonData = try JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted)
        return jsonData
    }

    /// 获取当前日期字符串
    private func getCurrentDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        return dateFormatter.string(from: Date())
    }

    /// 清理所有数据
    private func cleanupAllData(context: NSManagedObjectContext) throws {
        try cleanupCharacterData(context: context)
        try cleanupSceneData(context: context)
        try cleanupNoteData(context: context)
        try cleanupAudioData(context: context)
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

    /// 清理音频数据
    private func cleanupAudioData(context: NSManagedObjectContext) throws {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "AudioRecordingEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try context.execute(deleteRequest)
    }

    /// 获取设置数据
    private func fetchSettings() -> [String: String] {
        // 从用户默认值获取设置数据
        let userDefaults = UserDefaults.standard
        var settings: [String: String] = [:]

        // 获取常用设置
        if let theme = userDefaults.string(forKey: "theme") {
            settings["theme"] = theme
        }

        if let language = userDefaults.string(forKey: "language") {
            settings["language"] = language
        }

        return settings
    }

    /// 恢复角色数据
    private func restoreCharacters(_ characters: [CharacterData], context: NSManagedObjectContext) throws {
        for characterData in characters {
            let entity = CharacterEntity(context: context)
            entity.id = UUID(uuidString: characterData.id) ?? UUID()
            entity.name = characterData.name.isEmpty ? "未命名角色" : characterData.name
            entity.characterDescription = characterData.description
            entity.avatar = characterData.avatar
            entity.tags = characterData.tags
            entity.relatedNoteIDs = characterData.relatedNoteIDs.compactMap { UUID(uuidString: $0) }
            entity.audioIDs = characterData.relatedAudioRecordingIDs.compactMap { UUID(uuidString: $0) }
        }
    }
    
    /// 恢复场景数据
    private func restoreScenes(_ scenes: [SceneData], context: NSManagedObjectContext) throws {
        for sceneData in scenes {
            let entity = SceneEntity(context: context)
            entity.id = UUID(uuidString: sceneData.id) ?? UUID()
            entity.title = sceneData.name.isEmpty ? "未命名场景" : sceneData.name
            entity.sceneDescription = sceneData.description
            entity.tags = sceneData.tags
            entity.relatedNoteIDs = sceneData.relatedNoteIDs.compactMap { UUID(uuidString: $0) }
            entity.coverImage = sceneData.coverImage
        }
    }
    
    /// 恢复笔记数据
    private func restoreNotes(_ notes: [NoteData], context: NSManagedObjectContext) throws {
        for noteData in notes {
            let entity = NoteEntity(context: context)
            entity.id = UUID(uuidString: noteData.id) ?? UUID()
            entity.title = noteData.title.isEmpty ? "未命名笔记" : noteData.title
            entity.content = noteData.content
            entity.tags = noteData.tags
            entity.relatedCharacterIDs = noteData.relatedCharacterIDs.compactMap { UUID(uuidString: $0) }
            entity.relatedSceneIDs = noteData.relatedSceneIDs.compactMap { UUID(uuidString: $0) }
            // 设置必填的 date 字段，使用当前时间
            entity.date = Date()
        }
    }

    // MARK: - 音频文件管理
    
    /// 获取音频文件存储目录
    private func getAudioDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let audioDirectory = documentsDirectory.appendingPathComponent("AudioRecordings")
        return audioDirectory
    }
    
    func getAudioURL(for fileName: String) -> URL {
        return getAudioDirectory().appendingPathComponent(fileName)
    }

    // 以下是原有的CoreDataManager方法，已移至上面的类定义中
    /*
     // MARK: - 笔记操作
     */
    func createNote(title: String, content: String) -> NoteBlock {
        let entity = NoteEntity(context: viewContext)
        entity.id = UUID()
        entity.title = title
        entity.content = content
        entity.date = Date()
        entity.relatedCharacterIDs = []
        entity.relatedSceneIDs = []
        entity.tags = []

        saveContext()

        return NoteBlock(id: entity.id ?? UUID(),
                         title: entity.title ?? "",
                         content: entity.content ?? "",
                         relatedCharacterIDs: [],
                         relatedSceneIDs: [],
                         date: entity.date ?? Date(),
                         tags: [])
    }

    func fetchNotes() -> [NoteBlock] {
        let request: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
        do {
            let entities = try viewContext.fetch(request)
            return entities.map { entity in
                NoteBlock(id: entity.id ?? UUID(),
                          title: entity.title ?? "",
                          content: entity.content ?? "",
                          relatedCharacterIDs: entity.relatedCharacterIDs ?? [],
                          relatedSceneIDs: entity.relatedSceneIDs ?? [],
                          date: entity.date ?? Date(),
                          tags: entity.tags ?? [])
            }
        } catch {
            debugPrint("获取笔记数据失败: \(error)")
            return []
        }
    }

    func fetchNotes(for noteIDs: [UUID]) -> [NoteBlock] {
        let request: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id IN %@", noteIDs)
        do {
            let entities = try viewContext.fetch(request)
            return entities.map { entity in
                NoteBlock(id: entity.id ?? UUID(),
                          title: entity.title ?? "",
                          content: entity.content ?? "",
                          relatedCharacterIDs: entity.relatedCharacterIDs ?? [],
                          relatedSceneIDs: entity.relatedSceneIDs ?? [],
                          date: entity.date ?? Date(),
                          tags: entity.tags ?? [])
            }
        } catch {
            debugPrint("获取笔记数据失败: \(error)")
            return []
        }
    }

    func fetchNoteEntity(by id: UUID) -> NoteEntity? {
        let request: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        do {
            let entities = try viewContext.fetch(request)
            return entities.first
        } catch {
            debugPrint("获取笔记失败: \(error)")
            return nil
        }
    }

    func updateNote(_ note: NoteBlock) {
        if let entity = fetchNoteEntity(by: note.id) {
            entity.title = note.title
            entity.content = note.content
            entity.date = note.date
            entity.relatedCharacterIDs = note.relatedCharacterIDs
            entity.relatedSceneIDs = note.relatedSceneIDs
            entity.tags = note.tags
            saveContext()
        } else {
            debugPrint("笔记未找到，无法更新")
        }
    }

    func fetchSceneEntity(by id: UUID) -> SceneEntity? {
        let request: NSFetchRequest<SceneEntity> = SceneEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        do {
            let entities = try viewContext.fetch(request)
            return entities.first
        } catch {
            debugPrint("获取场景失败: \(error)")
            return nil
        }
    }

    func updateScene(_ scene: AdventureScene) {
        if let entity = fetchSceneEntity(by: scene.id) {
            entity.title = scene.title
            entity.sceneDescription = scene.description
            entity.relatedNoteIDs = scene.relatedNoteIDs
            entity.coverImage = scene.coverImage?.pngData()
            entity.atmosphereData = try? JSONEncoder().encode(scene.atmosphere)
            entity.tags = scene.tags
            saveContext()
        } else {
            debugPrint("场景未找到，无法更新")
        }
    }

    // MARK: - 场景操作

    func createScene(title: String, description: String) -> AdventureScene {
        let entity = SceneEntity(context: viewContext)
        entity.id = UUID()
        entity.title = title
        entity.sceneDescription = description
        entity.relatedNoteIDs = []
        entity.tags = []
        entity.atmosphereData = try? JSONEncoder().encode(SceneAtmosphere.default)

        saveContext()

        return AdventureScene(id: entity.id ?? UUID(),
                              title: entity.title ?? "",
                              description: entity.sceneDescription ?? "",
                              relatedNoteIDs: [],
                              coverImage: nil,
                              audioURL: nil,
                              atmosphere: .default,
                              tags: [])
    }

    func fetchScenes() -> [AdventureScene] {
        let request: NSFetchRequest<SceneEntity> = SceneEntity.fetchRequest()
        do {
            let entities = try viewContext.fetch(request)
            return entities.map { entity in
                var atmosphere: SceneAtmosphere = .default
                if let data = entity.atmosphereData {
                    atmosphere = (try? JSONDecoder().decode(SceneAtmosphere.self, from: data)) ?? .default
                }

                return AdventureScene(id: entity.id ?? UUID(),
                                      title: entity.title ?? "",
                                      description: entity.sceneDescription ?? "",
                                      relatedNoteIDs: entity.relatedNoteIDs ?? [],
                                      coverImage: entity.coverImage != nil ? UIImage(data: entity.coverImage!) : nil,
                                      audioURL: nil,
                                      atmosphere: atmosphere,
                                      tags: entity.tags ?? [])
            }
        } catch {
            debugPrint("获取场景数据失败: \(error)")
            return []
        }
    }

    func fetchScenes(for sceneIDs: [UUID]) -> [AdventureScene] {
        let request: NSFetchRequest<SceneEntity> = SceneEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id IN %@", sceneIDs)
        do {
            let entities = try viewContext.fetch(request)
            return entities.map { entity in
                var atmosphere: SceneAtmosphere = .default
                if let data = entity.atmosphereData {
                    atmosphere = (try? JSONDecoder().decode(SceneAtmosphere.self, from: data)) ?? .default
                }

                return AdventureScene(id: entity.id ?? UUID(),
                                      title: entity.title ?? "",
                                      description: entity.sceneDescription ?? "",
                                      relatedNoteIDs: entity.relatedNoteIDs ?? [],
                                      coverImage: entity.coverImage != nil ? UIImage(data: entity.coverImage!) : nil,
                                      audioURL: nil,
                                      atmosphere: atmosphere,
                                      tags: entity.tags ?? [])
            }
        } catch {
            debugPrint("获取场景数据失败: \(error)")
            return []
        }
    }

    // MARK: - Character 相关方法

    func saveCharacter(_ character: Character) {
        let entity = CharacterEntity(context: viewContext)
        entity.id = character.id
        entity.name = character.name
        entity.characterDescription = character.description
        entity.avatar = character.avatar?.pngData()
        entity.tags = character.tags
        entity.relatedNoteIDs = character.relatedNoteIDs
        saveContext()
    }

    // MARK: - Scene 相关方法

    func saveScene(_ scene: AdventureScene) {
        let entity = SceneEntity(context: viewContext)
        entity.id = scene.id
        entity.title = scene.title
        entity.sceneDescription = scene.description
        entity.relatedNoteIDs = scene.relatedNoteIDs
        entity.coverImage = scene.coverImage?.pngData()
        entity.atmosphereData = try? JSONEncoder().encode(scene.atmosphere)
        saveContext()
    }

    // MARK: - Note 相关方法

    func saveNote(_ note: NoteBlock) {
        let entity = NoteEntity(context: viewContext)
        entity.id = note.id
        entity.title = note.title
        entity.content = note.content
        entity.date = note.date
        entity.relatedCharacterIDs = note.relatedCharacterIDs
        entity.relatedSceneIDs = note.relatedSceneIDs
        saveContext()
    }

    // MARK: - Audio 相关方法

    func fetchAudioRecordingEntity(by id: UUID) -> AudioRecordingEntity? {
        let request: NSFetchRequest<AudioRecordingEntity> = AudioRecordingEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        do {
            return try viewContext.fetch(request).first
        } catch {
            debugPrint("获取 AudioRecordingEntity 失败: \(error)")
            return nil
        }
    }

    func saveAudioRecording(_ recording: AudioRecording, forCharacterID characterID: UUID? = nil) {
        let entity = AudioRecordingEntity(context: viewContext)
        entity.id = recording.id
        entity.title = recording.title
        entity.recordingURL = getRelativeAudioURL(from: recording.recordingURL)
        entity.date = recording.date

        if let charID = characterID, let characterEntity = fetchCharacterEntity(by: charID) {
            var ids = characterEntity.audioIDs ?? []
            if !ids.contains(recording.id) {
                ids.append(recording.id)
                characterEntity.audioIDs = ids
            }
        }

        saveContext()
    }

    func fetchAudioRecordings() -> [AudioRecording] {
        let request: NSFetchRequest<AudioRecordingEntity> = AudioRecordingEntity.fetchRequest()
        do {
            let entities = try viewContext.fetch(request)
            return entities.map { entity in
                let storedURL = entity.recordingURL ?? URL(fileURLWithPath: "unknown.m4a")
                let audioURL = getAbsoluteAudioURL(from: storedURL)

                return AudioRecording(id: entity.id ?? UUID(),
                                      title: entity.title ?? "",
                                      recordingURL: audioURL,
                                      date: entity.date ?? Date())
            }
        } catch {
            debugPrint("获取录音数据失败: \(error)")
            return []
        }
    }

    // MARK: - 删除方法

    func deleteCharacter(_ id: UUID) {
        let request: NSFetchRequest<CharacterEntity> = CharacterEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        deleteEntities(request)
    }

    func deleteScene(_ id: UUID) {
        let request: NSFetchRequest<SceneEntity> = SceneEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        deleteEntities(request)
    }

    func deleteNote(_ id: UUID) {
        let request: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        deleteEntities(request)
    }

    func deleteAudioRecording(_ id: UUID) {
        let request: NSFetchRequest<AudioRecordingEntity> = AudioRecordingEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        deleteEntities(request)
    }

    func updateAudioRecording(_ recording: AudioRecording) {
        if let entity = fetchAudioRecordingEntity(by: recording.id) {
            entity.title = recording.title
            entity.recordingURL = getRelativeAudioURL(from: recording.recordingURL)
            entity.date = recording.date
            saveContext()
        } else {
            debugPrint("录音未找到，无法更新")
        }
    }

    private func deleteEntities<T: NSManagedObject>(_ request: NSFetchRequest<T>) {
        do {
            let entities = try viewContext.fetch(request)
            entities.forEach { viewContext.delete($0) }
            saveContext()
        } catch {
            debugPrint("删除实体失败: \(error)")
        }
    }

    // 辅助方法：获取相对音频URL（只保留文件名）
    private func getRelativeAudioURL(from url: URL) -> URL {
        if url.pathComponents.count <= 2 {
            return url
        }
        return URL(fileURLWithPath: url.lastPathComponent)
    }

    // 辅助方法：从相对URL获取绝对URL
    private func getAbsoluteAudioURL(from url: URL) -> URL {
        // 如果是绝对路径且文件存在，直接返回
        if url.path.starts(with: "/") {
            if FileManager.default.fileExists(atPath: url.path) {
                return url
            } else {
                // 绝对路径但文件不存在，尝试从文件名构建新路径
                print("警告: 绝对路径文件不存在，尝试重新定位: \(url.path)")
            }
        }

        // 获取当前应用的AudioRecordings目录
        let audioDirectoryName = "AudioRecordings"
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioDirectory = documentsPath.appendingPathComponent(audioDirectoryName)

        // 确保目录存在
        if !FileManager.default.fileExists(atPath: audioDirectory.path) {
            do {
                try FileManager.default.createDirectory(at: audioDirectory, withIntermediateDirectories: true)
                print("创建音频目录: \(audioDirectory.path)")
            } catch {
                debugPrint("创建音频目录失败: \(error)")
            }
        }

        // 使用文件名构建新的绝对路径
        let newURL = audioDirectory.appendingPathComponent(url.lastPathComponent)
        
        // 如果新路径的文件不存在，记录警告
        if !FileManager.default.fileExists(atPath: newURL.path) {
            print("警告: 录音文件不存在: \(newURL.path)")
        }
        
        return newURL
    }
}
