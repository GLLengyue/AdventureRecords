import SwiftUI

struct SettingsView: View {
    // MARK: - 状态变量

    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("fontSize") private var fontSize: Double = 14
    @AppStorage("language") private var language = "简体中文"
    @AppStorage("recordingQuality") private var recordingQuality = "标准"
    @AppStorage("iCloudSync") private var iCloudSync = true
    @AppStorage("syncFrequency") private var syncFrequency = "自动"

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
                        Slider(value: $fontSize, in: 12 ... 24, step: 1) {
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

                // MARK: - 2. 云同步

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

    }
}