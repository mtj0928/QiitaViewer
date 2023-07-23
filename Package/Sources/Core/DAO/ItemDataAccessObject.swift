import Database
import Foundation
import CoreData

public enum ItemDataAccessObject {
    public static func count(id: String, on context: NSManagedObjectContext) throws -> Int {
        let fetchRequest = ItemModel.fetchRequest()
        fetchRequest.predicate = .items(id: id)
        return try context.count(for: fetchRequest)
    }

    public static func fetchAll(on context: NSManagedObjectContext) throws -> [ItemModel] {
        let fetchRequest = ItemModel.fetchRequest()
        return try context.fetch(fetchRequest)
    }

    public static func fetch(id: String, on context: NSManagedObjectContext) throws -> [ItemModel] {
        let fetchRequest = ItemModel.fetchRequest()
        fetchRequest.predicate = .items(id: id)
        return try context.fetch(fetchRequest)
    }

    public static func insert(item: Item, on context: NSManagedObjectContext) throws -> ItemModel {
        let user = try UserDataAccessObject.fetchOrInsertUser(user: item.user, on: context)
        let itemModel = ItemModel(context: context)
        itemModel.itemID = item.id
        itemModel.title = item.title
        itemModel.body = item.body
        itemModel.createdAt = item.createdAt
        itemModel.commentsCount = Int64(item.commentsCount)
        itemModel.likesCount = Int64(item.likesCount)
        itemModel.user = user
        itemModel.url = item.url
        context.insert(itemModel)
        return itemModel
    }
}

extension NSPredicate {
    static func items(id: String) -> NSPredicate {
        NSPredicate(format: "itemID == %@", id)
    }
}
