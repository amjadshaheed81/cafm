// CAFM server selection. No login credentials are stored here.
// Upgrade rule: installations of the original Unite app stay on property.unitetheunion.org.
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

enum CAFMHTTPStatus {
    static func isSuccess(_ code: Int?) -> Bool {
        guard let code = code else { return false }
        return (200..<300).contains(code)
    }
}

enum CAFMServerKind: String {
    case live, test, custom
}

enum ServerConfigurationError: LocalizedError {
    case invalidURL
    var errorDescription: String? {
        "Enter a complete HTTPS server address without a path, username, password or query."
    }
}

final class ServerConfiguration {
    static let shared = ServerConfiguration()
    static let legacyProductionURL = "https://property.unitetheunion.org"
    static let productionURL = "https://app.corecafm.com"
    static let testingURL = "https://testcp.corecafm.com"
    static let changedNotification = Notification.Name("CAFMServerConfigurationDidChange")

    private let addressKey = "CAFM.Server.BaseURL.v2"
    private let migratedKey = "CAFM.Server.Migrated.v2"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) { self.defaults = defaults }

    /// Called before any API request and before the old first-launch marker is changed.
    func bootstrap() {
        guard !defaults.bool(forKey: migratedKey) else { return }
        if let existing = defaults.string(forKey: addressKey),
           let normal = try? Self.normalizedURL(existing) {
            defaults.set(normal, forKey: addressKey)
        } else {
            // Old builds recorded the first launch even if no login was completed.
            let originalKeys = ["isNeedLogOutForPro", "userEmailId", "userPassword",
                                "backUPUserEmailId", "backUPUserPassword", "jwtToken", "currentUserID"]
            let isUpgrade = originalKeys.contains { defaults.object(forKey: $0) != nil }
            defaults.set(isUpgrade ? Self.legacyProductionURL : Self.buildDefaultURL, forKey: addressKey)
        }
        defaults.set(true, forKey: migratedKey)
    }

    // Can be customised in another customer's app build without changing endpoint code.
    static var buildDefaultURL: String {
        guard let string = Bundle.main.object(forInfoDictionaryKey: "CAFMDefaultAPIBaseURL") as? String,
              let normalized = try? normalizedURL(string) else { return productionURL }
        return normalized
    }

    var baseURL: String {
        bootstrap()
        return defaults.string(forKey: addressKey) ?? Self.buildDefaultURL
    }

    var kind: CAFMServerKind {
        if baseURL == Self.testingURL { return .test }
        if baseURL == Self.productionURL || baseURL == Self.legacyProductionURL { return .live }
        return .custom
    }

    var displayServer: String { URL(string: baseURL)?.host ?? baseURL }

    // Restrict authentication headers to this exact HTTPS API origin.
    func canSendSessionCookie(to requestURL: URL?) -> Bool {
        guard let requestURL = requestURL, let base = URL(string: baseURL) else { return false }
        return requestURL.scheme?.lowercased() == "https" &&
               requestURL.host?.lowercased() == base.host?.lowercased() &&
               requestURL.port == base.port
    }

    /// Accept only a base URL; endpoints append /api/... to this address.
    static func normalizedURL(_ input: String) throws -> String {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.contains("\\"), !trimmed.isEmpty,
              var components = URLComponents(string: trimmed),
              components.scheme?.lowercased() == "https",
              let host = components.host, !host.isEmpty, host.contains("."),
              components.user == nil, components.password == nil,
              components.query == nil, components.fragment == nil,
              components.path.isEmpty || components.path == "/" else {
            throw ServerConfigurationError.invalidURL
        }
        components.scheme = "https"
        components.host = host.lowercased()
        components.path = ""
        guard let valid = components.url else { throw ServerConfigurationError.invalidURL }
        return valid.absoluteString.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    }

    /// An authenticated administrator must approve the change in the UI.
    /// Callers must sign out/reset user-specific data BEFORE persisting a different server.
    func saveValidatedURL(_ url: String) throws {
        let normalized = try Self.normalizedURL(url)
        defaults.set(normalized, forKey: addressKey)
        NotificationCenter.default.post(name: Self.changedNotification, object: nil)
    }

    /// Recovery from login: users may choose either trusted LIVE alias only.
    /// The property and app domains currently point to the same production Azure services.
    func restoreTrustedProductionURL(_ url: String) {
        guard url == Self.productionURL || url == Self.legacyProductionURL else { return }
        defaults.set(url, forKey: addressKey)
        NotificationCenter.default.post(name: Self.changedNotification, object: nil)
    }

    func restoreLiveURL() { restoreTrustedProductionURL(Self.buildDefaultURL) }

    /// Deliberately unauthenticated; no cookies, tokens or user data leave this request.
    static func checkConnection(to address: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let canonical: String
        do { canonical = try normalizedURL(address) }
        catch { DispatchQueue.main.async { completion(.failure(error)) }; return }
        guard let url = URL(string: canonical + "/api/v1/site/health") else {
            DispatchQueue.main.async { completion(.failure(ServerConfigurationError.invalidURL)) }
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 12
        request.cachePolicy = .reloadIgnoringLocalCacheData
        let configuration = URLSessionConfiguration.ephemeral
        configuration.httpCookieStorage = nil
        configuration.httpShouldSetCookies = false
        URLSession(configuration: configuration).dataTask(with: request) { data, response, error in
            let result: Result<Void, Error>
            if let error = error { result = .failure(error) }
            else if let response = response as? HTTPURLResponse, response.statusCode == 200,
                    response.url?.scheme?.lowercased() == "https",
                    response.url?.host?.lowercased() == url.host?.lowercased(),
                    response.url?.port == url.port,
                    let data = data,
                    let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any],
                    (json["status"] as? String)?.uppercased() == "OK" {
                result = .success(())
            } else {
                result = .failure(NSError(domain: "CAFM.ServerHealth", code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "CAFM health check failed. Verify this address points to the correct API server."]))
            }
            DispatchQueue.main.async { completion(result) }
        }.resume()
    }
}
