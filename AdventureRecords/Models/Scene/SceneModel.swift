import Foundation
import UIKit
import SwiftUI

struct AdventureScene: Identifiable, Hashable {
    let id: UUID
    var title: String
    var description: String
    var relatedNoteIDs: [UUID]
    var coverImage: UIImage?
    var audioURL: URL?
    var tags: [String]
    
    // 场景氛围设置
    var atmosphere: SceneAtmosphere
    
    init(id: UUID = UUID(), title: String, description: String, relatedNoteIDs: [UUID] = [], coverImage: UIImage? = nil, audioURL: URL? = nil, atmosphere: SceneAtmosphere = .default, tags: [String] = []) {
        self.id = id
        self.title = title
        self.description = description
        self.relatedNoteIDs = relatedNoteIDs
        self.coverImage = coverImage
        self.audioURL = audioURL
        self.atmosphere = atmosphere
        self.tags = tags
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: AdventureScene, rhs: AdventureScene) -> Bool {
        lhs.id == rhs.id
    }
}

extension AdventureScene {
    mutating func addRelatedNoteID(_ noteID: UUID) {
        relatedNoteIDs.append(noteID)
        relatedNoteIDs = Array(Set(relatedNoteIDs))
    }

    mutating func removeRelatedNoteID(_ noteID: UUID) {
        if let index = relatedNoteIDs.firstIndex(of: noteID) {
            relatedNoteIDs.remove(at: index)
        }
    }

    func relatedNotes(in notes: [NoteBlock]) -> [NoteBlock] {
        return notes.filter { relatedNoteIDs.contains($0.id) }
    }

    func relatedCharacters(in notes: [NoteBlock], characterProvider: (NoteBlock) -> [Character]) -> [Character] {
        let relatedNotes = relatedNotes(in: notes)
        let characters = relatedNotes.flatMap(characterProvider)
        return Array(Set(characters)).sorted { $0.id.uuidString < $1.id.uuidString }
    }
}

// 场景氛围设置
struct SceneAtmosphere: Hashable {
    var backgroundColor: Color
    var ambientSound: URL?
    var lightingEffect: LightingEffect
    var particleEffect: ParticleEffect?
    
    static let `default` = SceneAtmosphere(
        backgroundColor: .black,
        ambientSound: nil,
        lightingEffect: .none,
        particleEffect: nil
    )
    
    func hash(into hasher: inout Hasher) {
        // 使用 Color 的 RGB 值来计算哈希值
        if let components = UIColor(backgroundColor).cgColor.components {
            hasher.combine(components)
        }
        hasher.combine(ambientSound)
        hasher.combine(lightingEffect)
        hasher.combine(particleEffect)
    }
    
    static func == (lhs: SceneAtmosphere, rhs: SceneAtmosphere) -> Bool {
        // 比较 Color 的 RGB 值
        let lhsComponents = UIColor(lhs.backgroundColor).cgColor.components
        let rhsComponents = UIColor(rhs.backgroundColor).cgColor.components
        return lhsComponents == rhsComponents &&
            lhs.ambientSound == rhs.ambientSound &&
            lhs.lightingEffect == rhs.lightingEffect &&
            lhs.particleEffect == rhs.particleEffect
    }
}

enum LightingEffect: String, CaseIterable {
    case none = "无"
    case dim = "昏暗"
    case bright = "明亮"
    case flickering = "闪烁"
    case spotlight = "聚光灯"
}

enum ParticleEffect: String, CaseIterable {
    case none = "无"
    case dust = "灰尘"
    case rain = "雨"
    case snow = "雪"
    case fireflies = "萤火虫"
    case leaves = "落叶"
}