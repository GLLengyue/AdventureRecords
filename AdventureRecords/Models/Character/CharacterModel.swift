import Foundation
import UIKit

struct Character: Identifiable, Hashable {
    let id: UUID
    var name: String
    var description: String
    var avatar: UIImage?
    var audioRecordings: [AudioRecording]?
    var tags: [String]
    var relatedNoteIDs: [UUID]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Character, rhs: Character) -> Bool {
        lhs.id == rhs.id
    }

    init(id: UUID = UUID(), name: String, description: String, avatar: UIImage? = nil, audioRecordings: [AudioRecording]? = nil, tags: [String] = [], relatedNoteIDs: [UUID] = []) {
        self.id = id
        self.name = name
        self.description = description
        self.avatar = avatar
        self.audioRecordings = audioRecordings
        self.tags = tags
        self.relatedNoteIDs = relatedNoteIDs
    }
    
}

extension Character {
    mutating func addNoteID(_ noteID: UUID) {
        if !relatedNoteIDs.contains(noteID) {
            relatedNoteIDs.append(noteID)
        }
    }

    mutating func removeNoteID(_ noteID: UUID) {
        if let index = relatedNoteIDs.firstIndex(of: noteID) {
            relatedNoteIDs.remove(at: index)
        }
    }

    func relatedNotes(in notes: [NoteBlock]) -> [NoteBlock] {
        return notes.filter { relatedNoteIDs.contains($0.id) }
    }

    func relatedScenes(in notes: [NoteBlock], sceneProvider: (NoteBlock) -> [AdventureScene]) -> [AdventureScene] {
        relatedNotes(in: notes).flatMap(sceneProvider)
    }

}