import SwiftUI

struct ImmersiveEditorView: View {
    @Binding var isPresented: Bool
    @Binding var content: String
    var title: String? = nil // 可选的标题，用于指示当前编辑的内容

    @Environment(\.colorScheme) var colorScheme
    @State private var showingControls = true // 控制退出按钮的显示

    var body: some View {
        NavigationView {
            ZStack(alignment: .topTrailing) {
                // 使用 ScrollView + TextEditor 来确保长文本可以滚动和编辑
                ScrollView {
                    TextEditor(text: $content)
                        .font(.system(size: 18, design: .serif)) // 优化阅读的字体
                        .lineSpacing(8)
                        .padding()
                        .frame(minHeight: UIScreen.main.bounds.height) // 确保 TextEditor 至少和屏幕一样高
                }
                .background(backgroundColor)
                .edgesIgnoringSafeArea(.all) // 占据整个屏幕
                .navigationBarHidden(true) // 隐藏导航栏
                .statusBar(hidden: true) // 隐藏状态栏
                .onTapGesture {
                    // 点击非文本区域时，切换控制按钮的显示状态
                    withAnimation {
                        showingControls.toggle()
                    }
                }

                if showingControls {
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .padding()
                            .foregroundColor(foregroundColor.opacity(0.7))
                    }
                    .padding(.top, 20) // 避免与刘海区域过于接近
                    .padding(.trailing, 20)
                    .transition(.opacity.combined(with: .scale))
                }

                if let displayTitle = title, showingControls {
                    Text(displayTitle)
                        .font(.caption)
                        .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                        .background(Color.black.opacity(0.5))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.top, 25)
                        .transition(.opacity)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle()) // 避免 iPad 上的侧边栏
        .onChange(of: content) {
            // 可以在这里实现自动保存逻辑，如果需要的话
            // debugPrint("Content changed, auto-save triggered.")
        }
    }

    private var backgroundColor: Color {
        colorScheme == .dark ? Color.black : Color.white
    }

    private var foregroundColor: Color {
        colorScheme == .dark ? Color.white : Color.black
    }
}
