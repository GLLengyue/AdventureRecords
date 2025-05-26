import Foundation

/// 示例数据生成器
/// 用于在开发环境和首次安装时生成示例数据
enum SampleDataGenerator {
    static let shared = CoreDataManager.shared

    /// 检查是否需要初始化数据
    static func checkAndInitializeIfNeeded() {
        // 这里可以通过 UserDefaults 检查是否是首次启动
        let defaults = UserDefaults.standard
        let hasInitializedKey = "hasInitializedSampleData"

        if !defaults.bool(forKey: hasInitializedKey) {
            initializeData()
            defaults.set(true, forKey: hasInitializedKey)
        }
    }

    /// 初始化示例数据
    static func initializeData() {
        #if DEBUG
            initializeDebugData()
        #else
            initializeProductionData()
        #endif
    }

    /// 开发环境的示例数据
    private static func initializeDebugData() {
        // 创建角色
        var alice = shared.createCharacter(name: "艾莉丝",
                                           description: "一位勇敢的冒险者",
                                           avatar: nil)

        var reinhart = shared.createCharacter(name: "莱因哈特",
                                              description: "神秘的吟游诗人",
                                              avatar: nil)

        // 创建场景
        var ruins = shared.createScene(title: "古老遗迹",
                                       description: "充满谜团的遗迹遗址。")

        var plaza = shared.createScene(title: "王都广场",
                                       description: "热闹非凡的城市中心。")

        // 创建笔记
        var firstMeeting = shared.createNote(title: "初遇",
                                             content: "主角在酒馆邂逅神秘人。")

        var exploration = shared.createNote(title: "遗迹探索",
                                            content: "队伍进入古老遗迹，发现线索。")

        // 建立关联关系
        alice.addNoteID(firstMeeting.id)
        firstMeeting.addRelatedCharacterID(alice.id)

        alice.addNoteID(exploration.id)
        exploration.addRelatedCharacterID(alice.id)

        reinhart.addNoteID(firstMeeting.id)
        firstMeeting.addRelatedCharacterID(reinhart.id)

        ruins.addRelatedNoteID(exploration.id)
        exploration.addRelatedSceneID(ruins.id)

        plaza.addRelatedNoteID(firstMeeting.id)
        firstMeeting.addRelatedSceneID(plaza.id)

        // 更新数据
        shared.updateCharacter(alice)
        shared.updateCharacter(reinhart)
        shared.updateScene(ruins)
        shared.updateScene(plaza)
        shared.updateNote(firstMeeting)
        shared.updateNote(exploration)
    }

    /// 生产环境的引导数据
    private static func initializeProductionData() {
        // 创建一个简单的示例，帮助用户理解应用
        let guide = shared.createCharacter(name: "冒险指南",
                                           description: "欢迎来到冒险笔记！这是一个帮助你记录和管理角色、场景和故事的工具。",
                                           avatar: nil)
        shared.updateCharacter(guide)

        let tutorial = shared.createScene(title: "开始你的冒险",
                                          description: "这是你的第一个场景。你可以在这里记录故事发生的地点、时间和氛围。")
        shared.updateScene(tutorial)

        let welcome = shared.createNote(title: "使用指南",
                                        content: "1. 创建角色：记录你故事中的人物特征和背景\n2. 设计场景：描述故事发生的环境和氛围\n3. 撰写笔记：记录发生的事件和情节\n4. 建立关联：将角色、场景和笔记关联起来，编织完整的故事")
        shared.updateNote(welcome)

        // 建立关联关系
    }

    /// 清除所有数据（用于测试）
    static func clearAllData() {
        #if DEBUG
            // TODO: 实现清除数据的逻辑
        #endif
    }
}
