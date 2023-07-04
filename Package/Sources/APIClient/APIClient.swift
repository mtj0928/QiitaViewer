import Foundation

public protocol AccessTokenProvider {
    var accessToken: String? { get }
}

public struct APIClient<TokenProvider: AccessTokenProvider>: APIClientProtocol {

    private let baseURL = URL(string: "https://qiita.com")!
    private let session: URLSession
    private let tokenProvider: TokenProvider

    public init(
        session: URLSession = .shared,
        tokenProvider: TokenProvider
    ) {
        self.session = session
        self.tokenProvider = tokenProvider
    }

    public func authenticatedUser() async throws -> UserResponse {
        let url = baseURL.appending(path: "api/v2/authenticated_user")
        let (data, response) = try await get(url: url)
        guard response.statusCode == 200 else {
            throw APIClientError.invalidStatusCode(response.statusCode)
        }
        do {
            return try decoder.decode(UserResponse.self, from: data)
        }
        catch {
            print(error.localizedDescription)
            throw error
        }
    }

    public func getItems(query: String) async throws -> [ItemResponse] {
        let url = baseURL.appending(path: "api/v2/items")
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = [
            URLQueryItem(name: "query", value: query)
        ]
        let (data, response) = try await get(url: urlComponents?.url ?? url)
        guard response.statusCode == 200 else {
            throw APIClientError.invalidStatusCode(response.statusCode)
        }
        do {
            return try decoder.decode([ItemResponse].self, from: data)
        }
        catch {
            print(error.localizedDescription)
            throw error
        }
    }

    private func get(url: URL) async throws -> (Data, HTTPURLResponse) {
        guard let accessToken = tokenProvider.accessToken,
              !accessToken.isEmpty
        else {
            throw APIClientError.noAccessToken
        }
        var request = URLRequest(url: url)
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            fatalError("unknown response")
        }
        return (data, httpResponse)
    }
}

enum APIClientError: Error, CustomStringConvertible {
    case noAccessToken
    case invalidStatusCode(Int)

    var description: String {
        switch self {
        case .noAccessToken:
            "アクセストークンが設定されていません"
        case .invalidStatusCode(let statusCode):
            "エラー: \(statusCode)"
        }
    }
}

let decoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return decoder
}()
