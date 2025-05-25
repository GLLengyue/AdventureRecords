import SwiftUI
import UniformTypeIdentifiers
import UIKit

// 分享Sheet视图
struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct DataManagementView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var showBackupSheet = false
    @State private var showRestoreSheet = false
    @State private var showExportSheet = false
    @State private var showDataCleanupSheet = false
    @State private var showCleanupConfirmation = false
    @State private var cleanupType: CleanupType = .none
    @State private var exportType: ExportType = .none
    @State private var isExporting = false
    @State private var exportDocument: ExportDocument?
    @State private var isBackingUp = false
    @State private var isRestoring = false
    @State private var backupDate = Date()
    @State private var showBackupSuccess = false
    @State private var showRestoreSuccess = false
    @State private var showBackupError = false
    @State private var showRestoreError = false
    @State private var showShareSheet = false
    @State private var backups: [BackupFile] = []
    
    let themeManager = ThemeManager.shared
    let coreDataManager = CoreDataManager.shared
    
    var body: some View {
        NavigationView {
            List {
                // 备份与恢复部分
                Section(header: Text("备份与恢复")) {
                    Button(action: { showBackupSheet = true }) {
                        DataManagementRow(
                            icon: "arrow.down.doc",
                            iconColor: themeManager.accentColor(for: .character),
                            title: "创建备份",
                            subtitle: "将所有数据备份到本地文件"
                        )
                    }
                    
                    Button(action: { showRestoreSheet = true }) {
                        DataManagementRow(
                            icon: "arrow.up.doc",
                            iconColor: themeManager.accentColor(for: .scene),
                            title: "从备份恢复",
                            subtitle: "从备份文件恢复所有数据"
                        )
                    }
                }
                
                // 数据导出部分
                Section(header: Text("数据导出")) {
                    Button(action: {
                        exportType = .pdf
                    }) {
                        DataManagementRow(
                            icon: "doc.richtext",
                            iconColor: .red,
                            title: "导出为PDF",
                            subtitle: "包含角色、场景和笔记信息"
                        )
                    }
                    
                    Button(action: {
                        exportType = .text
                    }) {
                        DataManagementRow(
                            icon: "doc.text",
                            iconColor: .gray,
                            title: "导出为纯文本",
                            subtitle: "适合分享给其他人"
                        )
                    }
                    
                    Button(action: {
                        exportType = .json
                    }) {
                        DataManagementRow(
                            icon: "curlybraces",
                            iconColor: .blue,
                            title: "导出为JSON",
                            subtitle: "便于与其他应用交互"
                        )
                    }
                }
                
                // 数据清理部分
                Section(header: Text("数据清理")) {
                    Button(action: {
                        cleanupType = .all
                    }) {
                        DataManagementRow(
                            icon: "trash",
                            iconColor: .red,
                            title: "清理所有数据",
                            subtitle: "删除所有角色、场景和笔记数据"
                        )
                    }
                    
                    Button(action: {
                        cleanupType = .character
                    }) {
                        DataManagementRow(
                            icon: "person.crop.circle.fill",
                            iconColor: themeManager.accentColor(for: .character),
                            title: "清理角色数据",
                            subtitle: "仅删除角色相关数据"
                        )
                    }
                    
                    Button(action: {
                        cleanupType = .scene
                    }) {
                        DataManagementRow(
                            icon: "theatermasks.circle.fill",
                            iconColor: themeManager.accentColor(for: .scene),
                            title: "清理场景数据",
                            subtitle: "仅删除场景相关数据"
                        )
                    }
                    
                    Button(action: {
                        cleanupType = .note
                    }) {
                        DataManagementRow(
                            icon: "note.text",
                            iconColor: themeManager.accentColor(for: .note),
                            title: "清理笔记数据",
                            subtitle: "仅删除笔记相关数据"
                        )
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("数据管理")
            .navigationBarItems(trailing: Button("完成") {
                presentationMode.wrappedValue.dismiss()
            })
            .onAppear {
                // 加载备份列表
                backups = coreDataManager.getAllBackups()
            }
            .onChange(of: exportType) {
                // 当导出类型改变时，延迟一点显示导出表单，确保视图已更新
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.016) {
                    showExportSheet = true
                }
            }
            .onChange(of: cleanupType) {
                if cleanupType != .none {
                    // 当清理类型改变时，延迟一点显示确认对话框，确保视图已更新
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.016) {
                        showCleanupConfirmation = true
                    }
                }
            }
            .sheet(isPresented: $showBackupSheet) {
                BackupView(
                    isBackingUp: $isBackingUp,
                    backupDate: $backupDate,
                    showSuccess: $showBackupSuccess,
                    showError: $showBackupError
                )
            }
            .sheet(isPresented: $showRestoreSheet) {
                RestoreView(
                    isRestoring: $isRestoring,
                    showSuccess: $showRestoreSuccess,
                    showError: $showRestoreError
                )
            }
            .sheet(isPresented: $showExportSheet) {
                ExportView(exportType: exportType)
            }
            .alert(
                "确认数据清理",
                isPresented: $showCleanupConfirmation
            ) {
                Button("清理", role: .destructive) {
                    performCleanup(type: cleanupType)
                    cleanupType = .none
                    showCleanupConfirmation = false
                }
                Button("取消", role: .cancel) {
                    cleanupType = .none
                    showCleanupConfirmation = false
                }
            } message: {
                Text("您确定要清理\(cleanupTypeText)吗？此操作不可撤销。")
            }
            .alert("备份成功", isPresented: $showBackupSuccess) {
                Button("确定") {}
            } message: {
                Text("数据已成功备份至本地文件。")
            }
            .alert("恢复成功", isPresented: $showRestoreSuccess) {
                Button("确定") {}
            } message: {
                Text("数据已成功从备份文件恢复。重启以应用更改。")
            }
            .alert("备份失败", isPresented: $showBackupError) {
                Button("确定") {}
            } message: {
                Text("备份数据时发生错误，请重试。")
            }
            .alert("恢复失败", isPresented: $showRestoreError) {
                Button("确定") {}
            } message: {
                Text("从备份文件恢复数据时发生错误，请检查文件是否有效。")
            }
        }
    }
    
    var cleanupTypeText: String {
        switch cleanupType {
        case .all:
            return "所有数据"
        case .character:
            return "角色数据"
        case .scene:
            return "场景数据"
        case .note:
            return "笔记数据"
        case .none:
            return ""
        }
    }
    
    func performCleanup(type: CleanupType) {
        // 实现数据清理逻辑
        print("清理\(cleanupTypeText)")
        
        // 调用DataManager进行数据清理
        let success = coreDataManager.cleanupData(type: type)
        
        if success {
            print("\(cleanupTypeText)清理成功")
        } else {
            print("\(cleanupTypeText)清理失败")
        }
    }
}

