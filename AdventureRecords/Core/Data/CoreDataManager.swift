import CoreData
import Foundation
import UIKit

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "AdventureRecords")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("无法加载 Core Data 存储: \(error)")
            }
        }
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    // MARK: - 保存上下文
    func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                print("保存 Core Data 上下文失败: \(error)")
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
        
        return Character(
            id: entity.id ?? UUID(),
            name: entity.name ?? "",
            description: entity.characterDescription ?? "",
            avatar: entity.avatar != nil ? UIImage(data: entity.avatar!) : nil,
            audioRecordings: nil,
            tags: [],
            relatedNoteIDs: []
        )
    }
    
    func fetchCharacters() -> [Character] {
        let request: NSFetchRequest<CharacterEntity> = CharacterEntity.fetchRequest()
        do {
            let entities = try viewContext.fetch(request)
            return entities.map { entity in
                Character(
                    id: entity.id ?? UUID(),
                    name: entity.name ?? "",
                    description: entity.characterDescription ?? "",
                    avatar: entity.avatar != nil ? UIImage(data: entity.avatar!) : nil,
                    audioRecordings: fetchAudioRecordings(for: entity.audioIDs ?? []),
                    tags: entity.tags ?? [],
                    relatedNoteIDs: entity.relatedNoteIDs ?? []
                )
            }
        } catch {
            print("获取角色数据失败: \(error)")
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
                let storedURL = entity.recordingURL ?? URL(fileURLWithPath: "")
                let audioURL = getAbsoluteAudioURL(from: storedURL)
                
                return AudioRecording(
                    id: entity.id ?? UUID(),
                    title: entity.title ?? "",
                    recordingURL: audioURL,
                    date: entity.date ?? Date()
                )
            }
        } catch {
            print("获取录音数据失败: \(error)")
            return []
        }
    }

    func fetchCharacters(for characterIDs: [UUID]) -> [Character] {
        let request: NSFetchRequest<CharacterEntity> = CharacterEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id IN %@", characterIDs)
        do {
            let entities = try viewContext.fetch(request)
            return entities.map { entity in
                Character(
                    id: entity.id ?? UUID(),
                    name: entity.name ?? "",
                    description: entity.characterDescription ?? "",
                    avatar: entity.avatar != nil ? UIImage(data: entity.avatar!) : nil,
                    audioRecordings: fetchAudioRecordings(for: entity.audioIDs ?? []),
                    tags: entity.tags ?? [],
                    relatedNoteIDs: entity.relatedNoteIDs ?? []
            )
            }
        } catch {
            print("获取角色数据失败: \(error)")
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
            print("获取角色失败: \(error)")
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
            print("角色未找到，无法更新")
        }
    }
    
    // MARK: - 笔记操作
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
        
        return NoteBlock(
            id: entity.id ?? UUID(),
            title: entity.title ?? "",
            content: entity.content ?? "",
            relatedCharacterIDs: [],
            relatedSceneIDs: [],
            date: entity.date ?? Date(),
            tags: []
        )
    }

    func fetchNotes() -> [NoteBlock] {
        let request: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
        do {
            let entities = try viewContext.fetch(request)
            return entities.map { entity in
                NoteBlock(
                    id: entity.id ?? UUID(),
                    title: entity.title ?? "",
                    content: entity.content ?? "",
                    relatedCharacterIDs: entity.relatedCharacterIDs ?? [],
                    relatedSceneIDs: entity.relatedSceneIDs ?? [],
                    date: entity.date ?? Date(),
                    tags: entity.tags ?? []
                )
            }
        } catch {
            print("获取笔记数据失败: \(error)")
            return []
        }

    }
    
    func fetchNotes(for noteIDs: [UUID]) -> [NoteBlock] {
        let request: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id IN %@", noteIDs)            
        do {
            let entities = try viewContext.fetch(request)
            return entities.map { entity in
                NoteBlock(
                    id: entity.id ?? UUID(),
                    title: entity.title ?? "",
                    content: entity.content ?? "",
                    relatedCharacterIDs: entity.relatedCharacterIDs ?? [],
                    relatedSceneIDs: entity.relatedSceneIDs ?? [],
                    date: entity.date ?? Date(),
                    tags: entity.tags ?? []
                )
            }
        } catch {
            print("获取笔记数据失败: \(error)")
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
            print("获取笔记失败: \(error)")
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
            print("笔记未找到，无法更新")
        }
    }

    func fetchSceneEntity(by id: UUID) -> SceneEntity? {
        let request: NSFetchRequest<SceneEntity> = SceneEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        do {
            let entities = try viewContext.fetch(request)
            return entities.first
        } catch {
            print("获取场景失败: \(error)")
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
            print("场景未找到，无法更新")
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
        
        return AdventureScene(
            id: entity.id ?? UUID(),
            title: entity.title ?? "",
            description: entity.sceneDescription ?? "",
            relatedNoteIDs: [],
            coverImage: nil,
            audioURL: nil,
            atmosphere: .default,
            tags: []
        )
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
                
                return AdventureScene(
                    id: entity.id ?? UUID(),
                    title: entity.title ?? "",
                    description: entity.sceneDescription ?? "",
                    relatedNoteIDs: entity.relatedNoteIDs ?? [],
                    coverImage: entity.coverImage != nil ? UIImage(data: entity.coverImage!) : nil,
                    audioURL: nil,
                    atmosphere: atmosphere,
                    tags: entity.tags ?? []
                )
            }
        } catch {
            print("获取场景数据失败: \(error)")
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
                
                return AdventureScene(
                    id: entity.id ?? UUID(),
                    title: entity.title ?? "",
                    description: entity.sceneDescription ?? "",
                    relatedNoteIDs: entity.relatedNoteIDs ?? [],
                    coverImage: entity.coverImage != nil ? UIImage(data: entity.coverImage!) : nil,
                    audioURL: nil,
                    atmosphere: atmosphere,
                    tags: entity.tags ?? []
                )
            }
        } catch {
            print("获取场景数据失败: \(error)")
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
            print("获取 AudioRecordingEntity 失败: \(error)")
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
                let storedURL = entity.recordingURL ?? URL(fileURLWithPath: "")
                let audioURL = getAbsoluteAudioURL(from: storedURL)
                
                return AudioRecording(
                    id: entity.id ?? UUID(),
                    title: entity.title ?? "",
                    recordingURL: audioURL,
                    date: entity.date ?? Date()
                )
            }
        } catch {
            print("获取录音数据失败: \(error)")
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
        }
        else {
            print("录音未找到，无法更新")
        }
    }

    private func deleteEntities<T: NSManagedObject>(_ request: NSFetchRequest<T>) {
        do {
            let entities = try viewContext.fetch(request)
            entities.forEach { viewContext.delete($0) }
            saveContext()
        } catch {
            print("删除实体失败: \(error)")
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
        if url.path.starts(with: "/") && FileManager.default.fileExists(atPath: url.path) {
            return url
        }
        
        let audioDirectoryName = "AudioRecordings" 
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioDirectory = documentsPath.appendingPathComponent(audioDirectoryName)
        
        if !FileManager.default.fileExists(atPath: audioDirectory.path) {
            do {
                try FileManager.default.createDirectory(at: audioDirectory, withIntermediateDirectories: true)
            } catch {
                print("创建音频目录失败: \(error)")
            }
        }
        
        return audioDirectory.appendingPathComponent(url.lastPathComponent)
    }
}