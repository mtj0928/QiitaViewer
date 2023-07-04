import Database
import Foundation
import SwiftData

public enum UserDataAccessObject {
    public static func fetch(id: String, on context: ModelContext) throws -> UserModel? {
        let users = try context.fetch(.users(id: id))
        return users.first
    }

    public static func insert(user: User, on context: ModelContext) throws -> UserModel {
        let userModel = UserModel(user)
        context.insert(userModel)
        return userModel
    }

    public static func fetchOrInsertUser(user: User, on context: ModelContext) throws -> UserModel {
        try fetch(id: user.id, on: context) ?? insert(user: user, on: context)
    }
}

extension FetchDescriptor {
    fileprivate static func users(id: String) -> FetchDescriptor<UserModel> {
        var fetchDescriptor = FetchDescriptor<UserModel>(
            predicate: #Predicate {
                $0.id == id
            }
        )
        fetchDescriptor.fetchLimit = 50
        fetchDescriptor.includePendingChanges = true
        return fetchDescriptor
    }
}

extension UserModel {
    convenience public init(_ user: User) {
        self.init(
            id: user.id,
            name: user.name,
            gitHubLoginName: user.gitHubLoginName,
            twitterScreenName: user.twitterScreenName,
            introductionText: user.description,
            profileImageURL: user.profileImageURL
        )
    }
}
