import Foundation

struct DataModule {
    static let notes: [NoteBlock] = [
        NoteBlock(id: UUID(), title: "初遇", content: "主角在酒馆邂逅神秘人。", relatedCharacterIDs: [UUID(), UUID()], relatedSceneIDs: [UUID()], date: Date()),
        NoteBlock(id: UUID(), title: "遗迹探索", content: "队伍进入古老遗迹，发现线索。", relatedCharacterIDs: [UUID()], relatedSceneIDs: [UUID(), UUID()], date: Date())
    ]

    static let characterCards: [CharacterCard] = [
        CharacterCard(id: UUID(), name: "艾莉丝", description: "一位勇敢的冒险者", avatar: nil, tags: ["主角"], noteIDs: [], sceneIDs: []),
        CharacterCard(id: UUID(), name: "莱因哈特", description: "神秘的吟游诗人", avatar: nil, tags: ["NPC"], noteIDs: [], sceneIDs: [])
    ]

    static let availableScenes: [AdventureScene] = [
        AdventureScene(id: UUID(), title: "古老遗迹", description: "充满谜团的遗迹遗址。", relatedCharacterIDs: [], relatedNoteIDs: []),
        AdventureScene(id: UUID(), title: "王都广场", description: "热闹非凡的城市中心。", relatedCharacterIDs: [], relatedNoteIDs: [])
    ]

    static let audioRecordings: [AudioRecording] = [
        AudioRecording(id: UUID(), title: "森林中的声音", recordingURL: URL(string: "https://example.com/forest.mp3")!, date: Date()),
        AudioRecording(id: UUID(), title: "海浪的低语", recordingURL: URL(string: "https://example.com/waves.mp3")!, date: Date())
    ]
}