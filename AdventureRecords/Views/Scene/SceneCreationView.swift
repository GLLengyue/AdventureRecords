import SwiftUI

struct SceneCreationView: View {
    @State private var title: String = ""
    @State private var description: String = ""
    @Environment(\.dismiss) var dismiss
    var onSave: (AdventureScene) -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("场景名称", text: $title)
                TextEditor(text: $description)
                    .frame(height: 120)
            }
            .navigationTitle("创建新场景")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        let newScene = AdventureScene(
                            id: UUID(),
                            title: title,
                            description: description,
                            relatedNoteIDs: []
                        )
                        onSave(newScene)
                    }
                    .disabled(title.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
            }
        }
    }
}