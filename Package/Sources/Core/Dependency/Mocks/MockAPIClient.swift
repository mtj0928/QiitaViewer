import APIClient

public struct MockAPIClient: APIClientProtocol {
    public var getItemsHandler: (String) async throws -> [ItemResponse]
    public var authenticatedUserHandler: () async throws -> UserResponse

    public func getItems(query: String) async throws -> [ItemResponse] {
        try await getItemsHandler(query)
    }

    public func authenticatedUser() async throws -> UserResponse {
        try await authenticatedUserHandler()
    }
}

extension APIClientProtocol where Self == MockAPIClient {
    public static var mock: MockAPIClient {
        MockAPIClient { _ in
            try await Task.sleep(nanoseconds: 1_000_000_000)
            return [.dummy1]
        } authenticatedUserHandler: {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            return .dummy
        }
    }

    public static var failure: MockAPIClient {
        MockAPIClient { _ in
            try await Task.sleep(nanoseconds: 1_000_000_000)
            throw MockAPIClientError()
        } authenticatedUserHandler: {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            throw MockAPIClientError()
        }
    }

    public static var tooSlow: MockAPIClient {
        MockAPIClient { _ in
            try await Task.sleep(nanoseconds: 10_000_000_000)
            return [.dummy1]
        } authenticatedUserHandler: {
            try await Task.sleep(nanoseconds: 10_000_000_000)
            return .dummy
        }
    }

    public static func mock(
        getItems: @escaping (String) async throws -> [ItemResponse],
        authenticatedUser: @escaping () async throws -> UserResponse
    ) -> MockAPIClient {
        MockAPIClient(
            getItemsHandler: getItems,
            authenticatedUserHandler: authenticatedUser
        )
    }
}

private struct MockAPIClientError: Error, CustomStringConvertible {
    var description: String = "ダミーのエラー"
}
