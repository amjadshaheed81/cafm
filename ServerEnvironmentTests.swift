import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

@main struct ServerEnvironmentTests {
    static var passed = 0
    static func check(_ condition: @autoclosure () -> Bool, _ description: String) {
        guard condition() else { fputs("FAIL: \(description)\n", stderr); exit(1) }
        passed += 1
        print("PASS: \(description)")
    }
    static func isolated() -> UserDefaults {
        let name = "CAFM.EnvironmentSwitch.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defaults.removePersistentDomain(forName: name)
        return defaults
    }
    static func main() throws {
        let fresh = ServerConfiguration(defaults: isolated())
        fresh.bootstrap()
        check(fresh.baseURL == ServerConfiguration.productionURL, "fresh installation selects app.corecafm.com")
        check(fresh.kind == .live, "fresh installation starts LIVE")
        check(fresh.preferredLiveURL == ServerConfiguration.productionURL, "new install remembers CAFM LIVE alias")
        try fresh.saveValidatedURL(ServerConfiguration.testingURL)
        check(fresh.baseURL == ServerConfiguration.testingURL, "new install can switch to TEST")
        check(fresh.kind == .test, "TEST environment is recognised")
        check(fresh.preferredLiveURL == ServerConfiguration.productionURL, "TEST preserves prior LIVE choice")
        fresh.restoreLiveURL()
        check(fresh.baseURL == ServerConfiguration.productionURL, "fresh TEST -> LIVE returns to CAFM domain")

        let originalDefaults = isolated()
        originalDefaults.set(false, forKey: "isNeedLogOutForPro")
        let installed = ServerConfiguration(defaults: originalDefaults)
        installed.bootstrap()
        check(installed.baseURL == ServerConfiguration.legacyProductionURL, "published install retains Unite domain")
        check(installed.preferredLiveURL == ServerConfiguration.legacyProductionURL, "published install remembers Unite domain")
        try installed.saveValidatedURL(ServerConfiguration.testingURL)
        check(installed.kind == .test, "published install can switch to TEST")
        check(installed.preferredLiveURL == ServerConfiguration.legacyProductionURL, "TEST remembers original property alias")
        installed.restoreLiveURL()
        check(installed.baseURL == ServerConfiguration.legacyProductionURL, "TEST -> LIVE restores original property URL")

        installed.restoreTrustedProductionURL(ServerConfiguration.productionURL)
        check(installed.preferredLiveURL == ServerConfiguration.productionURL, "explicit CAFM LIVE selection updates preference")
        try installed.saveValidatedURL(ServerConfiguration.testingURL)
        installed.restoreLiveURL()
        check(installed.baseURL == ServerConfiguration.productionURL, "new explicit LIVE preference survives TEST roundtrip")

        installed.restoreTrustedProductionURL(ServerConfiguration.legacyProductionURL)
        check(installed.baseURL == ServerConfiguration.legacyProductionURL, "trusted Unite recovery is permitted")
        installed.restoreTrustedProductionURL("https://malicious.example.org")
        check(installed.baseURL == ServerConfiguration.legacyProductionURL, "login recovery cannot select unknown host")

        try installed.saveValidatedURL("https://enterprise.example.org/")
        check(installed.kind == .custom, "custom server is recognised")
        check(installed.baseURL == "https://enterprise.example.org", "custom domain is normalised")
        installed.restoreLiveURL()
        check(installed.baseURL == ServerConfiguration.legacyProductionURL, "custom -> LIVE restores last chosen LIVE alias")

        let rev = ServerConfiguration(defaults: originalDefaults)
        check(rev.preferredLiveURL == ServerConfiguration.legacyProductionURL, "LIVE preference persists across app restarts")
        try rev.saveValidatedURL(ServerConfiguration.testingURL)
        let rev2 = ServerConfiguration(defaults: originalDefaults)
        check(rev2.kind == .test, "TEST persists across app restarts")
        check(rev2.preferredLiveURL == ServerConfiguration.legacyProductionURL, "LIVE alias persists through app relaunch")

        check(!rev2.canSendSessionCookie(to: URL(string:"https://property.unitetheunion.org/api/site/site/all")), "TEST never sends token to LIVE")
        check(rev2.canSendSessionCookie(to: URL(string:"https://testcp.corecafm.com/api/site/site/all")), "TEST can authenticate only selected host")
        check(!rev2.canSendSessionCookie(to: URL(string:"http://testcp.corecafm.com/api/site/site/all")), "never send token over HTTP")
        check(!rev2.canSendSessionCookie(to: URL(string:"https://external.example.org/test")), "never send token to external host")
        check(CAFMHTTPStatus.isSuccess(200), "HTTP 200 success")
        check(!CAFMHTTPStatus.isSuccess(401), "HTTP 401 failure")
        check(!CAFMHTTPStatus.isSuccess(nil), "missing HTTP status fails")
        for address in ["http://testcp.corecafm.com", "https://testcp.corecafm.com/path", "https://user@hostname.example.org"] {
            check((try? ServerConfiguration.normalizedURL(address)) == nil, "reject invalid address \(address)")
        }
        print("ALL \(passed) SERVER CONFIGURATION TESTS PASSED")
    }
}
