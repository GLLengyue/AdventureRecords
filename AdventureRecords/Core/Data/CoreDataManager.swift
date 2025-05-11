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
    func createCharacterCard(name: String, description: String, avatar: Data? = nil) -> CharacterCard {
        let entity = CharacterCardEntity(context: viewContext)
        entity.id = UUID()
        entity.name = name
        entity.characterDescription = description
        entity.avatar = avatar
        entity.tags = []
        entity.noteIDs = []
        entity.sceneIDs = []
        
        saveContext()
        
        return CharacterCard(
            id: entity.id ?? UUID(),
            name: entity.name ?? "",
            description: entity.characterDescription ?? "",
            avatar: entity.avatar != nil ? UIImage(data: entity.avatar!) : nil,
            audioRecordings: nil,
            tags: [],
            noteIDs: [],
            sceneIDs: []
        )
    }
    
    func fetchCharacters() -> [CharacterCard] {
        let request: NSFetchRequest<CharacterCardEntity> = CharacterCardEntity.fetchRequest()
        do {
            let entities = try viewContext.fetch(request)
            return entities.map { entity in
                CharacterCard(
                    id: entity.id ?? UUID(),
                    name: entity.name ?? "",
                    description: entity.characterDescription ?? "",
                    avatar: entity.avatar != nil ? UIImage(data: entity.avatar!) : nil,
                    audioRecordings: nil,
                    tags: entity.tags as? [String] ?? [],
                    noteIDs: entity.noteIDs as? [UUID] ?? [],
                    sceneIDs: entity.sceneIDs as? [UUID] ?? []
                )
            }
        } catch {
            print("获取角色数据失败: \(error)")
            return []
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
        
        saveContext()
        
        return NoteBlock(
            id: entity.id ?? UUID(),
            title: entity.title ?? "",
            content: entity.content ?? "",
            relatedCharacterIDs: [],
            relatedSceneIDs: [],
            date: entity.date ?? Date()
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
                    relatedCharacterIDs: entity.relatedCharacterIDs as? [UUID] ?? [],
                    relatedSceneIDs: entity.relatedSceneIDs as? [UUID] ?? [],
                    date: entity.date ?? Date()
                )
            }
        } catch {
            print("获取笔记数据失败: \(error)")
            return []
        }
    }
    
    // MARK: - 场景操作
    func createScene(title: String, description: String) -> AdventureScene {
        let entity = SceneEntity(context: viewContext)
        entity.id = UUID()
        entity.title = title
        entity.sceneDescription = description
        entity.relatedCharacterIDs = []
        entity.relatedNoteIDs = []
        
        saveContext()
        
        return AdventureScene(
            id: entity.id ?? UUID(),
            title: entity.title ?? "",
            description: entity.sceneDescription ?? "",
            relatedCharacterIDs: [],
            relatedNoteIDs: []
        )
    }
    
    func fetchScenes() -> [AdventureScene] {
        let request: NSFetchRequest<SceneEntity> = SceneEntity.fetchRequest()
        do {
            let entities = try viewContext.fetch(request)
            return entities.map { entity in
                AdventureScene(
                    id: entity.id ?? UUID(),
                    title: entity.title ?? "",
                    description: entity.sceneDescription ?? "",
                    relatedCharacterIDs: entity.relatedCharacterIDs as? [UUID] ?? [],
                    relatedNoteIDs: entity.relatedNoteIDs as? [UUID] ?? []
                )
            }
        } catch {
            print("获取场景数据失败: \(error)")
            return []
        }
    }
    
    // MARK: - 关系操作
    func addCharacterToNote(characterId: UUID, noteId: UUID) {
        let characterRequest: NSFetchRequest<CharacterCardEntity> = CharacterCardEntity.fetchRequest()
        characterRequest.predicate = NSPredicate(format: "id == %@", characterId as CVarArg)
        
        let noteRequest: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
        noteRequest.predicate = NSPredicate(format: "id == %@", noteId as CVarArg)
        
        do {
            let characters = try viewContext.fetch(characterRequest)
            let notes = try viewContext.fetch(noteRequest)
            
            if let character = characters.first, let note = notes.first {
                var characterNoteIDs = character.noteIDs as? [UUID] ?? []
                var noteCharacterIDs = note.relatedCharacterIDs as? [UUID] ?? []
                
                if !characterNoteIDs.contains(noteId) {
                    characterNoteIDs.append(noteId)
                    character.noteIDs = characterNoteIDs
                }
                
                if !noteCharacterIDs.contains(characterId) {
                    noteCharacterIDs.append(characterId)
                    note.relatedCharacterIDs = noteCharacterIDs
                }
                
                saveContext()
            }
        } catch {
            print("添加角色到笔记失败: \(error)")
        }
    }
    
    func addCharacterToScene(characterId: UUID, sceneId: UUID) {
        let characterRequest: NSFetchRequest<CharacterCardEntity> = CharacterCardEntity.fetchRequest()
        characterRequest.predicate = NSPredicate(format: "id == %@", characterId as CVarArg)
        
        let sceneRequest: NSFetchRequest<SceneEntity> = SceneEntity.fetchRequest()
        sceneRequest.predicate = NSPredicate(format: "id == %@", sceneId as CVarArg)
        
        do {
            let characters = try viewContext.fetch(characterRequest)
            let scenes = try viewContext.fetch(sceneRequest)
            
            if let character = characters.first, let scene = scenes.first {
                var characterSceneIDs = character.sceneIDs as? [UUID] ?? []
                var sceneCharacterIDs = scene.relatedCharacterIDs as? [UUID] ?? []
                
                if !characterSceneIDs.contains(sceneId) {
                    characterSceneIDs.append(sceneId)
                    character.sceneIDs = characterSceneIDs
                }
                
                if !sceneCharacterIDs.contains(characterId) {
                    sceneCharacterIDs.append(characterId)
                    scene.relatedCharacterIDs = sceneCharacterIDs
                }
                
                saveContext()
            }
        } catch {
            print("添加角色到场景失败: \(error)")
        }
    }
    
    func addNoteToScene(noteId: UUID, sceneId: UUID) {
        let noteRequest: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
        noteRequest.predicate = NSPredicate(format: "id == %@", noteId as CVarArg)
        
        let sceneRequest: NSFetchRequest<SceneEntity> = SceneEntity.fetchRequest()
        sceneRequest.predicate = NSPredicate(format: "id == %@", sceneId as CVarArg)
        
        do {
            let notes = try viewContext.fetch(noteRequest)
            let scenes = try viewContext.fetch(sceneRequest)
            
            if let note = notes.first, let scene = scenes.first {
                var noteSceneIDs = note.relatedSceneIDs as? [UUID] ?? []
                var sceneNoteIDs = scene.relatedNoteIDs as? [UUID] ?? []
                
                if !noteSceneIDs.contains(sceneId) {
                    noteSceneIDs.append(sceneId)
                    note.relatedSceneIDs = noteSceneIDs
                }
                
                if !sceneNoteIDs.contains(noteId) {
                    sceneNoteIDs.append(noteId)
                    scene.relatedNoteIDs = sceneNoteIDs
                }
                
                saveContext()
            }
        } catch {
            print("添加笔记到场景失败: \(error)")
        }
    }
    
    // MARK: - Character 相关方法
    func saveCharacter(_ character: CharacterCard) {
        let entity = CharacterCardEntity(context: viewContext)
        entity.id = character.id
        entity.name = character.name
        entity.characterDescription = character.description
        entity.avatar = character.avatar?.pngData()
        entity.tags = character.tags
        entity.noteIDs = character.noteIDs
        entity.sceneIDs = character.sceneIDs
        saveContext()
    }
    
    // MARK: - Scene 相关方法
    func saveScene(_ scene: AdventureScene) {
        let entity = SceneEntity(context: viewContext)
        entity.id = scene.id
        entity.title = scene.title
        entity.sceneDescription = scene.description
        entity.relatedCharacterIDs = scene.relatedCharacterIDs
        entity.relatedNoteIDs = scene.relatedNoteIDs
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
    func saveAudioRecording(_ recording: AudioRecording) {
        let entity = AudioRecordingEntity(context: viewContext)
        entity.id = recording.id
        entity.title = recording.title
        entity.recordingURL = recording.recordingURL
        entity.date = recording.date
        saveContext()
    }
    
    func fetchAudioRecordings() -> [AudioRecording] {
        let request: NSFetchRequest<AudioRecordingEntity> = AudioRecordingEntity.fetchRequest()
        do {
            let entities = try viewContext.fetch(request)
            return entities.map { entity in
                AudioRecording(
                    id: entity.id ?? UUID(),
                    title: entity.title ?? "",
                    recordingURL: entity.recordingURL ?? URL(fileURLWithPath: ""),
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
        let request: NSFetchRequest<CharacterCardEntity> = CharacterCardEntity.fetchRequest()
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
    
    private func deleteEntities<T: NSManagedObject>(_ request: NSFetchRequest<T>) {
        do {
            let entities = try viewContext.fetch(request)
            entities.forEach { viewContext.delete($0) }
            saveContext()
        } catch {
            print("删除实体失败: \(error)")
        }
    }
} 