//
//  ButtonStyles.swift
//  AdventureRecords
//
//  Created by Trae AI on 2025/5/15.
//

import SwiftUI

/// 模块化按钮样式，根据不同模块应用不同的视觉风格
public struct ModuleButton: View {
    public let title: String
    public let module: ModuleType
    public let action: () -> Void
    public var icon: String? = nil
    public var isProminent: Bool = false
    public var size: ButtonSize = .medium
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(size.iconFont)
                }
                
                Text(title)
                    .font(size.textFont)
            }
            .padding(size.padding)
            .frame(height: size.height)
            .frame(maxWidth: size.maxWidth ? .infinity : nil)
            .foregroundColor(isProminent ? .white : ThemeManager.shared.accentColor(for: module))
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isProminent ? ThemeManager.shared.accentColor(for: module) : ThemeManager.shared.accentColor(for: module).opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(ThemeManager.shared.accentColor(for: module), lineWidth: isProminent ? 0 : 1)
            )
        }
    }
}

/// 按钮尺寸枚举
public enum ButtonSize {
    case small
    case medium
    case large
    
    public var padding: EdgeInsets {
        switch self {
        case .small: return EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
        case .medium: return EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        case .large: return EdgeInsets(top: 12, leading: 24, bottom: 12, trailing: 24)
        }
    }
    
    public var height: CGFloat {
        switch self {
        case .small: return 28
        case .medium: return 44
        case .large: return 56
        }
    }
    
    public var maxWidth: Bool {
        switch self {
        case .large: return true
        default: return false
        }
    }
    
    public var textFont: Font {
        switch self {
        case .small: return .caption
        case .medium: return .body
        case .large: return .headline
        }
    }
    
    public var iconFont: Font {
        switch self {
        case .small: return .caption
        case .medium: return .body
        case .large: return .title3
        }
    }
}

/// 图标按钮
public struct IconButton: View {
    public let icon: String
    public let module: ModuleType
    public let action: () -> Void
    public var size: CGFloat = 44
    public var isProminent: Bool = false
    
    public var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size / 2.5))
                .frame(width: size, height: size)
                .foregroundColor(isProminent ? .white : ThemeManager.shared.accentColor(for: module))
                .background(
                    Circle()
                        .fill(isProminent ? ThemeManager.shared.accentColor(for: module) : ThemeManager.shared.accentColor(for: module).opacity(0.1))
                )
        }
    }
}

/// 标签按钮（用于底部标签栏）
public struct TabButton: View {
    public let title: String
    public let icon: String
    public let module: ModuleType
    public let isSelected: Bool
    public let action: () -> Void
    
    public var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                Text(title)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .foregroundColor(isSelected ? ThemeManager.shared.accentColor(for: module) : ThemeManager.shared.secondaryTextColor)
        }
    }
}

/// 预览
struct ButtonStyles_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            ModuleButton(title: "角色卡按钮", module: .character, action: {})
            ModuleButton(title: "笔记块按钮", module: .note, action: {}, icon: "note.text")
            ModuleButton(title: "场景按钮", module: .scene, action: {}, isProminent: true)
            
            HStack {
                IconButton(icon: "plus", module: .character, action: {})
                IconButton(icon: "trash", module: .note, action: {}, isProminent: true)
                IconButton(icon: "pencil", module: .scene, action: {})
            }
            
            HStack {
                TabButton(title: "角色卡", icon: "person.3", module: .character, isSelected: true, action: {})
                TabButton(title: "笔记块", icon: "note.text", module: .note, isSelected: false, action: {})
                TabButton(title: "场景", icon: "map", module: .scene, isSelected: false, action: {})
            }
        }
        .padding()
    }
}