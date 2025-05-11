import SwiftUI

struct NoteBlockDetailView: View {
    let noteBlock: NoteBlock
    @State private var showEditor = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(noteBlock.title)
                .font(.largeTitle)
                .bold()

            Text(noteBlock.content)
                .font(.body)

            Button(action: {
                showEditor = true
            }) {
                Label("编辑笔记", systemImage: "square.and.pencil")
            }
            .buttonStyle(.bordered)
            .controlSize(.large)

            Spacer()
        }
        .padding()
        .navigationTitle("笔记详情")
        .sheet(isPresented: $showEditor) {
            NoteEditorView(note: noteBlock)
        }
    }
}

#Preview {
    NoteBlockDetailView(noteBlock: NoteBlock(id: UUID(), title: "测试笔记", content: "这是测试笔记的内容", relatedCharacterIDs: [], relatedSceneIDs: [], date: Date()))
}