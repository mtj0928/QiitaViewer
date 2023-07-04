import Database
import Foundation
import SwiftData

public enum ItemDataAccessObject {
    public static func count(id: String, on context: ModelContext) throws -> Int {
        try context.fetchCount(.items(id: id))
    }

    public static func fetchAll(on context: ModelContext) throws -> [ItemModel] {
        try context.fetch(.all)
    }

    public static func fetch(id: String, on context: ModelContext) throws -> [ItemModel] {
        try context.fetch(.items(id: id))
    }

    public static func insert(item: Item, on context: ModelContext) throws -> ItemModel {
        let user = try UserDataAccessObject.fetchOrInsertUser(user: item.user, on: context)
        let itemModel = ItemModel(
            id: item.id,
            title: item.title,
            body: item.body,
            createdAt: item.createdAt,
            commentsCount: item.commentsCount,
            likesCount: item.likesCount,
            user: user,
            url: item.url
        )
        context.insert(itemModel)
        return itemModel
    }
}

extension FetchDescriptor {
    fileprivate static var all: FetchDescriptor<ItemModel> {
        var fetchDescriptor = FetchDescriptor<ItemModel>()
        fetchDescriptor.fetchLimit = 50
        fetchDescriptor.includePendingChanges = true
        return fetchDescriptor
    }

    fileprivate static func items(id: String) -> FetchDescriptor<ItemModel> {
        var fetchDescriptor = FetchDescriptor<ItemModel>(
            predicate: #Predicate {
                $0.id == id
            }
        )
        fetchDescriptor.fetchLimit = 50
        fetchDescriptor.includePendingChanges = true
        return fetchDescriptor
    }
}
