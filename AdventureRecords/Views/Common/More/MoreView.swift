import StoreKit
import SwiftUI
import CoreData

struct MoreView: View {
    @Environment(\.managedObjectContext) private var viewContext
    // 状态变量
    @State private var showSettings = false
    @State private var showHelpCenter = false
    @State private var showAbout = false
    @State private var showFeedback = false
    @State private var showPrivacyPolicy = false
    @State private var showTermsOfService = false
    @State private var showDonationSheet = false
    @State private var showResetConfirmation = false
    @State private var showDataManagement = false
    @State private var showDataManagerTest = false
    @State private var showAudioManagement = false
    @State private var showClearAllDataConfirmation = false

    // 应用设置
    @AppStorage("isDarkMode") private var isDarkMode = false
    // @AppStorage("debugMode") private var debugMode = false


    let themeManager: ThemeManager = .shared

    var body: some View {
        VStack {
            HStack {
                Text("更多")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.leading)
                Spacer()
            }
            .padding(.top)

            List {

                // 功能部分
                Section(header: Text("功能")) {
                    // 数据管理
                    Button(action: { showDataManagement = true }) {
                        MoreMenuRow(icon: "externaldrive",
                                    iconColor: themeManager.accentColor(for: .character),
                                    title: "数据管理",
                                    subtitle: "备份、恢复和导出数据")
                    }
                    
                    // 音频管理
                    Button(action: { showAudioManagement = true }) {
                        MoreMenuRow(icon: "waveform",
                                    iconColor: .purple,
                                    title: "音频管理",
                                    subtitle: "管理所有录音文件")
                    }

                    // 设置
                    Button(action: { showSettings = true }) {
                        MoreMenuRow(icon: "gear",
                                    iconColor: themeManager.accentColor(for: .scene),
                                    title: "设置",
                                    subtitle: "应用设置和偏好")
                    }

                    // 捐赠
                    Button(action: { showDonationSheet = true }) {
                        MoreMenuRow(icon: "heart.circle",
                                    iconColor: .pink,
                                    title: "支持开发者",
                                    subtitle: "感谢您的支持与鼓励")
                    }

                    // 帮助中心
                    Button(action: { showHelpCenter = true }) {
                        MoreMenuRow(icon: "questionmark.circle",
                                    iconColor: themeManager.accentColor(for: .note),
                                    title: "帮助中心",
                                    subtitle: "使用指南和常见问题")
                    }

                    // 反馈与建议
                    Button(action: { showFeedback = true }) {
                        MoreMenuRow(icon: "envelope",
                                    iconColor: themeManager.accentColor(for: .scene),
                                    title: "反馈与建议",
                                    subtitle: "提交问题或功能建议")
                    }
                }

                // 关于部分
                Section(header: Text("关于")) {
                    Button(action: { showAbout = true }) {
                        MoreMenuRow(icon: "info.circle",
                                    iconColor: .blue,
                                    title: "关于冒险记录",
                                    subtitle: "版本 1.0.0")
                    }

                    Button(action: { showPrivacyPolicy = true }) {
                        MoreMenuRow(icon: "lock.shield",
                                    iconColor: .gray,
                                    title: "隐私政策",
                                    subtitle: "了解我们如何保护您的数据")
                    }

                    Button(action: { showTermsOfService = true }) {
                        MoreMenuRow(icon: "doc.text",
                                    iconColor: .gray,
                                    title: "用户协议",
                                    subtitle: "使用条款和条件")
                    }

                    Button(action: {
                        // 跳转到App Store评分
                        if let scene = UIApplication.shared.connectedScenes
                            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
                        {
                            Task {
                                AppStore.requestReview(in: scene)
                            }
                        }
                    }) {
                        MoreMenuRow(icon: "star",
                                    iconColor: .yellow,
                                    title: "给我们评分",
                                    subtitle: "在App Store上评分支持我们")
                    }
                }

                // 高级设置部分
                Section(header: Text("高级设置")) {
                    // Toggle("调试模式", isOn: $debugMode)
                    //     .toggleStyle(SwitchToggleStyle(tint: themeManager.accentColor(for: .character)))

                    // if debugMode {
                    //     Button(action: {
                    //         // 查看日志实现
                    //     }) {
                    //         MoreMenuRow(icon: "doc.text",
                    //                     iconColor: themeManager.accentColor(for: .note),
                    //                     title: "查看日志",
                    //                     subtitle: "查看应用运行日志")
                    //     }

                    //     Button(action: { showDataManagerTest = true }) {
                    //         MoreMenuRow(icon: "hammer",
                    //                     iconColor: themeManager.accentColor(for: .scene),
                    //                     title: "数据管理测试",
                    //                     subtitle: "测试备份、恢复和清理功能")
                    //     }
                    // }


                    Button(action: { showResetConfirmation = true }) {
                        MoreMenuRow(icon: "arrow.counterclockwise",
                                    iconColor: .red,
                                    title: "重置所有设置",
                                    subtitle: "将所有设置恢复为默认值")
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showHelpCenter) {
            HelpCenterView()
        }
        .sheet(isPresented: $showAbout) {
            AboutView()
        }
        .sheet(isPresented: $showFeedback) {
            FeedbackView()
        }
        .sheet(isPresented: $showPrivacyPolicy) {
            PrivacyPolicyView()
        }
        .sheet(isPresented: $showTermsOfService) {
            TermsOfServiceView()
        }
        .sheet(isPresented: $showAudioManagement) {
            AudioManagementView()
        }
        .sheet(isPresented: $showDonationSheet) {
            DonationView()
        }
        .sheet(isPresented: $showDataManagement) {
            DataManagementView()
        }
        .sheet(isPresented: $showDataManagerTest) {
            DataManagerTestView()
        }
        .alert(isPresented: $showResetConfirmation) {
            Alert(title: Text("重置所有设置"),
                  message: Text("确定要重置所有设置吗？这将不会删除您的数据。"),
                  primaryButton: .destructive(Text("重置")) {
                      // 重置设置实现
                      isDarkMode = false
                      // debugMode = false
                  },
                  secondaryButton: .cancel(Text("取消")))
        }
    }
}

// MARK: - 音频管理方法

extension AudioManagementView {
    private func clearAllAudioRecordings() {
        let context = CoreDataManager.shared.viewContext
        
        // 删除所有音频录音实体
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = AudioRecordingEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            
            // 删除音频文件
            let audioDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Recordings")
            if FileManager.default.fileExists(atPath: audioDirectory.path) {
                try? FileManager.default.removeItem(at: audioDirectory)
            }
            
            // 重新创建空目录
            try? FileManager.default.createDirectory(at: audioDirectory, withIntermediateDirectories: true)
            
            // 保存更改
            try context.save()
            
            // 显示成功提示
            let alert = UIAlertController(title: "成功", message: "已成功删除所有音频数据", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default))
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                rootViewController.present(alert, animated: true)
            }
        } catch {
            print("清除音频数据失败: \(error.localizedDescription)")
            
            // 显示错误提示
            let alert = UIAlertController(title: "错误", message: "清除音频数据失败: \(error.localizedDescription)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default))
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                rootViewController.present(alert, animated: true)
            }
        }
    }
}

