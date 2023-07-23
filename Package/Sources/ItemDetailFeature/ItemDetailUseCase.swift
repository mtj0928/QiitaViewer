import Core
import CoreData
import Foundation

public struct ItemDetailUseCase: Sendable {
    private let container: NSPersistentContainer

    public init(container: NSPersistentContainer) {
        self.container = container
    }

    public func hasItem(id: String) throws -> Bool {
        let context = container.newBackgroundContext()
        let itemCount = try ItemDataAccessObject.count(id: id, on: context)
        return itemCount >= 1
    }

    public func save(item: Item) async throws {
        try await container.performBackgroundTask { context in
            _ = try ItemDataAccessObject.insert(item: item, on: context)
            try context.save()
        }
    }

    public func delete(itemID: String) async throws {
        try await container.performBackgroundTask { context in
            let items = try ItemDataAccessObject.fetch(id: itemID, on: context)
            items.forEach { item in
                context.delete(item)
            }
            try context.save()
        }
    }
}
