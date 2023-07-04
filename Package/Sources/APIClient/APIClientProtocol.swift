public protocol APIClientProtocol {
    func getItems(query: String) async throws -> [ItemResponse]
    func authenticatedUser() async throws -> UserResponse
}
