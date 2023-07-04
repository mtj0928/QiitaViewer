import APIClient
import Core
import Observation

@Observable
public final class ItemListViewModel {
    var searchText = "tag:swift" 
    private(set) var isLoading = false
    private(set) var items: [Item] = []

    private let apiClient: any APIClientProtocol

    public init(apiClient: some APIClientProtocol) {
        self.apiClient = apiClient
    }

    func reload() async throws {
        isLoading = true
        defer { isLoading = false }

        let items = try await apiClient.getItems(query: searchText)
        self.items = items.map { Item($0) }
    }
}
