//  ImmersiveModeView.swift
//  AdventureRecords
//  沉浸模式视图
import SwiftUI

enum ImmersiveContent {
    case character(Character)
    case note(NoteBlock)
    case scene(AdventureScene)
}

struct ImmersiveModeView: View {
    @Environment(\.dismiss) var dismiss
    let content: ImmersiveContent
    @State private var showControls = true

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景
                Color.black.ignoresSafeArea()

                // 内容区域
                ScrollView {
                    VStack(spacing: 20) {
                        switch content {
                        case let .character(card):
                            characterContent(card)
                        case let .note(note):
                            noteContent(note)
                        case let .scene(scene):
                            sceneContent(scene)
                        }
                    }
                    .padding()
                }

                // 控制栏
                if showControls {
                    VStack {
                        Spacer()
                        HStack {
                            Button(action: { dismiss() }) {
                                Image(systemName: "xmark.circle.fill")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.white)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color.black.opacity(0.5))
                    }
                }
            }
            .onTapGesture {
                withAnimation {
                    showControls.toggle()
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func characterContent(_ card: Character) -> some View {
        VStack(spacing: 20) {
            if let avatar = card.avatar {
                Image(uiImage: avatar)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 200)
                    .clipShape(Circle())
            }
            Text(card.name)
                .font(.largeTitle)
                .bold()
                .foregroundColor(.white)
            Text(card.description)
                .font(.body)
                .foregroundColor(.white)
        }
    }

    private func noteContent(_ note: NoteBlock) -> some View {
        VStack(spacing: 20) {
            Text(note.title)
                .font(.largeTitle)
                .bold()
                .foregroundColor(.white)
            Text(note.content)
                .font(.body)
                .foregroundColor(.white)
        }
    }

    private func sceneContent(_ scene: AdventureScene) -> some View {
        VStack(spacing: 20) {
            if let coverImage = scene.coverImage {
                Image(uiImage: coverImage)
                    .resizable()
                    .scaledToFit()
            }
            Text(scene.title)
                .font(.largeTitle)
                .bold()
                .foregroundColor(.white)
            Text(scene.description)
                .font(.body)
                .foregroundColor(.white)
        }
    }
}
