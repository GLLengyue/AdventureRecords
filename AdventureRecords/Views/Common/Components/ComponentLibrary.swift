//
//  ComponentLibrary.swift
//  AdventureRecords
//
//  Created by Trae AI on 2025/5/15.
//

import SwiftUI

/// 组件库入口文件
/// 这个文件导出所有组件，方便在应用中使用

// 重新导出所有组件，使其可以通过单一导入使用

/// 组件库版本信息
enum ComponentLibrary {
    static let version = "1.0.0"
    static let description = "AdventureRecords 基础组件库"

    /// 打印组件库信息
    static func printInfo() {
        print("\(description) v\(version)")
        print("包含主题系统、按钮组件、卡片组件、输入组件和布局组件")
    }
}