// 音频管理视图
struct AudioManagementView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var audioRecordings: [AudioRecording] = []
    @State private var showDeleteConfirmation = false
    @State private var recordingToDelete: AudioRecording?
    @State private var showClearAudioConfirmation = false
    
    var body: some View {
        NavigationView {
            List {
                if audioRecordings.isEmpty {
                    Text("没有找到录音文件")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowBackground(Color.clear)
                } else {
                    ForEach(audioRecordings, id: \.id) { recording in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(recording.title)
                                    .font(.headline)
                                Text(recording.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                // 播放/停止音频
                            }) {
                                Image(systemName: "play.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            
                            Button(role: .destructive) {
                                recordingToDelete = recording
                                showDeleteConfirmation = true
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                    }
                    Button(role: .destructive, action: { showClearAudioConfirmation = true }) {
                        Text("清除所有音频数据")
                    }
                }
            }
            .navigationTitle("音频管理")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
            .confirmationDialog("删除录音", isPresented: $showDeleteConfirmation, presenting: recordingToDelete) { recording in
                Button("删除", role: .destructive) {
                    deleteRecording(recording)
                }
            } message: { recording in
                Text("确定要删除录音 \"\(recording.title)\" 吗？此操作无法撤销。")
            }
            .onAppear {
                fetchAudioRecordings()
            }
            .alert("确认清除所有音频数据", isPresented: $showClearAudioConfirmation) {
                Button("清除", role: .destructive) {
                    clearAllAudioRecordings()
                }
                Button("取消", role: .cancel) {}
            } message: {
                Text("此操作将删除所有录音文件，且无法撤销。确定要继续吗？")
            }
        }
    }
    
    private func fetchAudioRecordings() {
        let fetchRequest: NSFetchRequest<AudioRecordingEntity> = AudioRecordingEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \AudioRecordingEntity.date, ascending: false)]
        
        do {
            let entities = try viewContext.fetch(fetchRequest)
            audioRecordings = entities.compactMap { entity in
                guard let id = entity.id,
                      let title = entity.title,
                      let date = entity.date else {
                    return nil
                }
                
                let audioURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    .appendingPathComponent("Recordings")
                    .appendingPathComponent("\(id.uuidString).m4a")
                
                return AudioRecording(id: id, title: title, recordingURL: audioURL, date: date)
            }
        } catch {
            print("获取录音数据失败: \(error.localizedDescription)")
        }
    }
    
    private func deleteRecording(_ recording: AudioRecording) {
        let context = CoreDataManager.shared.viewContext
        
        // 删除实体
        let fetchRequest: NSFetchRequest<AudioRecordingEntity> = AudioRecordingEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", recording.id as CVarArg)
        
        do {
            if let entity = try context.fetch(fetchRequest).first {
                // 删除文件
                try? FileManager.default.removeItem(at: recording.recordingURL)
                
                // 删除实体
                context.delete(entity)
                
                // 保存更改
                try context.save()
                
                // 更新列表
                if let index = audioRecordings.firstIndex(where: { $0.id == recording.id }) {
                    audioRecordings.remove(at: index)
                }
            }
        } catch {
            print("删除录音失败: \(error.localizedDescription)")
            
            // 显示错误提示
            let alert = UIAlertController(title: "错误", message: "删除录音失败: \(error.localizedDescription)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default))
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                rootViewController.present(alert, animated: true)
            }
        }
    }
}

