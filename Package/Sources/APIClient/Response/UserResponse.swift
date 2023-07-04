import Foundation

public struct UserResponse: Codable, Identifiable, Hashable, Sendable {
    public var id: String
    public var name: String?
    public var gitHubLoginName: String?
    public var twitterScreenName: String?
    public var description: String?
    public var profileImageURL: URL

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case gitHubLoginName = "github_login_name"
        case twitterScreenName = "twitter_screen_name"
        case description
        case profileImageURL = "profile_image_url"
    }

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

extension UserResponse {
    public static var dummy: UserResponse {
        UserResponse(
            id: "user id",
            name: "ダミーユーザー",
            description: "ダミーのユーザーです",
            profileImageURL: URL(string: "https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/70011/profile-images/1641719464")!
        )
    }
}

