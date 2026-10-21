// Store authentication tokens in the iOS Keychain, never UserDefaults.
import Foundation
import Security

enum SecureCredentials {
    private static let service = (Bundle.main.bundleIdentifier ?? "com.tdkglobalit.cafm") + ".authentication"

    static func get(_ name: String) -> String? {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrService as String: service,
                                    kSecAttrAccount as String: name,
                                    kSecReturnData as String: true,
                                    kSecMatchLimit as String: kSecMatchLimitOne]
        var result: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    @discardableResult
    static func set(_ value: String?, for name: String) -> Bool {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrService as String: service,
                                    kSecAttrAccount as String: name]
        guard let value = value, !value.isEmpty else {
            SecItemDelete(query as CFDictionary)
            return true
        }
        guard let encoded = value.data(using: .utf8) else { return false }
        let attributes: [String: Any] = [kSecValueData as String: encoded,
                                         kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly]
        let result = SecItemUpdate(query as CFDictionary, [kSecValueData as String: encoded] as CFDictionary)
        if result == errSecSuccess { return true }
        guard result == errSecItemNotFound else { return false }
        var toAdd = query
        attributes.forEach { toAdd[$0.key] = $0.value }
        return SecItemAdd(toAdd as CFDictionary, nil) == errSecSuccess
    }

    /// Upgrade existing installations without silently losing the active JWT.
    /// Retained plaintext passwords are removed immediately and never migrated.
    static func migrateLegacyDefaults() {
        let defaults = UserDefaults.standard
        for name in ["jwtToken", "sasToken"] {
            if let oldValue = defaults.string(forKey: name), !oldValue.isEmpty {
                // Upgrade: the UserDefaults token belongs to this installation.
                // If Keychain is unavailable, require a new login rather than leaving plaintext.
                _ = set(oldValue, for: name)
            }
            defaults.removeObject(forKey: name)
        }
        defaults.removeObject(forKey: "userPassword")
        defaults.removeObject(forKey: "backUPUserPassword")
    }

    /// Proactive check, when token is a JWT with the standard exp claim.
    /// If not parseable, the HTTP 401 handler remains authoritative.
    static var sessionExpired: Bool {
        guard var token = get("jwtToken"), !token.isEmpty else { return true }
        token = token.replacingOccurrences(of: "JWTSESSIONID=", with: "")
        let parts = token.split(separator: ".")
        guard parts.count >= 2 else { return false }
        var base64 = String(parts[1]).replacingOccurrences(of: "-", with: "+")
                                     .replacingOccurrences(of: "_", with: "/")
        base64 += String(repeating: "=", count: (4 - base64.count % 4) % 4)
        guard let data = Data(base64Encoded: base64),
              let payload = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any],
              let exp = payload["exp"] as? Double else { return false }
        return Date().timeIntervalSince1970 >= exp - 30
    }
}
