import APIClient
import KeychainAccess

public final class KeychainClient: KeychainProtocol, AccessTokenProvider {
    private let keychain: Keychain

    public init(keychain: Keychain) {
        self.keychain = keychain
    }

    public func get(_ key: String) -> String? {
        keychain[key]
    }

    public func set(_ value: String?, for key: String) {
        keychain[key] = value
    }
}