// 更多菜单行组件
struct MoreMenuRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(iconColor)
                .frame(width: 32, height: 32)
                .padding(.trailing, 10)

            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

// 帮助中心视图
struct HelpCenterView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let faqs = [
        (question: "如何创建新故事？", answer: "在笔记标签页点击右上角的'+'按钮，开始记录您的冒险故事。"),
        (question: "如何关联角色和场景？", answer: "在笔记编辑页面，点击'关联'按钮，选择要关联的角色和场景。"),
        (question: "如何查看故事中的角色和场景？", answer: "在笔记详情页，可以查看该故事涉及的所有角色和场景。"),
        (question: "如何备份和分享数据？", answer: "在'更多'→'数据管理'中，可以备份数据。长按备份文件可以分享给其他用户。"),
        (question: "如何启用iCloud同步？", answer: "在'更多'→'设置'中，开启'iCloud同步'选项。")
    ]
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("快速入门")) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("欢迎使用冒险记录")
                            .font(.headline)
                        
                        Text("建议的使用流程：首先创建角色和场景设定，然后在记录故事时建立它们之间的关联，以便更好地组织和管理您的冒险历程。")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 4)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Label("1. 创建角色和场景", systemImage: "person.2")
                                .font(.subheadline)
                                .padding(.vertical, 2)
                            Text("• 在角色和场景标签页中，点击右上角的'+'按钮分别创建新的角色和场景。")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.leading, 24)
                            
                            Label("2. 记录冒险故事", systemImage: "doc.text")
                                .font(.subheadline)
                                .padding(.vertical, 2)
                            Text("• 在笔记标签页中，点击'+'按钮创建新笔记，并在编辑界面中关联相关的角色和场景。")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.leading, 24)
                            
                            Label("3. 管理内容标签", systemImage: "tag")
                                .font(.subheadline)
                                .padding(.vertical, 2)
                            Text("• 为角色、场景和笔记添加标签，便于内容的分类和检索。")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.leading, 24)
                            
                            Label("4. 数据共享与备份", systemImage: "square.and.arrow.up")
                                .font(.subheadline)
                                .padding(.vertical, 2)
                            Text("• 支持将笔记导出为纯文本格式分享，或通过备份功能导出完整数据，方便跨设备同步或与其他玩家共享。")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.leading, 24)
                        }
                    }
                    .padding(.vertical, 12)
                }
                
                Section(header: Text("常见问题")) {
                    ForEach(faqs, id: \.question) { faq in
                        DisclosureGroup(faq.question) {
                            Text(faq.answer)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .padding(.vertical, 4)
                        }
                    }
                }
                
                Section {
                    Button(action: {
                        if let url = URL(string: "mailto:support@adventurerecords.app") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Text("联系支持团队")
                    }
                }
            }
            .navigationTitle("帮助中心")
            .navigationBarItems(trailing: Button("完成") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

// 关于视图
struct AboutView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 应用图标和名称
                    VStack(spacing: 16) {
                        Image(systemName: "book.closed.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        
                        Text("冒险记录")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("版本 \(version) (Build \(build))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 20)
                    
                    // 应用描述
                    VStack(alignment: .leading, spacing: 12) {
                        Text("关于")
                            .font(.headline)
                        
                        Text("冒险记录是一款专为桌面角色扮演游戏(TRPG)玩家设计的应用，帮助您轻松记录和管理游戏中的角色、场景和事件。除此之外，您还可以使用本应用辅助您的剧本创作。如果您觉得日常生活也是一种冒险，用本应用记录也不失为一种乐趣。")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // 开发者信息
                    VStack(alignment: .leading, spacing: 12) {
                        Text("开发者")
                            .font(.headline)
                        
                        Text("冒险记录由热爱角色扮演游戏的独立开发者开发。致力于为用户提供最佳的角色扮演辅助工具。")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // 版权信息
                    Text("© 2025 冒险记录 版权所有")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 10)
                        .padding(.bottom, 30)
                }
            }
            .navigationTitle("关于")
            .navigationBarItems(trailing: Button("完成") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

// 反馈与建议视图
struct FeedbackView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    private func openAppStoreReview() {
        if let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
        {
            Task {
                AppStore.requestReview(in: scene)
            }
        }
    }
    
    private func openEmailFeedback() {
        let email = "lifei.zhong@icloud.com"
        let subject = "冒险记录 反馈"
        let body = "\n\n\n---\n设备: \(UIDevice.current.model)\n系统版本: \(UIDevice.current.systemVersion)\n应用版本: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")"
        
        guard let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "mailto:\(email)?subject=\(encodedSubject)&body=\(encodedBody)") else {
            alertMessage = "无法创建邮件"
            showAlert = true
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            alertMessage = "未找到可用的邮件应用"
            showAlert = true
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()
                
                VStack(spacing: 16) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.yellow)
                    
                    Text("喜欢冒险记录吗？")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("您的支持对我们非常重要！请花一点时间在App Store上给我们评分。")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 32)
                }
                .padding()
                
                VStack(spacing: 16) {
                    VStack(spacing: 12) {
                        Button(action: openAppStoreReview) {
                            HStack {
                                Image(systemName: "star.fill")
                                Text("去App Store评分")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                        }
                        
                        Button(action: openEmailFeedback) {
                            HStack {
                                Image(systemName: "envelope.fill")
                                Text("通过邮件反馈")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 32)
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("稍后再说")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 20)
                
                Spacer()
                
                Text("当前版本: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 20)
            }
            .navigationTitle("评价我们")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("提示"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("确定"))
                )
            }
        }
    }
}

