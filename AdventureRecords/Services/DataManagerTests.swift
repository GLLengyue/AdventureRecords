import CoreData
import Foundation
import SwiftUI
import UniformTypeIdentifiers

/// 数据管理器测试类
/// 用于测试CoreDataManager的各项功能，确保数据备份、恢复、导出和清理功能正常工作
class DataManagerTests {
    // 单例实例
    static let shared = DataManagerTests()

    // 数据管理器实例
    private let coreDataManager = CoreDataManager.shared

    // 测试数据
    private var testCharacterData: CharacterData!
    private var testSceneData: SceneData!
    private var testNoteData: NoteData!

    // 测试文件路径
    private var testBackupFilePath: URL?

    // 私有初始化方法
    private init() {
        // 初始化测试数据
        setupTestData()
    }

    // 初始化测试数据
    private func setupTestData() {
        testCharacterData = CharacterData(id: "test-character-id", name: "测试角色", description: "这是一个用于测试的角色",
                                          avatar: nil, tags: [], relatedNoteIDs: [])
        testSceneData = SceneData(id: "test-scene-id", name: "测试场景", description: "这是一个用于测试的场景", tags: [],
                                  relatedNoteIDs: [])
        testNoteData = NoteData(id: "test-note-id", title: "测试笔记", content: "这是一个用于测试的笔记内容", tags: [],
                                relatedCharacterIDs: [], relatedSceneIDs: [])
    }

    // MARK: - 测试入口方法

    /// 运行所有测试
    func runAllTests() -> [TestResult] {
        var results = [TestResult]()

        // 使用异常捕获来运行每个测试
        // 确保即使某个测试失败，其他测试仍然能够运行
        do {
            // 测试备份功能
            results.append(testBackupCreation())
        } catch {
            results.append(TestResult(name: "备份创建测试", passed: false,
                                      message: "测试过程中发生异常: \(error.localizedDescription)"))
        }

        do {
            // 测试恢复功能
            results.append(testBackupRestoration())
        } catch {
            results.append(TestResult(name: "备份恢复测试", passed: false,
                                      message: "测试过程中发生异常: \(error.localizedDescription)"))
        }

        // 测试导出功能
        do {
            results.append(testDataExportPDF())
        } catch {
            results.append(TestResult(name: "PDF导出测试", passed: false,
                                      message: "测试过程中发生异常: \(error.localizedDescription)"))
        }

        do {
            results.append(testDataExportText())
        } catch {
            results.append(TestResult(name: "文本导出测试", passed: false,
                                      message: "测试过程中发生异常: \(error.localizedDescription)"))
        }

        do {
            results.append(testDataExportJSON())
        } catch {
            results.append(TestResult(name: "JSON导出测试", passed: false,
                                      message: "测试过程中发生异常: \(error.localizedDescription)"))
        }

        // 测试清理功能
        do {
            results.append(testDataCleanupAll())
        } catch {
            results.append(TestResult(name: "清理所有数据测试", passed: false,
                                      message: "测试过程中发生异常: \(error.localizedDescription)"))
        }

        do {
            results.append(testDataCleanupCharacter())
        } catch {
            results.append(TestResult(name: "清理角色数据测试", passed: false,
                                      message: "测试过程中发生异常: \(error.localizedDescription)"))
        }

        do {
            results.append(testDataCleanupScene())
        } catch {
            results.append(TestResult(name: "清理场景数据测试", passed: false,
                                      message: "测试过程中发生异常: \(error.localizedDescription)"))
        }

        do {
            results.append(testDataCleanupNote())
        } catch {
            results.append(TestResult(name: "清理笔记数据测试", passed: false,
                                      message: "测试过程中发生异常: \(error.localizedDescription)"))
        }

        // 清理测试文件
        cleanupTestFiles()

        return results
    }

    // MARK: - 备份测试

