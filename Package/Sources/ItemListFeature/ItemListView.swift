import Core
import ItemDetailFeature
import SwiftUI
import ViewComponents

public struct ItemListView: View {
    @State private var path = NavigationPath()
    @State private var viewModel: ItemListViewModel

    public init(viewModel: ItemListViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        NavigationStack(path: $path) {
            List {
                if !viewModel.items.isEmpty {
                    ForEach(viewModel.items) { item in
                        Button {
                            path.append(item)
                        } label: {
                            ItemListCell(item: item)
                        }
                        .foregroundStyle(Color.primary)
                    }
                } else if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }
            }
            .overlay {
                if viewModel.items.isEmpty && !viewModel.isLoading {
                    Text("記事がありません")
                        .font(.footnote)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowBackground(Color.clear)
                        .foregroundStyle(.secondary)
                        .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)
            .refreshable {
                try? await viewModel.reload()
            }
            .navigationDestination(for: Item.self) { item in
                DependencyProvider { dependency in
                    ItemDetailView(
                        viewModel: ItemDetailViewModel(
                            item: item,
                            useCase: ItemDetailUseCase(container: dependency.container)
                        )
                    )
                }
            }
            .searchable(text: $viewModel.searchText)
            .onSubmit(of: .search) {
                Task {
                    try? await viewModel.reload()
                }
            }
            .navigationTitle("探す")
        }
        .task {
            if viewModel.items.isEmpty {
                try? await viewModel.reload()
            }
        }
    }
}

struct ItemListView_Previews: PreviewProvider {
    static var previews: some View {
        ItemListView(
            viewModel: ItemListViewModel(apiClient: { () -> MockAPIClient in
                var mock = MockAPIClient.mock
                mock.getItemsHandler = { _ in
                    Bool.random() ? [.dummy] : []
                }
                return mock
            }())
        )
    }
}
