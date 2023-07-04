import APIClient
import Core
import Observation

@Observable
public final class AccountViewModel {
    private(set) var user: User? = nil
    private(set) var isLoading = false
    var accessToken: String = ""

    private let apiClient: any APIClientProtocol
    private let keychain: any KeychainProtocol

    public init(apiClient: some APIClientProtocol, keychain: some KeychainProtocol) {
        self.apiClient = apiClient
        self.keychain = keychain
        accessToken = keychain.accessToken ?? ""
    }

    func submitToken() async {
        keychain.accessToken = accessToken
        await updateUser()
    }

    func updateUser() async {
        if isLoading { return }

        isLoading = true
        defer { isLoading = false }

        guard let accessToken = keychain.accessToken,
              !accessToken.isEmpty,
              let userResponse = try? await apiClient.authenticatedUser()
        else {
            self.user = nil
            return
        }
        self.user = User(userResponse)
    }
}
