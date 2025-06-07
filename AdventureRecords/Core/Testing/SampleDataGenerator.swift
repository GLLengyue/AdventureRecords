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
        // 创建一个示例角色，引导用户了解应用功能
        var guide = shared.createCharacter(name: "冒险指南",
                                           description: "这是示例角色，帮助你快速了解 AdventureRecords 的使用方法。单击以查看详情，右滑以删除。",
                                           avatar: nil)

        // 创建示例场景
        var tutorial = shared.createScene(title: "开始你的冒险",
                                          description: "在场景中记录地点，并新建相关的笔记。你还可以为场景上传封面图。")

        // 创建示例笔记，概述主要功能
        var welcome = shared.createNote(title: "快速上手指南",
                                        content: "欢迎使用 AdventureRecords！\n\n1. 角色卡：创建角色并管理头像、标签和语音。\n2. 场景：记录地点、氛围与背景音乐。\n3. 笔记块：撰写故事，关联角色与场景。\n4. 三向链接：在角色、场景和笔记之间跳转。\n5. 沉浸模式：全屏编辑内容。\n6. 数据管理：备份、恢复、导出或清理数据。\n7. 音频记录：录制或导入音频并附加到人物卡。\n8. 标签：为场景，笔记和人物分别添加标签，之后可在标签云中快速筛选出你想查看的内容。\n\n删除或编辑这些示例，开始你的冒险吧！")

        // 建立关联关系
        welcome.addRelatedCharacterID(guide.id)
        welcome.addRelatedSceneID(tutorial.id)
        guide.addNoteID(welcome.id)
        tutorial.addRelatedNoteID(welcome.id)

        // 更新数据
        shared.updateNote(welcome)
        shared.updateCharacter(guide)
        shared.updateScene(tutorial)
    }

    /// 清除所有数据（用于测试）
    static func clearAllData() {
        #if DEBUG
        _ = shared.cleanupData(type: .all)
        #endif
    }
}
