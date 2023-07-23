import App
import APIClient
import Core
import CoreData
import Database
import KeychainAccess
import SwiftUI

@main
struct QiitaViewerApp: App {
    var body: some Scene {
        WindowGroup {
            AppRootView(dependency: .shared)
                .environment(\.managedObjectContext, Dependency.shared.container.viewContext)
        }
    }
}

extension Dependency {
    static let shared: Dependency = {
        let keychainClient = KeychainClient(keychain: Keychain(service: "com.github.mth0928.qiita_viewer"))
        let container = NSPersistentContainer.make(inMemory: false)
        return Dependency(
            container: container,
            apiClient: APIClient(tokenProvider: keychainClient),
            keychain: keychainClient
        )
    }()
}
