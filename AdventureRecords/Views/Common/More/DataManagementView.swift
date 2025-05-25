import SwiftUI
import UniformTypeIdentifiers
import UIKit

// 清理类型枚举
enum CleanupType {
    case all
    case character
    case scene
    case note
}

// 导出类型枚举
enum ExportType {
    case pdf
    case text
    case json
    
    var description: String {
        switch self {
        case .pdf:
            return "PDF文档 (.pdf)"
        case .text:
            return "纯文本文件 (.txt)"
        case .json:
            return "JSON文件 (.json)"
        }
    }
    
    var iconName: String {
        switch self {
        case .pdf:
            return "doc.richtext"
        case .text:
            return "doc.text"
        case .json:
            return "curlybraces"
        }
    }
    
    var color: Color {
        switch self {
        case .pdf:
            return .red
        case .text:
            return .gray
        case .json:
            return .blue
        }
    }
    
    var utType: UTType {
        switch self {
        case .pdf:
            return .pdf
        case .text:
            return .plainText
        case .json:
            return .json
        }
    }
}

// 导出文档结构
struct ExportDocument {
    let data: Data
    let filename: String
    let contentType: UTType
}

struct DataManagementView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var showBackupSheet = false
    @State private var showRestoreSheet = false
    @State private var showExportSheet = false
    @State private var showDataCleanupSheet = false
    @State private var showCleanupConfirmation = false
    @State private var cleanupType: CleanupType = .all
    @State private var exportType: ExportType = .pdf
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
    let dataManager = DataManager.shared
    
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
                        showExportSheet = true
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
                        showExportSheet = true
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
                        showExportSheet = true
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
                        showCleanupConfirmation = true
                    }) {
                        DataManagementRow(
                            icon: "trash",
                            iconColor: .red,
                            title: "清理所有数据",
                            subtitle: "删除所有角色、场景和笔记"
                        )
                    }
                    
                    Button(action: {
                        cleanupType = .character
                        showCleanupConfirmation = true
                    }) {
                        DataManagementRow(
                            icon: "person.crop.circle.badge.minus",
                            iconColor: themeManager.accentColor(for: .character),
                            title: "清理角色数据",
                            subtitle: "仅删除角色相关数据"
                        )
                    }
                    
                    Button(action: {
                        cleanupType = .scene
                        showCleanupConfirmation = true
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
                        showCleanupConfirmation = true
                    }) {
                        DataManagementRow(
                            icon: "note.text.badge.minus",
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
                backups = dataManager.getAllBackups()
            }
            .sheet(isPresented: $showBackupSheet) {
                BackupView(isBackingUp: $isBackingUp, backupDate: $backupDate, showSuccess: $showBackupSuccess, showError: $showBackupError)
            }
            .sheet(isPresented: $showRestoreSheet) {
                RestoreView(isRestoring: $isRestoring, showSuccess: $showRestoreSuccess, showError: $showRestoreError)
            }
            .sheet(isPresented: $showExportSheet) {
                ExportView(exportType: exportType)
            }
            .alert(isPresented: $showCleanupConfirmation) {
                Alert(
                    title: Text("确认数据清理"),
                    message: Text("您确定要清理\(cleanupTypeText)吗？此操作不可撤销。"),
                    primaryButton: .destructive(Text("清理")) {
                        performCleanup(type: cleanupType)
                    },
                    secondaryButton: .cancel(Text("取消"))
                )
            }
            .alert(isPresented: $showBackupSuccess) {
                Alert(
                    title: Text("备份成功"),
                    message: Text("数据已成功备份至本地文件。"),
                    dismissButton: .default(Text("确定"))
                )
            }
            .alert(isPresented: $showRestoreSuccess) {
                Alert(
                    title: Text("恢复成功"),
                    message: Text("数据已成功从备份文件恢复。"),
                    dismissButton: .default(Text("确定"))
                )
            }
            .alert(isPresented: $showBackupError) {
                Alert(
                    title: Text("备份失败"),
                    message: Text("备份数据时发生错误，请重试。"),
                    dismissButton: .default(Text("确定"))
                )
            }
            .alert(isPresented: $showRestoreError) {
                Alert(
                    title: Text("恢复失败"),
                    message: Text("从备份文件恢复数据时发生错误，请检查文件是否有效。"),
                    dismissButton: .default(Text("确定"))
                )
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
        }
    }
    
    func performCleanup(type: CleanupType) {
        // 实现数据清理逻辑
        print("清理\(cleanupTypeText)")
        
        // 调用DataManager进行数据清理
        let success = dataManager.cleanupData(type: type)
        
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
    
    let dataManager = DataManager.shared
    
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
            })
        }
    }
    
    func createBackup() {
        isBackingUp = true
        
        // 调用DataManager创建备份
        DispatchQueue.global(qos: .userInitiated).async {
            let success = dataManager.createBackup(name: backupName, date: backupDate)
            
            DispatchQueue.main.async {
                isBackingUp = false
                
                if success {
                    showSuccess = true
                } else {
                    showError = true
                }
                
                presentationMode.wrappedValue.dismiss()
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
    
    let dataManager = DataManager.shared
    
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
                backups = dataManager.getAllBackups()
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
            let success = dataManager.restoreFromBackup(backupFile: backup.url)
            
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
    
    let dataManager = DataManager.shared
    
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
                    ShareSheet(items: [document.data])
                }
            }
        }
    }
    
    func exportData() {
        isExporting = true
        
        // 调用DataManager导出数据
        DispatchQueue.global(qos: .userInitiated).async {
            let document = dataManager.exportData(
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
struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
    }
}
