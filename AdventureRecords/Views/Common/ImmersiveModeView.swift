//  ImmersiveModeView.swift
//  AdventureRecords
//  沉浸模式视图
import SwiftUI

struct ImmersiveModeView: View {
    @Environment(\.dismiss) var dismiss
    var content: String
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            VStack {
                ScrollView {
                    Text(content)
                        .font(.title2)
                        .padding()
                }
                Spacer()
                Button("退出沉浸模式") {
                    dismiss()
                }
                .padding()
            }
        }
    }
}

#Preview {
    ImmersiveModeView(content: "沉浸模式示例内容")
}
