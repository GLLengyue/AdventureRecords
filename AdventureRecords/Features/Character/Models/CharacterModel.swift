import Foundation
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
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: CharacterCard, rhs: CharacterCard) -> Bool {
        lhs.id == rhs.id
    }
} 