// 数据管理行组件
struct DataManagementRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(iconColor)
                .frame(width: 32, height: 32)
                .padding(.trailing, 10)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

// 备份视图
struct BackupView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var isBackingUp: Bool
    @Binding var backupDate: Date
    @Binding var showSuccess: Bool
    @Binding var showError: Bool
    @State private var backupName = ""
    @State private var showShareSheet = false
    @State private var backupData: Data?
    
    let coreDataManager = CoreDataManager.shared
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("备份信息")) {
                    TextField("备份名称", text: $backupName)
                        .autocapitalization(.none)
                    
                    DatePicker("备份日期", selection: $backupDate, displayedComponents: .date)
                }
                
                Section(footer: Text("备份将保存所有角色、场景和笔记数据。")) {
                    Button(action: {
                        createBackup()
                    }) {
                        HStack {
                            Spacer()
                            
                            if isBackingUp {
                                ProgressView()
                                    .padding(.trailing, 10)
                            }
                            
                            Text("创建备份")
                                .fontWeight(.semibold)
                            
                            Spacer()
                        }
                    }
                    .disabled(backupName.isEmpty || isBackingUp)
                }
            }
            .navigationTitle("创建备份")
            .navigationBarItems(trailing: Button("取消") {
                presentationMode.wrappedValue.dismiss()
            }
            .sheet(isPresented: $showShareSheet) {
                if let backupData = backupData {
                    ShareSheet(activityItems: [backupData])
                }
            })
        }
    }
    
    // State variables are already declared at the top of the view
    
    func createBackup() {
        isBackingUp = true
        
        // 调用DataManager创建备份
        DispatchQueue.global(qos: .userInitiated).async {
            if let backupData = coreDataManager.createBackup(name: backupName, date: backupDate) {
                // 备份成功，保存数据以便分享
                DispatchQueue.main.async {
                    self.backupData = backupData
                    isBackingUp = false
                    showSuccess = true
                    showShareSheet = true
                }
            } else {
                // 备份失败
                DispatchQueue.main.async {
                    isBackingUp = false
                    showError = true
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}

// 恢复视图
struct RestoreView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var isRestoring: Bool
    @Binding var showSuccess: Bool
    @Binding var showError: Bool
    @State private var selectedBackup: BackupFile?
    @State private var backups: [BackupFile] = []
    @State private var showDocumentPicker = false
    
    let coreDataManager = CoreDataManager.shared
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("选择备份文件")) {
                    Button(action: {
                        showDocumentPicker = true
                    }) {
                        HStack {
                            Image(systemName: "folder")
                                .foregroundColor(.blue)
                            Text("从文件中选择")
                        }
                    }
                }
                
                Section(header: Text("最近备份")) {
                    if backups.isEmpty {
                        Text("没有找到备份文件")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(backups) { backup in
                            Button(action: {
                                selectedBackup = backup
                            }) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(backup.name)
                                            .font(.headline)
                                        Text(backup.formattedDate)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    if selectedBackup?.id == backup.id {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                    }
                }
                
                Section(footer: Text("恢复将覆盖当前所有数据，请确保您已备份重要信息。")) {
                    Button(action: {
                        restoreFromBackup()
                    }) {
                        HStack {
                            Spacer()
                            
                            if isRestoring {
                                ProgressView()
                                    .padding(.trailing, 10)
                            }
                            
                            Text("恢复数据")
                                .fontWeight(.semibold)
                            
                            Spacer()
                        }
                    }
                    .disabled(selectedBackup == nil || isRestoring)
                }
            }
            .navigationTitle("从备份恢复")
            .navigationBarItems(trailing: Button("取消") {
                presentationMode.wrappedValue.dismiss()
            })
            .onAppear {
                // 加载备份文件列表
                backups = coreDataManager.getAllBackups()
            }
            .sheet(isPresented: $showDocumentPicker) {
                DocumentPicker(completion: { url in
                    // 处理选择的文件
                    handleSelectedFile(url: url)
                })
            }
        }
    }
    
    func restoreFromBackup() {
        guard let backup = selectedBackup else { return }
        
        isRestoring = true
        
        // 调用DataManager恢复备份
        DispatchQueue.global(qos: .userInitiated).async {
            let success = coreDataManager.restoreFromBackup(backup)
            
            DispatchQueue.main.async {
                isRestoring = false
                
                if success {
                    showSuccess = true
                } else {
                    showError = true
                }
                
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    func handleSelectedFile(url: URL) {
        // 检查文件是否是有效的备份文件
        if url.pathExtension == "adrbackup" {
            // 创建临时备份文件对象
            let tempBackup = BackupFile(
                url: url,
                name: url.deletingPathExtension().lastPathComponent,
                creationDate: Date()
            )
            
            // 设置为选中的备份
            selectedBackup = tempBackup
        }
    }
}

// 文档选择器
struct DocumentPicker: UIViewControllerRepresentable {
    var completion: (URL) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.data], asCopy: true)
        picker.allowsMultipleSelection = false
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            parent.completion(url)
        }
    }
}

