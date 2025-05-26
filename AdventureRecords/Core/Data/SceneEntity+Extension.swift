import CoreData
import Foundation
import SwiftUI

extension SceneEntity {
    var atmosphere: SceneAtmosphere {
        get {
            guard let data = atmosphereData,
                  let atmosphere = try? JSONDecoder().decode(SceneAtmosphere.self, from: data)
            else {
                return .default
            }
            return atmosphere
        }
        set {
            atmosphereData = try? JSONEncoder().encode(newValue)
        }
    }
}

// 为 SceneAtmosphere 添加 Codable 支持
extension SceneAtmosphere: Codable {
    enum CodingKeys: String, CodingKey {
        case backgroundColor
        case ambientSound
        case lightingEffect
        case particleEffect
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let colorData = try container.decode(Data.self, forKey: .backgroundColor)
        backgroundColor =
            Color((try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData)) ?? .black)
        ambientSound = try container.decodeIfPresent(URL.self, forKey: .ambientSound)
        lightingEffect = try container.decode(LightingEffect.self, forKey: .lightingEffect)
        particleEffect = try container.decodeIfPresent(ParticleEffect.self, forKey: .particleEffect)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let colorData = try NSKeyedArchiver.archivedData(withRootObject: UIColor(backgroundColor),
                                                         requiringSecureCoding: true)
        try container.encode(colorData, forKey: .backgroundColor)
        try container.encodeIfPresent(ambientSound, forKey: .ambientSound)
        try container.encode(lightingEffect, forKey: .lightingEffect)
        try container.encodeIfPresent(particleEffect, forKey: .particleEffect)
    }
}

// 为 LightingEffect 和 ParticleEffect 添加 Codable 支持
extension LightingEffect: Codable {}
extension ParticleEffect: Codable {}
