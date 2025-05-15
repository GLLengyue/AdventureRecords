import Foundation
import UIKit
import SwiftUI

struct AdventureScene: Identifiable, Hashable {
    let id: UUID
    var title: String
    var description: String
    var relatedCharacterIDs: [UUID]
    var relatedNoteIDs: [UUID]
    var coverImage: UIImage?
    var audioURL: URL?
    
    // 场景氛围设置
    var atmosphere: SceneAtmosphere
    
    init(id: UUID = UUID(), title: String, description: String, relatedCharacterIDs: [UUID] = [], relatedNoteIDs: [UUID] = [], coverImage: UIImage? = nil, audioURL: URL? = nil, atmosphere: SceneAtmosphere = .default) {
        self.id = id
        self.title = title
        self.description = description
        self.relatedCharacterIDs = relatedCharacterIDs
        self.relatedNoteIDs = relatedNoteIDs
        self.coverImage = coverImage
        self.audioURL = audioURL
        self.atmosphere = atmosphere
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: AdventureScene, rhs: AdventureScene) -> Bool {
        lhs.id == rhs.id
    }
    
    mutating func addRelatedNoteID(_ noteID: UUID) {
        relatedNoteIDs.append(noteID)
        relatedNoteIDs = Array(Set(relatedNoteIDs))
    }

    mutating func addRelatedCharacterIDs(_ characterIDs: [UUID]) {
        relatedCharacterIDs.append(contentsOf: characterIDs)
        relatedCharacterIDs = Array(Set(relatedCharacterIDs))
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