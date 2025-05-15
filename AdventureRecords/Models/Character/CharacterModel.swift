import Foundation
import UIKit

struct Character: Identifiable, Hashable {
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
    
    static func == (lhs: Character, rhs: Character) -> Bool {
        lhs.id == rhs.id
    }
    
    mutating func addNoteID(_ noteID: UUID) {
        noteIDs.append(noteID)
        noteIDs = Array(Set(noteIDs))
    }

    mutating func addSceneIDs(_ SceneIDs: [UUID]) {
        sceneIDs.append(contentsOf: SceneIDs)
        sceneIDs = Array(Set(sceneIDs))
    }
}