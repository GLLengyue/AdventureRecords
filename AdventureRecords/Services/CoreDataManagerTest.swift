import Foundation
import CoreData
import SwiftUI

// 这是一个测试文件，用于验证CoreDataManager的导入和使用
class CoreDataManagerTest {
    func testCoreDataManager() {
        let manager = CoreDataManager.shared
        let context = manager.viewContext
        print("成功获取CoreDataManager和viewContext")
    }
}
