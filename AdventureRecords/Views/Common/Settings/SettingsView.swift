import SwiftUI

struct SettingsView: View {
    // MARK: - 状态变量
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("fontSize") private var fontSize: Double = 14
    @AppStorage("language") private var language = "简体中文"
    @AppStorage("recordingQuality") private var recordingQuality = "标准"
    @AppStorage("defaultRecordingNameFormat") private var defaultRecordingNameFormat = "录音 %date%"
    @AppStorage("iCloudSync") private var iCloudSync = true
    @AppStorage("syncFrequency") private var syncFrequency = "自动"
    
    // 数据管理相关
    @State private var showBackupConfirmation = false
    @State private var showRestoreConfirmation = false
    @State private var showExportOptions = false
    @State private var showClearDataConfirmation = false
    
    // 环境变量
    @Environment(\.presentationMode) var presentationMode
    
    // 主题管理器
    private let themeManager = ThemeManager.shared
    
    var body: some View {
        VStack {
            HStack {
                Text("设置")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.leading)
                Spacer()
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("完成")
                        .foregroundColor(themeManager.accentColor(for: .character))
                }
                .padding(.trailing)
            }
            .padding(.top)
            
            List {
                // MARK: - 1. 应用设置
                Section(header: Text("应用设置").foregroundColor(themeManager.secondaryTextColor)) {
                    Toggle("深色模式", isOn: $isDarkMode)
                        .toggleStyle(SwitchToggleStyle(tint: themeManager.accentColor(for: .character)))
                    
                    Picker("主题外观", selection: $isDarkMode) {
                        Text("浅色").tag(false)
                        Text("深色").tag(true)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("字体大小: \(Int(fontSize))")
                        Slider(value: $fontSize, in: 12...24, step: 1) {
                            Text("\(Int(fontSize))")
                        } minimumValueLabel: {
                            Text("12").font(.caption)
                        } maximumValueLabel: {
                            Text("24").font(.caption)
                        }
                        .accentColor(themeManager.accentColor(for: .character))
                    }
                    .padding(.vertical, 4)
                    
                    Picker("语言", selection: $language) {
                        Text("简体中文").tag("简体中文")
                        Text("English").tag("English")
                    }
                }
                
                // MARK: - 2. 数据管理
                Section(header: Text("数据管理").foregroundColor(themeManager.secondaryTextColor)) {
                    Button(action: { showBackupConfirmation = true }) {
                        Label("备份数据", systemImage: "arrow.up.doc")
                            .foregroundColor(themeManager.primaryTextColor)
                    }
                    
                    Button(action: { showRestoreConfirmation = true }) {
                        Label("恢复数据", systemImage: "arrow.down.doc")
                            .foregroundColor(themeManager.primaryTextColor)
                    }
                    
                    Button(action: { showExportOptions = true }) {
                        Label("导出数据", systemImage: "square.and.arrow.up")
                            .foregroundColor(themeManager.primaryTextColor)
                    }
                    
                    Button(action: { showClearDataConfirmation = true }) {
                        Label("清理数据", systemImage: "trash")
                            .foregroundColor(.red)
                    }
                }
                
                // MARK: - 3. 音频设置
                Section(header: Text("音频设置").foregroundColor(themeManager.secondaryTextColor)) {
                    Picker("录音质量", selection: $recordingQuality) {
                        Text("低").tag("低")
                        Text("标准").tag("标准")
                        Text("高").tag("高")
                    }
                    
                    TextField("默认录音命名格式", text: $defaultRecordingNameFormat)
                        .font(.system(size: CGFloat(fontSize)))
                        .padding(.vertical, 4)
                    
                    HStack {
                        Text("音频播放速度")
                        Spacer()
                        Text("1.0x") // 这里可以根据实际需要调整
                    }
                }
                
                // MARK: - 4. 云同步
                Section(header: Text("云同步").foregroundColor(themeManager.secondaryTextColor)) {
                    Toggle("启用iCloud同步", isOn: $iCloudSync)
                        .toggleStyle(SwitchToggleStyle(tint: themeManager.accentColor(for: .character)))
                    
                    if iCloudSync {
                        Picker("同步频率", selection: $syncFrequency) {
                            Text("自动").tag("自动")
                            Text("每小时").tag("每小时")
                            Text("每天").tag("每天")
                            Text("手动").tag("手动")
                        }
                        
                        Button(action: {
                            // 手动同步实现
                        }) {
                            Label("立即同步", systemImage: "arrow.clockwise")
                                .foregroundColor(themeManager.accentColor(for: .character))
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
        .background(themeManager.backgroundColor.edgesIgnoringSafeArea(.all))
        // MARK: - 确认对话框和表单
        .alert(isPresented: $showBackupConfirmation) {
            Alert(
                title: Text("备份数据"),
                message: Text("确定要备份所有数据吗？这将覆盖之前的备份。"),
                primaryButton: .default(Text("确定")) {
                    // 备份数据实现
                },
                secondaryButton: .cancel(Text("取消"))
            )
        }
        .alert(isPresented: $showRestoreConfirmation) {
            Alert(
                title: Text("恢复数据"),
                message: Text("确定要从备份中恢复数据吗？这将覆盖当前的所有数据。"),
                primaryButton: .destructive(Text("确定")) {
                    // 恢复数据实现
                },
                secondaryButton: .cancel(Text("取消"))
            )
        }
        .alert(isPresented: $showClearDataConfirmation) {
            Alert(
                title: Text("清理数据"),
                message: Text("确定要清理所有数据吗？此操作不可撤销。"),
                primaryButton: .destructive(Text("清理")) {
                    // 清理数据实现
                },
                secondaryButton: .cancel(Text("取消"))
            )
        }
        .sheet(isPresented: $showExportOptions) {
            ExportOptionsView()
        }
    }
}

// MARK: - 辅助视图
struct ExportOptionsView: View {
    @Environment(\.presentationMode) var presentationMode
    private let themeManager = ThemeManager.shared
    
    var body: some View {
        NavigationView {
            List {
                Button(action: {
                    // 导出为PDF
                }) {
                    Label("导出为PDF", systemImage: "doc.richtext")
                        .foregroundColor(themeManager.primaryTextColor)
                }
                
                Button(action: {
                    // 导出为文本
                }) {
                    Label("导出为文本", systemImage: "doc.text")
                        .foregroundColor(themeManager.primaryTextColor)
                }
                
                Button(action: {
                    // 导出为JSON
                }) {
                    Label("导出为JSON", systemImage: "doc.badge.gearshape")
                        .foregroundColor(themeManager.primaryTextColor)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("导出选项")
            .navigationBarItems(trailing: Button("完成") {
                presentationMode.wrappedValue.dismiss()
            })
            .background(themeManager.backgroundColor.edgesIgnoringSafeArea(.all))
        }
    }
}