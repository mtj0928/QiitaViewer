import Core
import CoreData
import Database
import ItemDetailFeature
import SwiftUI
import ViewComponents

public struct SavedItemListView: View {

    @State private var path = NavigationPath()

    @FetchRequest<ItemModel>(
        entity: ItemModel.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \ItemModel.insertedAt, ascending: true)]
    ) private var items

    @Environment(\.managedObjectContext) private var context

    public init() {}

    public var body: some View {
        NavigationStack(path: $path) {
            List {
                ForEach(items) { itemModel in
                    let item = Item(itemModel)
                    let _ = itemModel.id
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
        let container: NSPersistentContainer = .mock
        let user = UserModel(.dummy, context: container.viewContext)
        container.viewContext.insert(user)

        let item = ItemModel(context: container.viewContext)
        item.itemID = "dummy id"
        item.title = "ダミータイトル"
        item.body = "本文"
        item.createdAt = .now
        item.commentsCount = 0
        item.likesCount = 10
        item.user =  user
        item.url = URL(string: "https://example.com")!
        container.viewContext.insert(item)

        return TabView {
            SavedItemListView()
                .tabItem {
                    Image(systemName: "tray.and.arrow.down")
                    Text("保存済み")
                }
        }
        .environment(\.managedObjectContext, container.viewContext)
        .tint(.green)
    }
}
