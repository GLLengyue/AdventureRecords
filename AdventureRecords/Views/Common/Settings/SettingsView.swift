import SwiftUI

struct SettingsView: View {
    // MARK: - 状态变量
    
    @Environment(\.colorScheme) private var systemColorScheme
    @AppStorage("isDarkMode") private var isDarkMode = UITraitCollection.current.userInterfaceStyle == .dark
    @State private var isFirstAppear = true
    @AppStorage("fontSize") private var fontSize: Double = 14
    @AppStorage("language") private var language = "简体中文"
    @AppStorage("recordingQuality") private var recordingQuality = "标准"

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
            .onAppear {
                // 只在视图首次出现时同步一次系统主题
                if isFirstAppear {
                    isDarkMode = systemColorScheme == .dark
                    isFirstAppear = false
                }
            }
            .onChange(of: systemColorScheme) {
                // 当系统主题变化时更新应用主题
                isDarkMode = systemColorScheme == .dark
            }

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

                    // VStack(alignment: .leading, spacing: 8) {
                    //     Text("字体大小: \(Int(fontSize))")
                    //     Slider(value: $fontSize, in: 12 ... 24, step: 1) {
                    //         Text("\(Int(fontSize))")
                    //     } minimumValueLabel: {
                    //         Text("12").font(.caption)
                    //     } maximumValueLabel: {
                    //         Text("24").font(.caption)
                    //     }
                    //     .accentColor(themeManager.accentColor(for: .character))
                    // }
                    // .padding(.vertical, 4)

                    // Picker("语言", selection: $language) {
                    //     Text("简体中文").tag("简体中文")
                    //     Text("English").tag("English")
                    // }
                }

            }
            .listStyle(InsetGroupedListStyle())
        }
        .background(themeManager.backgroundColor.edgesIgnoringSafeArea(.all))

    }
}
