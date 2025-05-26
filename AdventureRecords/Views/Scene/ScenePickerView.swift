import SwiftUI

struct ScenePickerView: View {
    @Binding var selectedSceneIDs: [UUID]
    @Environment(\.dismiss) var dismiss

    // 使用单例
    @StateObject private var viewModel = SceneViewModel.shared

    var body: some View {
        NavigationStack {
            List(viewModel.scenes) { scene in
                HStack {
                    Text(scene.title)
                    Spacer()
                    if selectedSceneIDs.contains(scene.id) {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if let index = selectedSceneIDs.firstIndex(of: scene.id) {
                        selectedSceneIDs.remove(at: index)
                    } else {
                        selectedSceneIDs.append(scene.id)
                    }
                }
            }
            .navigationTitle("选择场景")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}
