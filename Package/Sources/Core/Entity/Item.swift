import APIClient
import Database
import Foundation

public struct Item: Codable, Identifiable, Hashable, Sendable {
    public var id: String
    public var title: String
    public var body: String
    public var createdAt: Date
    public var commentsCount: Int
    public var likesCount: Int
    public var user: User
    public var url: URL
}

extension Item {
    public init(_ model: ItemModel) {
        self.init(
            id: model.itemID!,
            title: model.title!,
            body: model.body!,
            createdAt: model.createdAt!,
            commentsCount: Int(model.commentsCount),
            likesCount: Int(model.likesCount),
            user: User(model.user!),
            url: model.url!
        )
    }

    public init(_ response: ItemResponse) {
        self.init(
            id: response.id,
            title: response.title,
            body: response.body,
            createdAt: response.createdAt,
            commentsCount: response.commentsCount,
            likesCount: response.likesCount,
            user: User(response.user),
            url: response.url
        )
    }
}

extension Item {
    public static var dummy1: Item { Item(.dummy1) }
    public static var dummy2: Item { Item(.dummy2) }
    public static var dummy3: Item { Item(.dummy3) }
}
