// Visible environment reminder on every screen, including login and modal flows.
import UIKit

final class EnvironmentBadge {
    static let shared = EnvironmentBadge()
    private weak var badge: UILabel?

    func update(in window: UIWindow?) {
        guard let window = window else { return }
        badge?.removeFromSuperview()
        let configuration = ServerConfiguration.shared
        guard configuration.kind != .live else { return }
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = configuration.kind == .test ? "TEST MODE · testcp.corecafm.com" : "CUSTOM SERVER · \(configuration.displayServer)"
        label.textColor = .black
        label.backgroundColor = UIColor(red: 1.0, green: 0.75, blue: 0.20, alpha: 0.96)
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        label.accessibilityLabel = label.text
        label.isUserInteractionEnabled = false
        window.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: window.safeAreaLayoutGuide.topAnchor),
            label.leadingAnchor.constraint(equalTo: window.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: window.trailingAnchor),
            label.heightAnchor.constraint(equalToConstant: 23)
        ])
        window.bringSubviewToFront(label)
        badge = label
    }
}
