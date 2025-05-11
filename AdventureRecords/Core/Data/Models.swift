//  Models.swift
//  AdventureRecords
//  核心数据模型定义

import Foundation

// 三向链接引用类型
enum LinkTarget: Hashable {
    case character(UUID)
    case note(UUID)
    case scene(UUID)
}
