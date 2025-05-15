//
//  CardComponents.swift
//  AdventureRecords
//
//  Created by Trae AI on 2025/5/15.
//

import SwiftUI

/// 通用卡片组件，支持不同模块的样式
public struct ModuleCardView<Content: View>: View {
    let module: ModuleType
    let content: Content
    var hasShadow: Bool = true
    var cornerRadius: CGFloat = 12
    
    init(module: ModuleType, hasShadow: Bool = true, cornerRadius: CGFloat = 12, @ViewBuilder content: () -> Content) {
        self.module = module
        self.hasShadow = hasShadow
        self.cornerRadius = cornerRadius
        self.content = content()
    }
    
    public var body: some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(ThemeManager.shared.secondaryBackgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(ThemeManager.shared.accentColor(for: module), lineWidth: 1.5)
            )
            .shadow(color: hasShadow ? Color.black.opacity(0.1) : Color.clear, radius: 5, x: 0, y: 2)
    }
}

/// 角色卡片组件
public struct CharacterView: View {
    let name: String
    let description: String
    var avatar: UIImage? = nil
    var onTap: () -> Void = {}
    
    public var body: some View {
        ModuleCardView(module: .character) {
            Button(action: onTap) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        if let avatar = avatar {
                            Image(uiImage: avatar)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(ThemeManager.shared.characterAccentColor, lineWidth: 2))
                        } else {
                            Image(systemName: "person.crop.circle")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(ThemeManager.shared.characterAccentColor)
                        }
                        
                        VStack(alignment: .leading) {
                            Text(name)
                                .font(.headline)
                                .foregroundColor(ThemeManager.shared.primaryTextColor)
                            
                            Text(description)
                                .font(.subheadline)
                                .foregroundColor(ThemeManager.shared.secondaryTextColor)
                                .lineLimit(2)
                        }
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

/// 笔记块卡片组件
public struct NoteCardView: View {
    let title: String
    let content: String
    let date: Date
    var onTap: () -> Void = {}
    
    public var body: some View {
        ModuleCardView(module: .note) {
            Button(action: onTap) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(ThemeManager.shared.primaryTextColor)
                    
                    Text(content)
                        .font(.body)
                        .foregroundColor(ThemeManager.shared.secondaryTextColor)
                        .lineLimit(3)
                    
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(ThemeManager.shared.noteAccentColor)
                        Text(date, style: .date)
                            .font(.caption)
                            .foregroundColor(ThemeManager.shared.secondaryTextColor)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

/// 场景卡片组件
public struct SceneCardView: View {
    let title: String
    let description: String
    var image: UIImage? = nil
    var onTap: () -> Void = {}
    
    public var body: some View {
        ModuleCardView(module: .scene) {
            Button(action: onTap) {
                VStack(alignment: .leading, spacing: 8) {
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 120)
                            .frame(maxWidth: .infinity)
                            .clipped()
                            .cornerRadius(8)
                    } else {
                        Rectangle()
                            .fill(ThemeManager.shared.sceneAccentColor.opacity(0.2))
                            .frame(height: 80)
                            .frame(maxWidth: .infinity)
                            .cornerRadius(8)
                            .overlay(
                                Image(systemName: "map")
                                    .font(.largeTitle)
                                    .foregroundColor(ThemeManager.shared.sceneAccentColor)
                            )
                    }
                    
                    Text(title)
                        .font(.headline)
                        .foregroundColor(ThemeManager.shared.primaryTextColor)
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(ThemeManager.shared.secondaryTextColor)
                        .lineLimit(2)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

/// 标签组件
public struct TagView: View {
    let text: String
    let module: ModuleType
    
    public var body: some View {
        Text(text)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(ThemeManager.shared.accentColor(for: module).opacity(0.2))
            )
            .foregroundColor(ThemeManager.shared.accentColor(for: module))
    }
}