import AccountFeature
import Core
import ItemListFeature
import SavedItemListFeature
import SwiftUI

public struct AppRootView: View {

    private let dependency: Dependency
    private let itemListViewModel: ItemListViewModel
    private let accountViewModel: AccountViewModel
    private let saveItemListViewModel: SaveItemListViewModel

    @State private var selectedView: ViewKind = .search
    @Environment(\.horizontalSizeClass) private var verticalSize

    public init(dependency: Dependency) {
        self.dependency = dependency
        self.itemListViewModel = ItemListViewModel(apiClient: dependency.apiClient)
        self.accountViewModel = AccountViewModel(
            apiClient: dependency.apiClient,
            keychain: dependency.keychain
        )
        self.saveItemListViewModel = SaveItemListViewModel(container: dependency.container)
    }

    public var body: some View {
        Group {
            switch verticalSize {
            case .compact:
                TabView(selection: $selectedView) {
                    ItemListView(viewModel: itemListViewModel)
                        .tabItem { ViewKind.search.label }
                        .tag(ViewKind.search)

                    SavedItemListNavigationView(viewModel: saveItemListViewModel)
                        .tabItem { ViewKind.download.label }
                        .tag(ViewKind.download)

                    AccountView(viewModel: accountViewModel)
                        .tabItem { ViewKind.account.label }
                        .tag(ViewKind.account)
                }
            case .regular:
                NavigationSplitView {
                    List(
                        ViewKind.allCases,
                        selection: Binding(
                            get: { selectedView },
                            set: { value in selectedView = value ?? .search }
                        )
                    ) { kind in
                        NavigationLink(value: kind) {
                            kind.label
                        }
                    }
                } detail: {
                    switch selectedView {
                    case .search:
                        ItemListView(viewModel: itemListViewModel)
                    case .download:
                        SavedItemListNavigationView(viewModel: saveItemListViewModel)
                    case .account:
                        AccountView(viewModel: accountViewModel)
                    }
                }
                .navigationTitle("Qiita Viewer")
            default:
                Text("")
            }
        }
        .environment(\.dependency, dependency)
        .environment(\.managedObjectContext, dependency.container.viewContext)
    }
}

enum ViewKind: String, Hashable, Identifiable, CaseIterable {
    case search, download, account

    var id: String { rawValue }

    var label: some View {
        switch self {
        case .search: return Label("探す", systemImage: "magnifyingglass")
        case .download: return Label("保存済み", systemImage: "tray.and.arrow.down")
        case .account: return Label("アカウント", systemImage: "person")
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        AppRootView(dependency: Dependency(
            container: .mock,
            apiClient: .mock(
                getItems: { _ in
                    return [
                        .dummy1,
                        .dummy2,
                        .dummy3,
                    ]
                },
                authenticatedUser: { .dummy }
            ),
            keychain: .mock
        ))
        .tint(Color.green)
    }
}