    /// 测试创建备份
    private func testBackupCreation() -> TestResult {
        let testName = "备份创建测试"

        do {
            // 创建测试备份
            let backupData = coreDataManager.createBackup(name: "测试备份", date: Date())

            // 检查备份是否成功
            if backupData != nil {
                // 获取所有备份
                let backups = coreDataManager.getAllBackups()

                // 检查是否有备份文件
                if !backups.isEmpty {
                    // 保存测试备份文件路径，用于后续测试
                    testBackupFilePath = backups.first?.url

                    return TestResult(name: testName, passed: true, message: "成功创建备份文件")
                } else {
                    return TestResult(name: testName, passed: false, message: "备份创建成功，但未找到备份文件")
                }
            } else {
                return TestResult(name: testName, passed: false, message: "备份创建失败")
            }
        } catch {
            return TestResult(name: testName, passed: false, message: "备份创建过程中发生错误: \(error.localizedDescription)")
        }
    }

    /// 测试从备份恢复
    private func testBackupRestoration() -> TestResult {
        let testName = "备份恢复测试"

        // 检查是否有测试备份文件
        guard let backupFilePath = testBackupFilePath else {
            return TestResult(name: testName, passed: false, message: "没有可用的测试备份文件")
        }

        do {
            // 从备份恢复
            let success = coreDataManager.restoreFromBackup(BackupFile(url: backupFilePath, name: "测试备份",
                                                                       creationDate: Date()))

            // 检查恢复是否成功
            if success {
                return TestResult(name: testName, passed: true, message: "成功从备份文件恢复数据")
            } else {
                return TestResult(name: testName, passed: false, message: "从备份恢复失败")
            }
        } catch {
            return TestResult(name: testName, passed: false, message: "从备份恢复过程中发生错误: \(error.localizedDescription)")
        }
    }

    // MARK: - 导出测试

    /// 测试导出PDF
    private func testDataExportPDF() -> TestResult {
        let testName = "PDF导出测试"

        // 导出PDF
        if let exportDoc = coreDataManager.exportData(type: .pdf, includeCharacters: true, includeScenes: true,
                                                      includeNotes: true)
        {
            // 检查导出文档
            if exportDoc.data.count > 0 && exportDoc.filename.hasSuffix(".pdf") {
                return TestResult(name: testName, passed: true, message: "成功导出PDF文档，大小: \(exportDoc.data.count) 字节")
            } else {
                return TestResult(name: testName, passed: false, message: "导出的PDF文档无效")
            }
        } else {
            return TestResult(name: testName, passed: false, message: "PDF导出失败")
        }
    }

    /// 测试导出文本
    private func testDataExportText() -> TestResult {
        let testName = "文本导出测试"

        // 导出文本
        if let exportDoc = coreDataManager.exportData(type: .text, includeCharacters: true, includeScenes: true,
                                                      includeNotes: true)
        {
            // 检查导出文档
            if exportDoc.data.count > 0 && exportDoc.filename.hasSuffix(".txt") {
                // 尝试将数据转换为字符串
                if let content = String(data: exportDoc.data, encoding: .utf8), !content.isEmpty {
                    return TestResult(name: testName, passed: true, message: "成功导出文本文档，大小: \(exportDoc.data.count) 字节")
                } else {
                    return TestResult(name: testName, passed: false, message: "导出的文本内容无效")
                }
            } else {
                return TestResult(name: testName, passed: false, message: "导出的文本文档无效")
            }
        } else {
            return TestResult(name: testName, passed: false, message: "文本导出失败")
        }
    }

    /// 测试导出JSON
    private func testDataExportJSON() -> TestResult {
        let testName = "JSON导出测试"

        // 导出JSON
        if let exportDoc = coreDataManager.exportData(type: .json, includeCharacters: true, includeScenes: true,
                                                      includeNotes: true)
        {
            // 检查导出文档
            if exportDoc.data.count > 0 && exportDoc.filename.hasSuffix(".json") {
                // 尝试解析JSON
                do {
                    if let _ = try JSONSerialization.jsonObject(with: exportDoc.data, options: []) as? [String: Any] {
                        return TestResult(name: testName, passed: true,
                                          message: "成功导出JSON文档，大小: \(exportDoc.data.count) 字节")
                    } else {
                        return TestResult(name: testName, passed: false, message: "导出的JSON内容无效")
                    }
                } catch {
                    return TestResult(name: testName, passed: false,
                                      message: "无法解析导出的JSON: \(error.localizedDescription)")
                }
            } else {
                return TestResult(name: testName, passed: false, message: "导出的JSON文档无效")
            }
        } else {
            return TestResult(name: testName, passed: false, message: "JSON导出失败")
        }
    }