// 导出视图
struct ExportView: View {
    @Environment(\.presentationMode) var presentationMode
    let exportType: ExportType
    @State private var isExporting = false
    @State private var includeCharacters = true
    @State private var includeScenes = true
    @State private var includeNotes = true
    @State private var exportDocument: ExportDocument?
    @State private var showShareSheet = false
    
    let coreDataManager = CoreDataManager.shared
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("导出内容")) {
                    Toggle("包含角色", isOn: $includeCharacters)
                    Toggle("包含场景", isOn: $includeScenes)
                    Toggle("包含笔记", isOn: $includeNotes)
                }
                
                Section(header: Text("导出格式")) {
                    HStack {
                        Image(systemName: exportType.iconName)
                            .foregroundColor(exportType.color)
                        Text(exportType.description)
                    }
                }
                
                Section(footer: Text("导出可能需要一些时间，具体取决于数据量。")) {
                    Button(action: {
                        exportData()
                    }) {
                        HStack {
                            Spacer()
                            
                            if isExporting {
                                ProgressView()
                                    .padding(.trailing, 10)
                            }
                            
                            Text("导出数据")
                                .fontWeight(.semibold)
                            
                            Spacer()
                        }
                    }
                    .disabled(!includeCharacters && !includeScenes && !includeNotes || isExporting)
                }
            }
            .navigationTitle("导出数据")
            .navigationBarItems(trailing: Button("取消") {
                presentationMode.wrappedValue.dismiss()
            })
            .sheet(isPresented: $showShareSheet) {
                if let document = exportDocument {
                    ShareSheet(activityItems: [document.data])
                }
            }
        }
    }
    
    func exportData() {
        isExporting = true
        
        // 调用DataManager导出数据
        DispatchQueue.global(qos: .userInitiated).async {
            let document = coreDataManager.exportData(
                type: exportType,
                includeCharacters: includeCharacters,
                includeScenes: includeScenes,
                includeNotes: includeNotes
            )
            
            DispatchQueue.main.async {
                isExporting = false
                
                if let doc = document {
                    exportDocument = doc
                    showShareSheet = true
                } else {
                    // 导出失败处理
                    print("导出失败")
                }
            }
        }
    }
}

// 分享表单
// struct ShareSheet: UIViewControllerRepresentable {
//     var items: [Any]
    
//     func makeUIViewController(context: Context) -> UIActivityViewController {
//         let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
//         return controller
//     }
    
//     func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
//     }
// }
