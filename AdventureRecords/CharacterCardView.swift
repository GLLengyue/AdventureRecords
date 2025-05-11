//  CharacterCardView.swift
//  AdventureRecords
//  角色卡列表视图
import SwiftUI

struct CharacterCardView: View {
    @State private var characterCards: [CharacterCard] = DataModule.characterCards
    @State private var selectedCard: CharacterCard?
    @State private var showDetail = false
    @State private var showEditor = false
    @State private var isCreatingNew = false
    @State private var showDeleteAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(characterCards, id: \.id) { card in
                    Button(action: {
                        selectedCard = card
                        showDetail = true
                    }) {
                        HStack {
                            if let avatar = card.avatar {
                                Image(uiImage: avatar)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.crop.circle")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                            }
                            VStack(alignment: .leading) {
                                Text(card.name).font(.headline)
                                Text(card.description).font(.subheadline).foregroundColor(.secondary)
                            }
                        }
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            selectedCard = card
                            showDeleteAlert = true
                        } label: {
                            Label("删除", systemImage: "trash")
                        }
                        
                        Button {
                            selectedCard = card
                            isCreatingNew = false
                            showEditor = true
                        } label: {
                            Label("编辑", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
                }
            }
            .navigationTitle("角色卡")
            .toolbar {
                Button(action: {
                    isCreatingNew = true
                    showEditor = true
                }) {
                    Label("新建角色", systemImage: "plus")
                }
            }
            .onChange(of: selectedCard) {
                if selectedCard != nil {
                    showDetail = true
                }
            }
            .sheet(isPresented: $showDetail) {
                if let card = selectedCard {
                    CharacterDetailView(card: card)
                }
            }
            .sheet(isPresented: $showEditor) {
                if isCreatingNew {
                    CharacterEditorView(onSave: { newCard in
                        characterCards.append(newCard)
                        showEditor = false
                    }, onCancel: {
                        showEditor = false
                    })
                } else if let index = characterCards.firstIndex(where: { $0.id == selectedCard?.id }) {
                    CharacterEditorView(card: characterCards[index], onSave: { updatedCard in
                        characterCards[index] = updatedCard
                        showEditor = false
                    }, onCancel: {
                        showEditor = false
                    })
                }
            }
            .alert("确认删除", isPresented: $showDeleteAlert) {
                Button("取消", role: .cancel) {}
                Button("删除", role: .destructive) {
                    if let selectedCard = selectedCard, let index = characterCards.firstIndex(where: { $0.id == selectedCard.id }) {
                        characterCards.remove(at: index)
                    }
                }
            } message: {
                Text("确定要删除角色 \(selectedCard?.name ?? "") 吗？此操作无法撤销。")
            }
        }
    }
}

#Preview {
    CharacterCardView()
}
