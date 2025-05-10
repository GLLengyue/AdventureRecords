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
    NoteBlockDetailView(noteBlock: DataModule.notes[0])
}