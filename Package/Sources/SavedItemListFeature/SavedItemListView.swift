import Core
import Database
import ItemDetailFeature
import SwiftData
import SwiftUI
import ViewComponents

public struct SavedItemListView: View {
    @State private var path = NavigationPath()
    @Query private var items: [ItemModel]
    @Environment(\.modelContext) private var context

    public init() {}

    public var body: some View {
        NavigationStack(path: $path) {
            List {
                ForEach(items.map(Item.init)) { item in
                    Button {
                        path.append(item)
                    } label: {
                        ItemListCell(item: item)
                    }
                    .foregroundStyle(Color.primary)
                }
                .onDelete { indexSet in
                    indexSet.map { items[$0] }
                        .forEach { item in
                            context.delete(item)
                        }
                    try? context.save()
                }
            }
            .overlay {
                if items.isEmpty {
                    Text("保存済みの記事はありません")
                        .foregroundStyle(.secondary)
                }
            }
            .listStyle(.plain)
            .navigationTitle("保存済み")
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
        }
    }
}

struct SavedItemListView_Previews: PreviewProvider {
    static var previews: some View {
        let container: ModelContainer = .mock
        let user = UserModel(.dummy)
        container.mainContext.insert(user)
        let item = ItemModel(
            id: "dummy id",
            title: "title",
            body: "body",
            createdAt: .now,
            commentsCount: 0,
            likesCount: 10,
            user: user,
            url: URL(string: "https://example.com")!
        )
        container.mainContext.insert(item)
        return TabView {
            SavedItemListView()
                .tabItem {
                    Image(systemName: "tray.and.arrow.down")
                    Text("保存済み")
                }
        }
        .modelContext(container.mainContext)
    }
}
