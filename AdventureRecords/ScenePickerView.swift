import SwiftUI

struct ScenePickerView: View {
    @Binding var selectedScenes: [UUID]
    let availableScenes: [AdventureScene]
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(availableScenes) { scene in
                    Button(action: {
                        if selectedScenes.contains(scene.id) {
                            selectedScenes.removeAll(where: { $0 == scene.id })
                        } else {
                            selectedScenes.append(scene.id)
                        }
                    }) {
                        HStack {
                            Text(scene.title)
                            Spacer()
                            if selectedScenes.contains(scene.id) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("选择场景")
            .toolbar {
                Button("完成") {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    ScenePickerView(selectedScenes: .constant([]), availableScenes: [])
}