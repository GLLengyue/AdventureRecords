import Foundation

struct AdventureScene: Identifiable, Hashable {
    let id: UUID
    var title: String
    var description: String
    var relatedCharacterIDs: [UUID]
    var relatedNoteIDs: [UUID]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: AdventureScene, rhs: AdventureScene) -> Bool {
        lhs.id == rhs.id
    }
} 