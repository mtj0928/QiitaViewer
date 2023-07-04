import Foundation
import SwiftData

@Model
public final class ItemModel {
    @Attribute(.unique) public var id: String
    public var title: String
    public var body: String
    public var createdAt: Date
    public var insertedAt: Date
    public var commentsCount: Int
    public var likesCount: Int
    @Relationship(.cascade) public var user: UserModel?
    public var url: URL

    public init(
        id: String,
        title: String,
        body: String,
        createdAt: Date,
        commentsCount: Int,
        likesCount: Int,
        user: UserModel?,
        url: URL
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.createdAt = createdAt
        self.insertedAt = Date()
        self.commentsCount = commentsCount
        self.likesCount = likesCount
        self.user = user
        self.url = url
    }
}
