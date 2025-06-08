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
                                           description: "这是示例角色，帮助你快速了解 AdventureRecords 的使用方法。单击以查看详情，右滑以删除。\n可在“更多”页最下点击“生成示例数据”按钮，生成《西游记》示例数据快速体验本应用功能。",
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

    /// 西游记示例数据
    static func generateJourneyToWestSample() {
        var wukong = shared.createCharacter(name: "孙悟空",
                                            description: "花果山美猴王",
                                            avatar: nil)
        var bodhi = shared.createCharacter(name: "菩提祖师",
                                           description: "悟空的师父",
                                           avatar: nil)
        var tangseng = shared.createCharacter(name: "唐僧",
                                              description: "东土取经人",
                                              avatar: nil)
        var baigujing = shared.createCharacter(name: "白骨精",
                                              description: "善于变化的妖精",
                                              avatar: nil)
        var sixear = shared.createCharacter(name: "六耳猕猴",
                                           description: "假冒孙悟空的妖猴",
                                           avatar: nil)

        wukong.tags = ["取经前", "取经后"]
        bodhi.tags = ["取经前"]
        tangseng.tags = ["取经后"]
        baigujing.tags = ["取经后"]
        sixear.tags = ["取经后"]

        var fangcun = shared.createScene(title: "灵台方寸山",
                                         description: "菩提祖师道场")
        var palace = shared.createScene(title: "天宫",
                                       description: "众神居所")
        var cave = shared.createScene(title: "白骨洞",
                                      description: "白骨精的巢穴")
        var huaguo = shared.createScene(title: "花果山",
                                       description: "美猴王的故乡")

        fangcun.tags = ["取经前"]
        palace.tags = ["取经前"]
        cave.tags = ["取经后"]
        huaguo.tags = ["取经前"]

        var apprenticeship = shared.createNote(title: "拜师菩提祖师",
                                                content: "悟空求仙学艺，拜菩提祖师为师。")
        apprenticeship.tags = ["取经前"]

        var havoc = shared.createNote(title: "大闹天宫",
                                      content: "悟空大闹天宫，惊动诸神。")
        havoc.tags = ["取经前"]

        var bone = shared.createNote(title: "三打白骨精",
                                     content: "悟空识破白骨精，三次将其打退。")
        bone.tags = ["取经后"]

        var fake = shared.createNote(title: "真假美猴王",
                                     content: "六耳猕猴假冒悟空，如来辨真身。")
        fake.tags = ["取经后"]

        // 建立关联
        apprenticeship.addRelatedCharacterID(wukong.id)
        apprenticeship.addRelatedCharacterID(bodhi.id)
        apprenticeship.addRelatedSceneID(fangcun.id)
        wukong.addNoteID(apprenticeship.id)
        bodhi.addNoteID(apprenticeship.id)
        fangcun.addRelatedNoteID(apprenticeship.id)

        havoc.addRelatedCharacterID(wukong.id)
        havoc.addRelatedSceneID(palace.id)
        wukong.addNoteID(havoc.id)
        palace.addRelatedNoteID(havoc.id)

        bone.addRelatedCharacterID(wukong.id)
        bone.addRelatedCharacterID(tangseng.id)
        bone.addRelatedCharacterID(baigujing.id)
        bone.addRelatedSceneID(cave.id)
        wukong.addNoteID(bone.id)
        tangseng.addNoteID(bone.id)
        baigujing.addNoteID(bone.id)
        cave.addRelatedNoteID(bone.id)

        fake.addRelatedCharacterID(wukong.id)
        fake.addRelatedCharacterID(tangseng.id)
        fake.addRelatedCharacterID(sixear.id)
        fake.addRelatedSceneID(huaguo.id)
        wukong.addNoteID(fake.id)
        tangseng.addNoteID(fake.id)
        sixear.addNoteID(fake.id)
        huaguo.addRelatedNoteID(fake.id)

        // 更新
        shared.updateCharacter(wukong)
        shared.updateCharacter(bodhi)
        shared.updateCharacter(tangseng)
        shared.updateCharacter(baigujing)
        shared.updateCharacter(sixear)
        shared.updateScene(fangcun)
        shared.updateScene(palace)
        shared.updateScene(cave)
        shared.updateScene(huaguo)
        shared.updateNote(apprenticeship)
        shared.updateNote(havoc)
        shared.updateNote(bone)
        shared.updateNote(fake)
    }
}
