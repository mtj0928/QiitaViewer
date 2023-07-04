public final class MockKeychain: KeychainProtocol {
    private var values: [String: String] = [:]

    public init(values: [String: String] = [:]) {
        self.values = values
    }

    public func get(_ key: String) -> String? {
        values[key]
    }

    public func set(_ value: String?, for key: String) {
        if let value {
            values[key] = value
        } else {
            values.removeValue(forKey: key)
        }
    }
}

extension KeychainProtocol where Self == MockKeychain {
    public static var mock: MockKeychain {
        mock([:])
    }

    public static func mock(_ values: [String: String]) -> MockKeychain {
        MockKeychain(values: values)
    }
}