    // MARK: - 清理测试

    /// 测试清理所有数据
    private func testDataCleanupAll() -> TestResult {
        let testName = "清理所有数据测试"

        // 清理所有数据
        let success = coreDataManager.cleanupData(type: .all)

        // 检查清理是否成功
        if success {
            return TestResult(name: testName, passed: true, message: "成功清理所有数据")
        } else {
            return TestResult(name: testName, passed: false, message: "清理所有数据失败")
        }
    }

    /// 测试清理角色数据
    private func testDataCleanupCharacter() -> TestResult {
        let testName = "清理角色数据测试"

        // 清理角色数据
        let success = coreDataManager.cleanupData(type: .character)

        // 检查清理是否成功
        if success {
            return TestResult(name: testName, passed: true, message: "成功清理角色数据")
        } else {
            return TestResult(name: testName, passed: false, message: "清理角色数据失败")
        }
    }

    /// 测试清理场景数据
    private func testDataCleanupScene() -> TestResult {
        let testName = "清理场景数据测试"

        // 清理场景数据
        let success = coreDataManager.cleanupData(type: .scene)

        // 检查清理是否成功
        if success {
            return TestResult(name: testName, passed: true, message: "成功清理场景数据")
        } else {
            return TestResult(name: testName, passed: false, message: "清理场景数据失败")
        }
    }

    /// 测试清理笔记数据
    private func testDataCleanupNote() -> TestResult {
        let testName = "清理笔记数据测试"

        // 清理笔记数据
        let success = coreDataManager.cleanupData(type: .note)

        // 检查清理是否成功
        if success {
            return TestResult(name: testName, passed: true, message: "成功清理笔记数据")
        } else {
            return TestResult(name: testName, passed: false, message: "清理笔记数据失败")
        }
    }

    // MARK: - 辅助方法

    /// 清理测试文件
    private func cleanupTestFiles() {
        // 清理测试备份文件
        if let backupFilePath = testBackupFilePath {
            do {
                try FileManager.default.removeItem(at: backupFilePath)
                print("已清理测试备份文件: \(backupFilePath.path)")
            } catch {
                print("清理测试备份文件失败: \(error.localizedDescription)")
            }
        }
    }
}

/// 测试结果结构体
struct TestResult {
    let name: String
    let passed: Bool
    let message: String
    let timestamp: Date

    init(name: String, passed: Bool, message: String) {
        self.name = name
        self.passed = passed
        self.message = message
        self.timestamp = Date()
    }
}

/// 测试运行器
/// 用于运行数据管理器测试并显示结果
class DataManagerTestRunner {
    static func runTests() -> [TestResult] {
        print("开始运行数据管理器测试...")

        // 运行所有测试
        let results = DataManagerTests.shared.runAllTests()

        // 打印测试结果
        printTestResults(results)

        return results
    }

    static func printTestResults(_ results: [TestResult]) {
        print("\n===== 数据管理器测试结果 =====")

        // 计算通过和失败的测试数量
        let passedTests = results.filter { $0.passed }.count
        let failedTests = results.count - passedTests

        print("总测试数: \(results.count)")
        print("通过测试: \(passedTests)")
        print("失败测试: \(failedTests)")
        print("通过率: \(Double(passedTests) / Double(results.count) * 100)%")

        // 打印详细结果
        print("\n详细测试结果:")
        for (index, result) in results.enumerated() {
            let status = result.passed ? "✅ 通过" : "❌ 失败"
            print("\(index + 1). \(result.name): \(status)")
            print("   消息: \(result.message)")

            // 如果是最后一个结果，不打印分隔线
            if index < results.count - 1 {
                print("   -------------------")
            }
        }

        print("\n===== 测试结束 =====")
    }
}
