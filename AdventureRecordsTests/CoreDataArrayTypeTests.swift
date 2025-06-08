//
//  CoreDataArrayTypeTests.swift
//  AdventureRecordsTests
//
//  Created by 冷月 on 2025/6/8.
//

import XCTest
@testable import AdventureRecords

final class CoreDataArrayTypeTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        _ = CoreDataManager.shared.cleanupData(type: .all)
    }
    
    override func tearDown() {
        _ = CoreDataManager.shared.cleanupData(type: .all)
        super.tearDown()
    }
    
    // MARK: - Character Array Tests
    
    func testCharacterTagsArrayHandling() {
        let manager = CoreDataManager.shared
        
        // 创建带有tags的角色
        let testTags = ["勇敢", "智慧", "魔法师"]
        let character = manager.createCharacter(name: "测试角色", description: "测试描述")
        
        // 更新角色添加tags
        var updatedCharacter = character
        updatedCharacter.tags = testTags
        manager.updateCharacter(updatedCharacter)
        
        // 验证tags正确保存和读取
        let fetchedCharacter = manager.fetchCharacters().first { $0.id == character.id }
        XCTAssertNotNil(fetchedCharacter)
        XCTAssertEqual(fetchedCharacter?.tags.count, testTags.count)
        XCTAssertEqual(Set(fetchedCharacter?.tags ?? []), Set(testTags))
    }
    
    func testCharacterRelatedNoteIDsArrayHandling() {
        let manager = CoreDataManager.shared
        
        // 创建角色和笔记
        let character = manager.createCharacter(name: "测试角色", description: "测试描述")
        let note1 = manager.createNote(title: "笔记1", content: "内容1")
        let note2 = manager.createNote(title: "笔记2", content: "内容2")
        
        // 更新角色关联笔记
        var updatedCharacter = character
        updatedCharacter.relatedNoteIDs = [note1.id, note2.id]
        manager.updateCharacter(updatedCharacter)
        
        // 验证关联笔记ID正确保存和读取
        let fetchedCharacter = manager.fetchCharacters().first { $0.id == character.id }
        XCTAssertNotNil(fetchedCharacter)
        XCTAssertEqual(fetchedCharacter?.relatedNoteIDs.count, 2)
        XCTAssertTrue(fetchedCharacter?.relatedNoteIDs.contains(note1.id) ?? false)
        XCTAssertTrue(fetchedCharacter?.relatedNoteIDs.contains(note2.id) ?? false)
    }
    
    func testCharacterAudioIDsArrayHandling() {
        let manager = CoreDataManager.shared
        
        // 创建角色
        let character = manager.createCharacter(name: "测试角色", description: "测试描述")
        
        // 创建音频记录
        let audioRecording = AudioRecording(
            id: UUID(),
            title: "测试音频", recordingURL: URL(fileURLWithPath: "unknown.m4a"),
            date: Date()
        )
        
        // 保存音频记录并关联到角色
        manager.saveAudioRecording(audioRecording, forCharacterID: character.id)
        
        // 验证音频ID正确关联
        let fetchedCharacter = manager.fetchCharacters().first { $0.id == character.id }
        XCTAssertNotNil(fetchedCharacter)
        XCTAssertEqual(fetchedCharacter?.audioRecordings?.count, 1)
        XCTAssertEqual(fetchedCharacter?.audioRecordings?.first?.id, audioRecording.id)
    }
    
    // MARK: - Note Array Tests
    
    func testNoteTagsArrayHandling() {
        let manager = CoreDataManager.shared
        
        // 创建带有tags的笔记
        let testTags = ["重要", "战斗", "策略"]
        let note = manager.createNote(title: "测试笔记", content: "测试内容")
        
        // 更新笔记添加tags
        var updatedNote = note
        updatedNote.tags = testTags
        manager.updateNote(updatedNote)
        
        // 验证tags正确保存和读取
        let fetchedNote = manager.fetchNotes().first { $0.id == note.id }
        XCTAssertNotNil(fetchedNote)
        XCTAssertEqual(fetchedNote?.tags.count, testTags.count)
        XCTAssertEqual(Set(fetchedNote?.tags ?? []), Set(testTags))
    }
    
    func testNoteRelatedCharacterIDsArrayHandling() {
        let manager = CoreDataManager.shared
        
        // 创建笔记和角色
        let note = manager.createNote(title: "测试笔记", content: "测试内容")
        let character1 = manager.createCharacter(name: "角色1", description: "描述1")
        let character2 = manager.createCharacter(name: "角色2", description: "描述2")
        
        // 更新笔记关联角色
        var updatedNote = note
        updatedNote.relatedCharacterIDs = [character1.id, character2.id]
        manager.updateNote(updatedNote)
        
        // 验证关联角色ID正确保存和读取
        let fetchedNote = manager.fetchNotes().first { $0.id == note.id }
        XCTAssertNotNil(fetchedNote)
        XCTAssertEqual(fetchedNote?.relatedCharacterIDs.count, 2)
        XCTAssertTrue(fetchedNote?.relatedCharacterIDs.contains(character1.id) ?? false)
        XCTAssertTrue(fetchedNote?.relatedCharacterIDs.contains(character2.id) ?? false)
    }
    
    func testNoteRelatedSceneIDsArrayHandling() {
        let manager = CoreDataManager.shared
        
        // 创建笔记和场景
        let note = manager.createNote(title: "测试笔记", content: "测试内容")
        let scene1 = manager.createScene(title: "场景1", description: "描述1")
        let scene2 = manager.createScene(title: "场景2", description: "描述2")
        
        // 更新笔记关联场景
        var updatedNote = note
        updatedNote.relatedSceneIDs = [scene1.id, scene2.id]
        manager.updateNote(updatedNote)
        
        // 验证关联场景ID正确保存和读取
        let fetchedNote = manager.fetchNotes().first { $0.id == note.id }
        XCTAssertNotNil(fetchedNote)
        XCTAssertEqual(fetchedNote?.relatedSceneIDs.count, 2)
        XCTAssertTrue(fetchedNote?.relatedSceneIDs.contains(scene1.id) ?? false)
        XCTAssertTrue(fetchedNote?.relatedSceneIDs.contains(scene2.id) ?? false)
    }
    
    // MARK: - Scene Array Tests
    
    func testSceneTagsArrayHandling() {
        let manager = CoreDataManager.shared
        
        // 创建带有tags的场景
        let testTags = ["森林", "神秘", "危险"]
        let scene = manager.createScene(title: "测试场景", description: "测试描述")
        
        // 更新场景添加tags
        var updatedScene = scene
        updatedScene.tags = testTags
        manager.updateScene(updatedScene)
        
        // 验证tags正确保存和读取
        let fetchedScene = manager.fetchScenes().first { $0.id == scene.id }
        XCTAssertNotNil(fetchedScene)
        XCTAssertEqual(fetchedScene?.tags.count, testTags.count)
        XCTAssertEqual(Set(fetchedScene?.tags ?? []), Set(testTags))
    }
    
    func testSceneRelatedNoteIDsArrayHandling() {
        let manager = CoreDataManager.shared
        
        // 创建场景和笔记
        let scene = manager.createScene(title: "测试场景", description: "测试描述")
        let note1 = manager.createNote(title: "笔记1", content: "内容1")
        let note2 = manager.createNote(title: "笔记2", content: "内容2")
        
        // 更新场景关联笔记
        var updatedScene = scene
        updatedScene.relatedNoteIDs = [note1.id, note2.id]
        manager.updateScene(updatedScene)
        
        // 验证关联笔记ID正确保存和读取
        let fetchedScene = manager.fetchScenes().first { $0.id == scene.id }
        XCTAssertNotNil(fetchedScene)
        XCTAssertEqual(fetchedScene?.relatedNoteIDs.count, 2)
        XCTAssertTrue(fetchedScene?.relatedNoteIDs.contains(note1.id) ?? false)
        XCTAssertTrue(fetchedScene?.relatedNoteIDs.contains(note2.id) ?? false)
    }
    
    // MARK: - Edge Cases Tests
    
    func testEmptyArrayHandling() {
        let manager = CoreDataManager.shared
        
        // 创建实体
        let character = manager.createCharacter(name: "测试角色", description: "测试描述")
        let note = manager.createNote(title: "测试笔记", content: "测试内容")
        let scene = manager.createScene(title: "测试场景", description: "测试描述")
        
        // 验证空数组正确处理
        let fetchedCharacter = manager.fetchCharacters().first { $0.id == character.id }
        let fetchedNote = manager.fetchNotes().first { $0.id == note.id }
        let fetchedScene = manager.fetchScenes().first { $0.id == scene.id }
        
        XCTAssertNotNil(fetchedCharacter)
        XCTAssertNotNil(fetchedNote)
        XCTAssertNotNil(fetchedScene)
        
        // 验证默认空数组
        XCTAssertEqual(fetchedCharacter?.tags.count, 0)
        XCTAssertEqual(fetchedCharacter?.relatedNoteIDs.count, 0)
        XCTAssertEqual(fetchedNote?.tags.count, 0)
        XCTAssertEqual(fetchedNote?.relatedCharacterIDs.count, 0)
        XCTAssertEqual(fetchedNote?.relatedSceneIDs.count, 0)
        XCTAssertEqual(fetchedScene?.tags.count, 0)
        XCTAssertEqual(fetchedScene?.relatedNoteIDs.count, 0)
    }
    
    func testLargeArrayHandling() {
        let manager = CoreDataManager.shared
        
        // 创建角色
        let character = manager.createCharacter(name: "测试角色", description: "测试描述")
        
        // 创建大量tags
        let largeTags = (1...100).map { "标签\($0)" }
        
        // 更新角色
        var updatedCharacter = character
        updatedCharacter.tags = largeTags
        manager.updateCharacter(updatedCharacter)
        
        // 验证大数组正确处理
        let fetchedCharacter = manager.fetchCharacters().first { $0.id == character.id }
        XCTAssertNotNil(fetchedCharacter)
        XCTAssertEqual(fetchedCharacter?.tags.count, 100)
        XCTAssertEqual(Set(fetchedCharacter?.tags ?? []), Set(largeTags))
    }
    
    func testArrayTypeConsistency() {
        let manager = CoreDataManager.shared
        
        // 创建角色
        let character = manager.createCharacter(name: "测试角色", description: "测试描述")
        
        // 添加tags
        var updatedCharacter = character
        updatedCharacter.tags = ["测试标签"]
        manager.updateCharacter(updatedCharacter)
        
        // 多次读取验证类型一致性
        for _ in 1...5 {
            let fetchedCharacter = manager.fetchCharacters().first { $0.id == character.id }
            XCTAssertNotNil(fetchedCharacter)
            XCTAssertTrue(fetchedCharacter?.tags is [String])
            XCTAssertEqual(fetchedCharacter?.tags.count, 1)
            XCTAssertEqual(fetchedCharacter?.tags.first, "测试标签")
        }
    }
}
