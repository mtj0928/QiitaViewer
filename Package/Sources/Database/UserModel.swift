import Foundation
import SwiftData

@Model
public final class UserModel {
    @Attribute(.unique) public var id: String
    public var name: String?
    public var gitHubLoginName: String?
    public var twitterScreenName: String?
    public var introductionText: String?
    public var profileImageURL: URL

    public init(
        id: String,
        name: String? = nil,
        gitHubLoginName: String? = nil,
        twitterScreenName: String? = nil,
        introductionText: String? = nil,
        profileImageURL: URL
    ) {
        self.id = id
        self.name = name
        self.gitHubLoginName = gitHubLoginName
        self.twitterScreenName = twitterScreenName
        self.introductionText = introductionText
        self.profileImageURL = profileImageURL
    }
}
