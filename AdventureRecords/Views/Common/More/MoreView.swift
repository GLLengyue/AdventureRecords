import StoreKit
import SwiftUI
import CoreData

struct MoreView: View {
    @Environment(\.managedObjectContext) private var viewContext
    // 状态变量
    @State private var showSettings = false
    @State private var showUserProfile = false
    @State private var showHelpCenter = false
    @State private var showAbout = false
    @State private var showFeedback = false
    @State private var showPrivacyPolicy = false
    @State private var showTermsOfService = false
    @State private var showSubscriptionSheet = false
    @State private var showResetConfirmation = false
    @State private var showDataManagement = false
    @State private var showDataManagerTest = false
    @State private var showAudioManagement = false
    @State private var showClearAudioConfirmation = false
    @State private var showClearAllDataConfirmation = false

    // 应用设置
    @AppStorage("isDarkMode") private var isDarkMode = false
    // @AppStorage("debugMode") private var debugMode = false

    // 订阅管理器
    @StateObject private var subscriptionManager = SubscriptionManager()

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
                // 用户资料部分
                Section {
                    Button(action: { showUserProfile = true }) {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(themeManager.accentColor(for: .character))
                                .padding(.trailing, 10)

                            VStack(alignment: .leading) {
                                Text("用户资料")
                                    .font(.headline)
                                Text("管理您的个人信息和偏好")
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
                    Button(role: .destructive, action: { showClearAudioConfirmation = true }) {
                        MoreMenuRow(icon: "trash",
                                    iconColor: .red,
                                    title: "清除所有音频数据",
                                    subtitle: "删除所有录音文件")
                    }


                    // 设置
                    Button(action: { showSettings = true }) {
                        MoreMenuRow(icon: "gear",
                                    iconColor: themeManager.accentColor(for: .scene),
                                    title: "设置",
                                    subtitle: "应用设置和偏好")
                    }

                    // 订阅
                    Button(action: { showSubscriptionSheet = true }) {
                        MoreMenuRow(icon: "star.circle",
                                    iconColor: .orange,
                                    title: "高级会员",
                                    subtitle: "解锁所有高级功能")
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
        .sheet(isPresented: $showUserProfile) {
            UserProfileView()
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
        .alert("确认清除所有音频数据", isPresented: $showClearAudioConfirmation) {
            Button("清除", role: .destructive) {
                clearAllAudioRecordings()
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("此操作将删除所有录音文件，且无法撤销。确定要继续吗？")
        }
        .sheet(isPresented: $showSubscriptionSheet) {
            SubscriptionView(subscriptionManager: subscriptionManager)
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

extension MoreView {
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

// 用户资料视图
struct UserProfileView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Text("用户资料")
                .navigationTitle("用户资料")
                .navigationBarItems(trailing: Button("完成") {
                    presentationMode.wrappedValue.dismiss()
                })
        }
    }
}

// 帮助中心视图
struct HelpCenterView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Text("帮助中心")
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

    var body: some View {
        NavigationView {
            Text("关于冒险记录")
                .navigationTitle("关于")
                .navigationBarItems(trailing: Button("完成") {
                    presentationMode.wrappedValue.dismiss()
                })
        }
    }
}

// 反馈视图
struct FeedbackView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Text("反馈与建议")
                .navigationTitle("反馈")
                .navigationBarItems(trailing: Button("完成") {
                    presentationMode.wrappedValue.dismiss()
                })
        }
    }
}

// 隐私政策视图
struct PrivacyPolicyView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("隐私政策")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("本隐私政策描述了我们如何收集、使用和分享您的信息。")
                        .font(.body)

                    Text("我们收集的信息")
                        .font(.headline)

                    Text("我们只收集您自愿提供的信息，如角色、笔记和场景等游戏数据。我们不会收集您的个人身份信息。")
                        .font(.body)

                    Text("数据存储")
                        .font(.headline)

                    Text("所有数据都存储在您的设备上，除非您启用了iCloud同步功能。")
                        .font(.body)
                }
                .padding()
            }
            .navigationTitle("隐私政策")
            .navigationBarItems(trailing: Button("完成") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

// 用户协议视图
struct TermsOfServiceView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("用户协议")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("欢迎使用冒险记录应用。通过使用我们的应用，您同意遵守以下条款。")
                        .font(.body)

                    Text("使用条款")
                        .font(.headline)

                    Text("您可以使用我们的应用记录和管理您的角色扮演游戏数据。您不得将应用用于任何非法目的。")
                        .font(.body)

                    Text("知识产权")
                        .font(.headline)

                    Text("本应用及其内容受知识产权法保护。您不得未经授权复制、修改或分发应用的任何部分。")
                        .font(.body)
                }
                .padding()
            }
            .navigationTitle("用户协议")
            .navigationBarItems(trailing: Button("完成") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

// 订阅视图
struct SubscriptionView: View {
    @ObservedObject var subscriptionManager: SubscriptionManager
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "star.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.orange)
                    .padding(.top, 30)

                Text("高级会员")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("解锁所有高级功能，提升您的角色扮演游戏体验")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                VStack(alignment: .leading, spacing: 15) {
                    SubscriptionFeatureRow(icon: "infinity", text: "无限角色和场景")
                    SubscriptionFeatureRow(icon: "icloud.and.arrow.up", text: "自动云备份")
                    SubscriptionFeatureRow(icon: "paintbrush", text: "高级主题和自定义选项")
                    SubscriptionFeatureRow(icon: "square.and.arrow.up", text: "高级导出格式")
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)

                Button(action: {
                    // 订阅实现
                }) {
                    Text("立即订阅")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                Button(action: {
                    // 恢复购买实现
                    subscriptionManager.restorePurchases()
                }) {
                    Text("恢复购买")
                        .foregroundColor(.blue)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("高级会员")
            .navigationBarItems(trailing: Button("关闭") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

// 订阅功能行
struct SubscriptionFeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(.orange)
                .font(.system(size: 22))

            Text(text)
                .font(.body)

            Spacer()
        }
    }
}

// 订阅管理器
class SubscriptionManager: ObservableObject {
    @Published var isSubscribed = false

    func restorePurchases() {
        // 实现恢复购买功能
        print("恢复购买")
    }
}
