import APIClient

public protocol KeychainProtocol: AccessTokenProvider {
    func get(_ key: String) -> String?
    func set(_ value: String?, for key: String)
}

extension KeychainProtocol {
    private var accessTokenKey: String { "access_token" }

    public var accessToken: String? {
        get { get(accessTokenKey) }
        nonmutating set { set(newValue, for: accessTokenKey) }
    }
}
