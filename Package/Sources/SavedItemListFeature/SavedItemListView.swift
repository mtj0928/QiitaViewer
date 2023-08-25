import Core
import CoreData
import Database
import ItemDetailFeature
import SwiftUI
import UIKit
import ViewComponents

public struct SavedItemListNavigationView: View {

    private let viewModel: SaveItemListViewModel
    @State var path: [Item] = []

    public init(viewModel: SaveItemListViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationStack(path: $path) {
            SavedItemListView(viewModel: viewModel) { item in
                path.append(item)
            }
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

public struct SavedItemListView: UIViewControllerRepresentable {
    private let viewModel: SaveItemListViewModel
    private let didTapItem: (Item) -> Void

    public init(viewModel: SaveItemListViewModel, didTapItem: @escaping (Item) -> Void) {
        self.viewModel = viewModel
        self.didTapItem = didTapItem
    }

    public func makeUIViewController(context: Context) -> some UIViewController {
        SavedItemListViewController(viewModel: viewModel, didTapItem: didTapItem)
    }

    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
}

public final class SavedItemListViewController: UIViewController {
    private let viewModel: SaveItemListViewModel
    private let didTapItem: (Item) -> Void

    private lazy var dataSource: UICollectionViewDiffableDataSource<Int, Item> = makeDataSource()

    private let collectionView: UICollectionView = {
        let configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()

    public init(viewModel: SaveItemListViewModel, didTapItem: @escaping (Item) -> Void) {
        self.viewModel = viewModel
        self.didTapItem = didTapItem

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        collectionView.dataSource = dataSource
        collectionView.delegate = self

        reload()
        observeViewModel()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.indexPathsForSelectedItems?
            .forEach { index in
                collectionView.deselectItem(at: index, animated: animated)
            }
    }

    private func observeViewModel() {
        _ = withObservationTracking {
            viewModel.items
        } onChange: { [weak self] in
            Task { @MainActor [weak self] in
                self?.reload()
                self?.observeViewModel()
            }
        }
    }

    private func makeDataSource() -> UICollectionViewDiffableDataSource<Int, Item> {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Item> { cell, indexPath, item in
            cell.contentConfiguration = UIHostingConfiguration {
                ItemListCell(item: item)
            }
        }
        let dataSource: UICollectionViewDiffableDataSource<Int, Item> = UICollectionViewDiffableDataSource(
            collectionView: collectionView
        ) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
        return dataSource
    }

    private func reload() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Item>()
        snapshot.appendSections([0])
        snapshot.appendItems(viewModel.items, toSection: 0)
        dataSource.apply(snapshot)

        var configuration = viewModel.items.isEmpty ? UIContentUnavailableConfiguration.empty() : nil
        configuration?.text = "保存している画像はありません"
        configuration?.secondaryText = "探すタブから記事を検索して保存しましょう"
        contentUnavailableConfiguration = configuration
    }
}

extension SavedItemListViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = dataSource.snapshot(for: 0).items[indexPath.item]
        didTapItem(item)
    }
}

#Preview {
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

    return SavedItemListNavigationView(viewModel: SaveItemListViewModel(container: container))
}
