import APIClient
import Database
import Foundation

public struct User: Codable, Identifiable, Hashable, Sendable {
    public var id: String
    public var name: String?
    public var gitHubLoginName: String?
    public var twitterScreenName: String?
    public var description: String?
    public var profileImageURL: URL

    public var displayName: String {
        validate(name) ?? "@\(id)"
    }

    private func validate(_ name: String?) -> String? {
        guard let name,
              !name.isEmpty
        else { return nil }
        return name
    }
}

extension User {
    public init(_ model: UserModel) {
        self.init(
            id: model.id!,
            name: model.name,
            gitHubLoginName: model.gitHubLoginName,
            twitterScreenName: model.twitterScreenName,
            description: model.introductionText,
            profileImageURL: model.profileImageURL!
        )
    }

    public init(_ response: UserResponse) {
        self.init(
            id: response.id,
            name: response.name,
            gitHubLoginName: response.gitHubLoginName,
            twitterScreenName: response.twitterScreenName,
            description: response.description,
            profileImageURL: response.profileImageURL
        )
    }
}

extension User {
    public static var dummy: User { User(.dummy) }
}
