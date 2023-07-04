import APIClient
import Database
import Foundation
import SwiftData

public struct Dependency: Equatable {
    private let id = UUID()

    public let container: ModelContainer
    public let apiClient: any APIClientProtocol
    public let keychain: any KeychainProtocol

    public init(
        container: ModelContainer,
        apiClient: some APIClientProtocol,
        keychain: some KeychainProtocol
    ) {
        self.container = container
        self.apiClient = apiClient
        self.keychain = keychain
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

extension Dependency {
    public static var mock: Dependency {
        Dependency(
            container: .mock,
            apiClient: .mock,
            keychain: .mock([:])
        )
    }
}
