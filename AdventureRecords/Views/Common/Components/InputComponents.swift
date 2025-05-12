//
//  InputComponents.swift
//  AdventureRecords
//
//  Created by Trae AI on 2025/5/15.
//

import SwiftUI

/// 模块化文本输入框
public struct ModuleTextField: View {
    let title: String
    let module: ModuleType
    @Binding var text: String
    var placeholder: String = ""
    var isMultiline: Bool = false
    var maxHeight: CGFloat? = nil
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(ThemeManager.shared.accentColor(for: module))
            
            if isMultiline {
                ZStack(alignment: .topLeading) {
                    if text.isEmpty {
                        Text(placeholder)
                            .foregroundColor(ThemeManager.shared.secondaryTextColor.opacity(0.5))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 12)
                    }
                    
                    TextEditor(text: $text)
                        .frame(minHeight: 100, maxHeight: maxHeight)
                        .padding(4)
                        .background(ThemeManager.shared.backgroundColor)
                        .cornerRadius(8)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(ThemeManager.shared.accentColor(for: module), lineWidth: 1)
                )
            } else {
                TextField(placeholder, text: $text)
                    .padding(12)
                    .background(ThemeManager.shared.backgroundColor)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(ThemeManager.shared.accentColor(for: module), lineWidth: 1)
                    )
            }
        }
    }
}

/// 模块化选择器
public struct ModulePicker<T: Hashable>: View {
    let title: String
    let module: ModuleType
    let options: [T]
    @Binding var selection: T
    let labelForOption: (T) -> String
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(ThemeManager.shared.accentColor(for: module))
            
            Picker(title, selection: $selection) {
                ForEach(options, id: \.self) { option in
                    Text(labelForOption(option))
                        .tag(option)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding(12)
            .background(ThemeManager.shared.backgroundColor)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(ThemeManager.shared.accentColor(for: module), lineWidth: 1)
            )
        }
    }
}

/// 关联选择器组件
public struct RelationshipSelector<T: Identifiable>: View {
    let title: String
    let module: ModuleType
    let items: [T]
    @Binding var selectedItemIDs: [T.ID]
    let itemLabel: (T) -> String
    let itemIcon: String
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(ThemeManager.shared.accentColor(for: module))
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(items) { item in
                        let isSelected = selectedItemIDs.contains(where: { $0 as? UUID == item.id as? UUID })
                        
                        Button(action: {
                            toggleSelection(item.id)
                        }) {
                            HStack {
                                Image(systemName: itemIcon)
                                    .font(.caption)
                                Text(itemLabel(item))
                                    .font(.caption)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(isSelected ? 
                                          ThemeManager.shared.accentColor(for: module) : 
                                          ThemeManager.shared.accentColor(for: module).opacity(0.1))
                            )
                            .foregroundColor(isSelected ? .white : ThemeManager.shared.accentColor(for: module))
                        }
                    }
                }
            }
            .frame(height: 40)
        }
    }
    
    private func toggleSelection(_ id: T.ID) {
        if let index = selectedItemIDs.firstIndex(where: { $0 as? UUID == id as? UUID }) {
            selectedItemIDs.remove(at: index)
        } else {
            selectedItemIDs.append(id)
        }
    }
}

/// 日期选择器组件
public struct ModuleDatePicker: View {
    let title: String
    let module: ModuleType
    @Binding var date: Date
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(ThemeManager.shared.accentColor(for: module))
            
            DatePicker("", selection: $date, displayedComponents: [.date, .hourAndMinute])
                .datePickerStyle(CompactDatePickerStyle())
                .labelsHidden()
                .padding(12)
                .background(ThemeManager.shared.backgroundColor)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(ThemeManager.shared.accentColor(for: module), lineWidth: 1)
                )
        }
    }
}

/// 预览
struct InputComponents_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State private var text = ""
        @State private var multilineText = ""
        @State private var selectedOption = "选项1"
        @State private var selectedDate = Date()
        @State private var selectedIDs: [UUID] = []
        
        let options = ["选项1", "选项2", "选项3"]
        
        struct PreviewItem: Identifiable {
            let id: UUID
            let name: String
        }
        
        let items = [
            PreviewItem(id: UUID(), name: "角色1"),
            PreviewItem(id: UUID(), name: "角色2"),
            PreviewItem(id: UUID(), name: "角色3")
        ]
        
        var body: some View {
            ScrollView {
                VStack(spacing: 20) {
                    ModuleTextField(title: "角色名称", module: .character, text: $text, placeholder: "请输入角色名称")
                    
                    ModuleTextField(title: "笔记内容", module: .note, text: $multilineText, placeholder: "请输入笔记内容", isMultiline: true)
                    
                    ModulePicker(title: "选择选项", module: .scene, options: options, selection: $selectedOption) { option in
                        return option
                    }
                    
                    ModuleDatePicker(title: "选择日期", module: .note, date: $selectedDate)
                    
                    RelationshipSelector(
                        title: "关联角色", 
                        module: .note, 
                        items: items, 
                        selectedItemIDs: $selectedIDs,
                        itemLabel: { $0.name },
                        itemIcon: "person"
                    )
                }
                .padding()
            }
        }
    }
    
    static var previews: some View {
        PreviewWrapper()
    }
}