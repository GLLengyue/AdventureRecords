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
        entity.noteIDs = []
        entity.sceneIDs = []
        
        saveContext()
        
        return Character(
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
                    audioRecordings: fetchAudioRecordings(for: entity.audioIDs as? [UUID] ?? []),
                    tags: entity.tags ?? [],
                    noteIDs: entity.noteIDs ?? [],
                    sceneIDs: entity.sceneIDs ?? []
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
                    audioRecordings: fetchAudioRecordings(for: entity.audioIDs as? [UUID] ?? []),
                    tags: entity.tags ?? [],
                    noteIDs: entity.noteIDs ?? [],
                    sceneIDs: entity.sceneIDs ?? []
                )
            }
        } catch {
            print("获取角色数据失败: \(error)")
            return []
        }
    }
    func fetchCharacter(by id: UUID) -> CharacterEntity? {
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
        if let entity = fetchCharacter(by: character.id) {
            entity.name = character.name
            entity.characterDescription = character.description
            entity.avatar = character.avatar?.pngData()
            entity.tags = character.tags
            entity.noteIDs = character.noteIDs
            entity.sceneIDs = character.sceneIDs
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
                    relatedCharacterIDs: entity.relatedCharacterIDs ?? [],
                    relatedSceneIDs: entity.relatedSceneIDs ?? [],
                    date: entity.date ?? Date()
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
                    date: entity.date ?? Date()
                )
            }
        } catch {
            print("获取笔记数据失败: \(error)")
            return []
        }
    }
    
    func fetchNote(by id: UUID) -> NoteEntity? {
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
        if let entity = fetchNote(by: note.id) {
            entity.title = note.title
            entity.content = note.content
            entity.date = note.date
            entity.relatedCharacterIDs = note.relatedCharacterIDs
            entity.relatedSceneIDs = note.relatedSceneIDs
            saveContext()
        } else {
            print("笔记未找到，无法更新")
        }
    }

    func fetchScene(by id: UUID) -> SceneEntity? {
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
        if let entity = fetchScene(by: scene.id) {
            entity.title = scene.title
            entity.sceneDescription = scene.description
            entity.relatedCharacterIDs = scene.relatedCharacterIDs
            entity.relatedNoteIDs = scene.relatedNoteIDs
            entity.coverImage = scene.coverImage?.pngData()
            entity.atmosphereData = try? JSONEncoder().encode(scene.atmosphere)
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
        entity.relatedCharacterIDs = []
        entity.relatedNoteIDs = []
        entity.atmosphereData = try? JSONEncoder().encode(SceneAtmosphere.default)
        
        saveContext()
        
        return AdventureScene(
            id: entity.id ?? UUID(),
            title: entity.title ?? "",
            description: entity.sceneDescription ?? "",
            relatedCharacterIDs: [],
            relatedNoteIDs: [],
            coverImage: nil,
            audioURL: nil,
            atmosphere: .default
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
                    relatedCharacterIDs: entity.relatedCharacterIDs ?? [],
                    relatedNoteIDs: entity.relatedNoteIDs ?? [],
                    coverImage: entity.coverImage != nil ? UIImage(data: entity.coverImage!) : nil,
                    audioURL: nil,
                    atmosphere: entity.atmosphere
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
                AdventureScene(
                    id: entity.id ?? UUID(),
                    title: entity.title ?? "",
                    description: entity.sceneDescription ?? "",
                    relatedCharacterIDs: entity.relatedCharacterIDs ?? [],
                    relatedNoteIDs: entity.relatedNoteIDs ?? [],
                    coverImage: entity.coverImage != nil ? UIImage(data: entity.coverImage!) : nil,
                    audioURL: nil,
                    atmosphere: entity.atmosphere
                )
            }
        } catch {
            print("获取场景数据失败: \(error)")
            return []
        }
    }

    func fetchCharacterStruct(id: UUID) -> Character? {
        guard let entity = fetchCharacter(by: id) else { return nil }
        return Character(
            id: entity.id ?? UUID(),
            name: entity.name ?? "",
            description: entity.characterDescription ?? "",
            avatar: entity.avatar != nil ? UIImage(data: entity.avatar!) : nil,
            audioRecordings: fetchAudioRecordings(for: entity.audioIDs as? [UUID] ?? []),
            tags: entity.tags ?? [],
            noteIDs: entity.noteIDs ?? [],
            sceneIDs: entity.sceneIDs ?? []
        )
    }

    private func mapAudioEntitiesToStructs(audioEntities: Set<AudioRecordingEntity>?) -> [AudioRecording] {
        guard let entities = audioEntities else { return [] }
        return entities.map { audioEntity in
            AudioRecording(
                id: audioEntity.id ?? UUID(),
                title: audioEntity.title ?? "",
                recordingURL: audioEntity.recordingURL ?? URL(fileURLWithPath: ""),
                date: audioEntity.date ?? Date()
            )
        }
    }
    
    // MARK: - 关系操作
    func addCharacterToNote(characterId: UUID, noteId: UUID) {
        let characterRequest: NSFetchRequest<CharacterEntity> = CharacterEntity.fetchRequest()
        characterRequest.predicate = NSPredicate(format: "id == %@", characterId as CVarArg)
        
        let noteRequest: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
        noteRequest.predicate = NSPredicate(format: "id == %@", noteId as CVarArg)
        
        do {
            let characters = try viewContext.fetch(characterRequest)
            let notes = try viewContext.fetch(noteRequest)
            
            if let character = characters.first, let note = notes.first {
                var characterNoteIDs = character.noteIDs ?? []
                var noteCharacterIDs = note.relatedCharacterIDs ?? []
                
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
        let characterRequest: NSFetchRequest<CharacterEntity> = CharacterEntity.fetchRequest()
        characterRequest.predicate = NSPredicate(format: "id == %@", characterId as CVarArg)
        
        let sceneRequest: NSFetchRequest<SceneEntity> = SceneEntity.fetchRequest()
        sceneRequest.predicate = NSPredicate(format: "id == %@", sceneId as CVarArg)
        
        do {
            let characters = try viewContext.fetch(characterRequest)
            let scenes = try viewContext.fetch(sceneRequest)
            
            if let character = characters.first, let scene = scenes.first {
                var characterSceneIDs = character.sceneIDs ?? []
                var sceneCharacterIDs = scene.relatedCharacterIDs ?? []
                
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
                var noteSceneIDs = note.relatedSceneIDs ?? []
                var sceneNoteIDs = scene.relatedNoteIDs ?? []
                
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
    func saveCharacter(_ character: Character) {
        let entity = CharacterEntity(context: viewContext)
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
        entity.recordingURL = recording.recordingURL
        entity.date = recording.date

        if let charID = characterID, let characterEntity = fetchCharacter(by: charID) {
            var ids = characterEntity.audioIDs as? [UUID] ?? []
            if !ids.contains(recording.id) {
                ids.append(recording.id)
                characterEntity.audioIDs = ids as NSArray
            }
        }
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
        // 先解除所有角色的audioIDs关联
        let request: NSFetchRequest<CharacterEntity> = CharacterEntity.fetchRequest()
        if let characters = try? viewContext.fetch(request) {
            for character in characters {
                var ids = character.audioIDs as? [UUID] ?? []
                if let idx = ids.firstIndex(of: id) {
                    ids.remove(at: idx)
                    character.audioIDs = ids as NSArray
                }
            }
        }
        // 再删除录音实体
        if let audioEntity = fetchAudioRecordingEntity(by: id) {
            viewContext.delete(audioEntity)
        }
        saveContext()
    }

    func updateAudioRecording(_ recording: AudioRecording) {
        if let entity = fetchAudioRecordingEntity(by: recording.id) {
            entity.title = recording.title
            entity.recordingURL = recording.recordingURL
            entity.date = recording.date
            saveContext()
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
}
