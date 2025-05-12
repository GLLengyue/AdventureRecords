//
//  ThemeManager.swift
//  AdventureRecords
//
//  Created by Trae AI on 2025/5/15.
//

import SwiftUI
import UIKit

/// 主题管理器，负责管理应用的颜色方案和主题设置
public class ThemeManager: ObservableObject {
    public static let shared = ThemeManager()
    
    // MARK: - 颜色方案
    
    // 主色调
    public let primaryColor = Color("PrimaryColor")
    
    // 模块强调色
    public let characterAccentColor = Color.purple
    public let noteAccentColor = Color.green
    public let sceneAccentColor = Color.blue
    
    // 功能色
    public let successColor = Color.green
    public let warningColor = Color.yellow
    public let errorColor = Color.red
    public let infoColor = Color.blue
    
    // 背景色
    @Published public var backgroundColor = Color(UIColor.systemBackground)
    @Published public var secondaryBackgroundColor = Color(UIColor.secondarySystemBackground)
    
    // 文本色
    @Published public var primaryTextColor = Color(UIColor.label)
    @Published public var secondaryTextColor = Color(UIColor.secondaryLabel)
    
    // MARK: - 主题模式
    @Published public var isDarkMode: Bool = false {
        didSet {
            updateColorScheme()
        }
    }
    
    private init() {
        // 初始化时检测系统当前的外观模式
        if UITraitCollection.current.userInterfaceStyle == .dark {
            isDarkMode = true
        }
        updateColorScheme()
    }
    
    /// 更新颜色方案
    private func updateColorScheme() {
        if isDarkMode {
            backgroundColor = Color(UIColor.systemBackground)
            secondaryBackgroundColor = Color(UIColor.secondarySystemBackground)
            primaryTextColor = Color(UIColor.label)
            secondaryTextColor = Color(UIColor.secondaryLabel)
        } else {
            backgroundColor = Color(UIColor.systemBackground)
            secondaryBackgroundColor = Color(UIColor.secondarySystemBackground)
            primaryTextColor = Color(UIColor.label)
            secondaryTextColor = Color(UIColor.secondaryLabel)
        }
    }
    
    /// 切换暗色/亮色模式
    public func toggleDarkMode() {
        isDarkMode.toggle()
    }
    
    /// 根据模块类型获取强调色
    public func accentColor(for module: ModuleType) -> Color {
        switch module {
        case .character:
            return characterAccentColor
        case .note:
            return noteAccentColor
        case .scene:
            return sceneAccentColor
        }
    }
}

/// 模块类型枚举
public enum ModuleType {
    case character
    case note
    case scene
}

/// 主题相关的视图修饰符
extension View {
    /// 应用模块强调色
    func moduleAccent(_ module: ModuleType) -> some View {
        self.accentColor(ThemeManager.shared.accentColor(for: module))
    }
    
    /// 应用模块主题（包括强调色和其他相关样式）
    func moduleTheme(_ module: ModuleType) -> some View {
        self
            .accentColor(ThemeManager.shared.accentColor(for: module))
            // 可以在这里添加更多与模块相关的样式
    }
}