import App
import APIClient
import Core
import Database
import KeychainAccess
import SwiftData
import SwiftUI

@main
struct QiitaViewerApp: App {
    var body: some Scene {
        WindowGroup {
            AppRootView(dependency: .shared)
                .modelContainer(Dependency.shared.container)
        }
    }
}

extension Dependency {
    static let shared: Dependency = {
        let keychainClient = KeychainClient(keychain: Keychain(service: "com.github.mth0928.qiita_viewer"))
        let container = try! ModelContainer(for: .default, configurations: [ModelConfiguration(inMemory: false)])
        return Dependency(
            container: container,
            apiClient: APIClient(tokenProvider: keychainClient),
            keychain: keychainClient
        )
    }()
}
