import Foundation

struct NoteBlock: Identifiable, Hashable {
    let id: UUID
    var title: String
    var content: String
    var relatedCharacterIDs: [UUID]
    var relatedSceneIDs: [UUID]
    var date: Date
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: NoteBlock, rhs: NoteBlock) -> Bool {
        lhs.id == rhs.id
    }
}