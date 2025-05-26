import Foundation

struct NoteBlock: Identifiable, Hashable {
    let id: UUID
    var title: String
    var content: String
    var relatedCharacterIDs: [UUID]
    var relatedSceneIDs: [UUID]
    var date: Date
    var tags: [String]

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: NoteBlock, rhs: NoteBlock) -> Bool {
        lhs.id == rhs.id
    }
}

extension NoteBlock {
    func relatedCharacters(in characters: [Character]) -> [Character] {
        characters.filter { relatedCharacterIDs.contains($0.id) }
    }

    func relatedScenes(in scenes: [AdventureScene]) -> [AdventureScene] {
        scenes.filter { relatedSceneIDs.contains($0.id) }
    }

    mutating func addRelatedCharacterID(_ characterID: UUID) {
        if !relatedCharacterIDs.contains(characterID) {
            relatedCharacterIDs.append(characterID)
        }
    }

    mutating func addRelatedSceneID(_ sceneID: UUID) {
        if !relatedSceneIDs.contains(sceneID) {
            relatedSceneIDs.append(sceneID)
        }
    }
}
