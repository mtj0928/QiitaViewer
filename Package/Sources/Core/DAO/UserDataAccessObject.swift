import Database
import CoreData
import Foundation

public enum UserDataAccessObject {
    public static func fetch(id: String, on context: NSManagedObjectContext) throws -> UserModel? {
        let fetchRequest = UserModel.fetchRequest()
        fetchRequest.predicate = .users(id: id)
        let users = try context.fetch(fetchRequest)
        return users.first
    }

    public static func insert(user: User, on context: NSManagedObjectContext) throws -> UserModel {
        let userModel = UserModel(user, context: context)
        context.insert(userModel)
        return userModel
    }

    public static func fetchOrInsertUser(user: User, on context: NSManagedObjectContext) throws -> UserModel {
        try fetch(id: user.id, on: context) ?? insert(user: user, on: context)
    }
}

extension NSPredicate {
    fileprivate static func users(id: String) -> NSPredicate {
        NSPredicate(format: "id == %@", id)
    }
}

extension UserModel {
    convenience public init(_ user: User, context: NSManagedObjectContext) {
        self.init(context: context)
        self.id = user.id
        self.name = user.name
        self.gitHubLoginName = user.gitHubLoginName
        self.twitterScreenName = user.twitterScreenName
        self.introductionText = user.description
        self.profileImageURL = user.profileImageURL
    }
}
