import AccountFeature
import Core
import ItemListFeature
import SavedItemListFeature
import SwiftUI
import SwiftData

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

public struct AppRootView: View {
    let dependency: Dependency

    @State var selectedView: ViewKind = .search

    let itemListViewModel: ItemListViewModel
    let accountViewModel: AccountViewModel

    @Environment(\.horizontalSizeClass) var verticalSize

    public init(dependency: Dependency) {
        self.dependency = dependency
        self.itemListViewModel = ItemListViewModel(apiClient: dependency.apiClient)
        self.accountViewModel = AccountViewModel(
            apiClient: dependency.apiClient,
            keychain: dependency.keychain
        )
    }

    public var body: some View {
        Group {
            switch verticalSize {
            case .compact:
                TabView(selection: $selectedView) {
                    ItemListView(viewModel: itemListViewModel)
                        .tabItem { ViewKind.search.label }
                        .tag(ViewKind.search)

                    SavedItemListView()
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
                        SavedItemListView()
                            .tabItem {
                                Image(systemName: "tray.and.arrow.down")
                                Text("保存済み")
                            }
                    case .account:
                        AccountView(viewModel: accountViewModel)
                    }
                }
                .navigationTitle("Qiita Viewer")
            default:
                EmptyView()
            }
        }
        .environment(\.dependency, dependency)
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        AppRootView(dependency: .mock)
    }
}
