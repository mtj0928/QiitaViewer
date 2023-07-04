import Core
import Foundation
import SwiftData

public struct ItemDetailUseCase: Sendable {
    private let container: ModelContainer

    public init(container: ModelContainer) {
        self.container = container
    }

    public func hasItem(id: String) throws -> Bool {
        let context = ModelContext(container)
        let itemCount = try ItemDataAccessObject.count(id: id, on: context)
        return itemCount >= 1
    }

    public func save(item: Item) async throws {
        // TODO: - ModelContext(container) だと書き込みが[at]Queryに反映されない
        let context = await container.mainContext
        _ = try ItemDataAccessObject.insert(item: item, on: context)
        try! context.save()
    }

    public func delete(itemID: String) async throws {
        // TODO: - ModelContext(container) だと書き込みが[at]Queryに反映されない
        let context = await container.mainContext
        let items = try ItemDataAccessObject.fetch(id: itemID, on: context)
        items.forEach { item in
            context.delete(item)
        }
        try context.save()
    }
}
