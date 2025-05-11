import Foundation

struct DataModule {
    // 创建一些固定的 UUID 用于关联
    static let character1ID = UUID()
    static let character2ID = UUID()
    static let scene1ID = UUID()
    static let scene2ID = UUID()
    static let note1ID = UUID()
    static let note2ID = UUID()

    static let notes: [NoteBlock] = [
        NoteBlock(
            id: note1ID,
            title: "初遇",
            content: "主角在酒馆邂逅神秘人。",
            relatedCharacterIDs: [character1ID, character2ID],
            relatedSceneIDs: [scene1ID],
            date: Date()
        ),
        NoteBlock(
            id: note2ID,
            title: "遗迹探索",
            content: "队伍进入古老遗迹，发现线索。",
            relatedCharacterIDs: [character1ID],
            relatedSceneIDs: [scene1ID, scene2ID],
            date: Date()
        )
    ]

    static let characterCards: [CharacterCard] = [
        CharacterCard(
            id: character1ID,
            name: "艾莉丝",
            description: "一位勇敢的冒险者",
            avatar: nil,
            tags: ["主角"],
            noteIDs: [note1ID, note2ID],
            sceneIDs: [scene1ID, scene2ID]
        ),
        CharacterCard(
            id: character2ID,
            name: "莱因哈特",
            description: "神秘的吟游诗人",
            avatar: nil,
            tags: ["NPC"],
            noteIDs: [note1ID],
            sceneIDs: [scene1ID]
        )
    ]

    static let availableScenes: [AdventureScene] = [
        AdventureScene(
            id: scene1ID,
            title: "古老遗迹",
            description: "充满谜团的遗迹遗址。",
            relatedCharacterIDs: [character1ID, character2ID],
            relatedNoteIDs: [note1ID, note2ID]
        ),
        AdventureScene(
            id: scene2ID,
            title: "王都广场",
            description: "热闹非凡的城市中心。",
            relatedCharacterIDs: [character1ID],
            relatedNoteIDs: [note2ID]
        )
    ]

    static let audioRecordings: [AudioRecording] = [
        AudioRecording(id: UUID(), title: "森林中的声音", recordingURL: URL(string: "https://example.com/forest.mp3")!, date: Date()),
        AudioRecording(id: UUID(), title: "海浪的低语", recordingURL: URL(string: "https://example.com/waves.mp3")!, date: Date())
    ]
}