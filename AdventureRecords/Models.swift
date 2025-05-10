//  Models.swift
//  AdventureRecords
//  数据模型定义：角色卡、笔记块、场景、三向链接
import Foundation
import SwiftUI
import UIKit

struct CharacterCard: Identifiable, Hashable {
    let id: UUID
    var name: String
    var description: String
    var avatar: UIImage?
    var audioRecordings: [AudioRecording]?
    var tags: [String]
    var noteIDs: [UUID]
    var sceneIDs: [UUID]
    
    // 用于Hashable协议
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: CharacterCard, rhs: CharacterCard) -> Bool {
        lhs.id == rhs.id
    }
}

// 音频记录结构
struct AudioRecording: Identifiable, Hashable {
    let id: UUID
    var title: String
    var recordingURL: URL
    var date: Date
}

struct NoteBlock: Identifiable, Hashable {
    let id: UUID
    var title: String
    var content: String
    var relatedCharacterIDs: [UUID]
    var relatedSceneIDs: [UUID]
    var date: Date
}

struct AdventureScene: Identifiable, Hashable {
    let id: UUID
    var title: String
    var description: String
    var relatedCharacterIDs: [UUID]
    var relatedNoteIDs: [UUID]
}

// 三向链接引用类型
enum LinkTarget: Hashable {
    case character(UUID)
    case note(UUID)
    case scene(UUID)
}