// 隐私政策视图
struct PrivacyPolicyView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("隐私政策")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.bottom, 8)
                        
                        Text("更新日期: 2025年5月31日")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("欢迎使用冒险记录应用。我们非常重视您的隐私。本隐私政策解释了我们会收集哪些信息、如何使用这些信息以及您的隐私权。")
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.bottom, 8)
                        
                        // 数据收集
                        VStack(alignment: .leading, spacing: 8) {
                            Text("1. 我们收集的信息")
                                .font(.headline)
                            
                            Text("我们不会收集您在使用应用时的任何信息，您的所有信息都保存在你的设备上，包括：")
                                .font(.body)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("• 角色信息：您创建的角色名称、属性、背景故事等")
                                Text("• 游戏内容：场景描述、笔记、任务记录等")
                                Text("• 应用设置：您的偏好设置和自定义选项")
                            }
                            .padding(.leading, 8)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 4)
                            
                            Text("我们不会收集您的个人身份信息，除非您自愿通过反馈功能提供。")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        // 数据使用
                        VStack(alignment: .leading, spacing: 8) {
                            Text("2. 数据使用")
                                .font(.headline)
                            
                            Text("我们使用您提供的的反馈来：")
                                .font(.body)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("• 提供、维护和改进我们的服务")
                                Text("• 响应您的客户服务请求")
                                Text("• 向您发送应用更新和支持信息")
                            }
                            .padding(.leading, 8)
                            .font(.body)
                            .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        // 数据存储与安全
                        VStack(alignment: .leading, spacing: 8) {
                            Text("3. 数据存储与安全")
                                .font(.headline)
                            
                            Text("• 本地存储：所有数据默认存储在您的设备上。")
                            Text("• iCloud同步：如果启用iCloud同步，您的数据将存储在您的iCloud账户中。")
                            
                            Text("您可以在设备的设置中管理iCloud同步选项。")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                                                
                        // 隐私政策变更
                        VStack(alignment: .leading, spacing: 8) {
                            Text("4. 隐私政策变更")
                                .font(.headline)
                            
                            Text("我们可能会不定期更新隐私政策。任何变更都会在本页面发布，并更新顶部的'更新日期'。建议您定期查看本隐私政策以了解变更。")
                                .font(.body)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        // 联系我们
                        VStack(alignment: .leading, spacing: 8) {
                            Text("5. 联系我们")
                                .font(.headline)
                            
                            Text("如果您对本隐私政策有任何疑问，请通过以下方式联系我们：")
                                .font(.body)
                            
                            Button(action: {
                                if let url = URL(string: "mailto:lifei.zhong@icloud.com") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                HStack {
                                    Image(systemName: "envelope")
                                    Text("lifei.zhong@icloud.com")
                                }
                                .font(.body)
                                .foregroundColor(.blue)
                            }
                            .padding(.top, 4)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .padding(.top, 8)
                }
                .padding()
            }
            .navigationTitle("隐私政策")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

// 用户协议视图
struct TermsOfServiceView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("用户协议")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.bottom, 4)
                        
                        Text("最后更新日期: 2025年5月31日")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("欢迎使用冒险记录应用。在开始使用我们的服务之前，请仔细阅读本用户协议。")
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        // 1. 协议范围
                        VStack(alignment: .leading, spacing: 8) {
                            Text("1. 协议范围")
                                .font(.headline)
                            
                            Text("本用户协议是您与冒险记录应用之间的法律协议，规定了您使用本应用的条件。通过下载、安装或使用本应用，即表示您同意受本协议的约束。")
                                .font(.body)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        // 2. 数据所有权
                        VStack(alignment: .leading, spacing: 8) {
                            Text("2. 数据所有权")
                                .font(.headline)
                            
                            Text("2.1 您通过本应用创建的所有内容，包括但不限于角色数据、游戏记录和设置，完全归您所有。")
                            
                            Text("2.2 我们不会访问、收集或存储您在本应用中创建的任何内容。所有数据都仅存储在您的设备本地。")
                                .padding(.top, 4)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        // 3. 使用限制
                        VStack(alignment: .leading, spacing: 8) {
                            Text("3. 使用限制")
                                .font(.headline)
                            
                            Text("3.1 您同意不会使用本应用进行任何非法活动或侵犯他人权利的行为。")
                            
                            Text("3.2 您不得对本应用进行反向工程、反编译或试图提取源代码。")
                                .padding(.top, 4)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        // 4. 免责声明
                        VStack(alignment: .leading, spacing: 8) {
                            Text("4. 免责声明")
                                .font(.headline)
                            
                            Text("4.1 本应用按'原样'提供，不作任何明示或暗示的保证。我们不保证本应用不会中断或没有错误。")
                            
                            Text("4.2 对于因使用或无法使用本应用而导致的任何直接、间接、附带、特殊、后果性或惩罚性损害，我们概不负责。")
                                .padding(.top, 4)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        // 5. 协议修改
                        VStack(alignment: .leading, spacing: 8) {
                            Text("5. 协议修改")
                                .font(.headline)
                            
                            Text("我们保留随时修改本协议的权利。任何更改将在发布更新后的协议后立即生效。您继续使用本应用即表示您接受这些更改。")
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        // 6. 适用法律
                        VStack(alignment: .leading, spacing: 8) {
                            Text("6. 适用法律")
                                .font(.headline)
                            
                            Text("本协议应受中华人民共和国法律管辖并按其解释，不考虑其法律冲突条款。")
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        // 7. 联系我们
                        VStack(alignment: .leading, spacing: 8) {
                            Text("7. 联系我们")
                                .font(.headline)
                            
                            Text("如果您对本用户协议有任何疑问，请通过以下方式联系我们：")
                            
                            Button(action: {
                                if let url = URL(string: "mailto:lifei.zhong@icloud.com") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                HStack {
                                    Image(systemName: "envelope")
                                    Text("lifei.zhong@icloud.com")
                                }
                                .font(.body)
                                .foregroundColor(.blue)
                            }
                            .padding(.top, 4)
                            
                            Text("最后更新日期: 2025年5月31日")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .padding(.top, 8)
                }
                .padding()
            }
            .navigationTitle("用户协议")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

// 捐赠视图
struct DonationView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var donationManager = DonationManager.shared
    
    // 捐赠选项
    let donationOptions = [
        (amount: 6, title: "请我喝杯咖啡", emoji: "☕️"),
        (amount: 15, title: "请我吃顿午饭", emoji: "🍱"),
        (amount: 30, title: "请我吃顿大餐", emoji: "🍽️"),
        (amount: 66, title: "慷慨解囊", emoji: "🎁")
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "heart.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.pink)
                    .padding(.top, 30)
                
                Text("支持开发者")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("感谢您考虑支持我的工作！您的每一份支持都是我继续开发的动力。")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // 捐赠选项
                VStack(spacing: 15) {
                    ForEach(donationOptions, id: \.amount) { option in
                        Button(action: {
                            // 处理捐赠
                            handleDonation(amount: option.amount)
                        }) {
                            HStack {
                                Text(option.emoji)
                                    .font(.title2)
                                
                                VStack(alignment: .leading) {
                                    Text(option.title)
                                        .font(.headline)
                                    Text("\(option.amount)元")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
                
                Text("您的支持将帮助我持续改进应用，添加新功能。")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("支持开发者")
            .navigationBarItems(trailing: Button("关闭") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func handleDonation(amount: Int) {
        // 调用捐赠管理器进行购买
        donationManager.purchase(amount: amount)

        // 显示感谢提示
        let alert = UIAlertController(title: "感谢支持！", message: "感谢您的慷慨捐赠！您的支持是我继续开发的动力。", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "好的", style: .default))

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(alert, animated: true)
        }
    }
}
