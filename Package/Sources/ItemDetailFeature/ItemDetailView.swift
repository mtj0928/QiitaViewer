import APIClient
import Database
import MarkdownUI
import SwiftUI

public struct ItemDetailView: View {

    @State var viewModel: ItemDetailViewModel
    @State var isShowingDeleteConfirmationAlert = false

    public init(viewModel: ItemDetailViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        ScrollView {
            Markdown(viewModel.item.body)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .markdownTheme(.gitHub)
                .padding()
        }
        .background(content: {
            // GitHubの背景色
            Color(light: .white, dark: Color(rgba: 0x1819_1dff))
        })
        .toolbar {
            if viewModel.downloadedItem {
                Button(
                    action: {
                        isShowingDeleteConfirmationAlert = true
                    },
                    label: {
                        Image(systemName: "checkmark.circle.fill")
                    }
                )
            } else {
                Button(
                    action: {
                        Task {
                            await viewModel.save()
                        }
                    },
                    label: {
                        Image(systemName: "arrow.down.circle")
                    }
                )
            }
        }
        .contentMargins(.bottom, 60, for: .scrollContent)
        .navigationTitle(viewModel.item.title)
        .toolbarTitleDisplayMode(.inline)
        .alert("この記事を端末から削除しますか？", isPresented: $isShowingDeleteConfirmationAlert) {
            Button("削除する", role: .destructive) {
                Task {
                    await viewModel.delete()
                }
            }
            Button("キャンセル", role: .cancel) {
                isShowingDeleteConfirmationAlert = true
            }
        }
    }
}

struct ItemDetailView_Previews: PreviewProvider {
    static var previews: some View {
        TabView {
            NavigationStack {
                ItemDetailView(
                    viewModel: ItemDetailViewModel(
                        item: .dummy,
                        useCase: ItemDetailUseCase(container: .mock)
                    )
                )
            }
            .tabItem { Label("探す", systemImage: "magnifyingglass") }
        }
    }
}

