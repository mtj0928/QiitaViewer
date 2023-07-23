import APIClient
import CoreData
import Database
import Foundation

public struct Dependency: Equatable {
    private let id = UUID()

    public let container: NSPersistentContainer
    public let apiClient: any APIClientProtocol
    public let keychain: any KeychainProtocol

    public init(
        container: NSPersistentContainer,
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
