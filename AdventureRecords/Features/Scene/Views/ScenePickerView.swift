import SwiftUI

struct ScenePickerView: View {
    @Binding var selectedSceneIDs: [UUID]
    @StateObject private var viewModel = SceneViewModel()
    @Environment(\.dismiss) var dismiss
    
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
            .onAppear {
                viewModel.loadScenes()
            }
        }
    }
}


#Preview {
    ScenePickerView(selectedSceneIDs: .constant([]))
}
