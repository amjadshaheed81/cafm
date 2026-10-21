// Admin-only Live / Test / Custom CAFM environment selector.
import UIKit
import Alamofire

final class ServerSettingsVC: UIViewController {
    private let currentServer = UILabel()
    private let picker = UISegmentedControl(items: ["LIVE", "TEST", "CUSTOM"])
    private let customField = UITextField()
    private let statusLabel = UILabel()
    private let testButton = UIButton(type: .system)
    private let saveButton = UIButton(type: .system)

    private var isAdmin: Bool {
        UserDefaults.standard.userRole == .admin &&
        UserConstants.shared.currentUserID != nil &&
        (jwtToken?.isEmpty == false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Server Configuration"
        view.backgroundColor = .systemBackground
        buildView()
        updateSelection()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isAdmin { navigationController?.popViewController(animated: false) }
    }

    private func buildView() {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 18
        stack.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(stack)
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 24),
            stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -24),
            stack.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor, constant: -20),
            stack.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor, constant: -40)
        ])

        stack.addArrangedSubview(makeLabel("Current server", .headline))
        currentServer.numberOfLines = 0
        currentServer.font = .preferredFont(forTextStyle: .body)
        currentServer.textColor = .secondaryLabel
        stack.addArrangedSubview(currentServer)

        stack.addArrangedSubview(makeLabel("Choose environment", .headline))
        picker.accessibilityLabel = "CAFM server environment"
        picker.addTarget(self, action: #selector(selectionChanged), for: .valueChanged)
        stack.addArrangedSubview(picker)

        stack.addArrangedSubview(makeLabel("LIVE: \(ServerConfiguration.shared.preferredLiveURL)\nTEST: \(ServerConfiguration.testingURL)\nCUSTOM: another HTTPS CAFM API", .footnote))
        customField.borderStyle = .roundedRect
        customField.autocorrectionType = .no
        customField.autocapitalizationType = .none
        customField.keyboardType = .URL
        customField.textContentType = .URL
        customField.placeholder = "https://customer.example.com"
        customField.accessibilityLabel = "Custom CAFM server URL"
        customField.returnKeyType = .done
        customField.addTarget(self, action: #selector(editingFinished), for: .editingDidEndOnExit)
        customField.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
        stack.addArrangedSubview(customField)

        statusLabel.textColor = .secondaryLabel
        statusLabel.font = .preferredFont(forTextStyle: .footnote)
        statusLabel.numberOfLines = 0
        stack.addArrangedSubview(statusLabel)

        configureButton(testButton, title: "Test connection", action: #selector(testTapped))
        configureButton(saveButton, title: "Save and switch server", action: #selector(saveTapped))
        stack.addArrangedSubview(testButton)
        stack.addArrangedSubview(saveButton)
        stack.addArrangedSubview(makeLabel("Changing servers signs you out and clears the selected site and cached responses on this device. You must log in to the new server. Existing production users are not switched automatically.", .footnote))
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(editingFinished))
        dismissTap.cancelsTouchesInView = false
        view.addGestureRecognizer(dismissTap)
    }

    private func makeLabel(_ text: String, _ style: UIFont.TextStyle) -> UILabel {
        let label = UILabel()
        label.text = text
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: style)
        label.textColor = .label
        return label
    }

    private func configureButton(_ button: UIButton, title: String, action: Selector) {
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        button.layer.cornerRadius = 8
        button.layer.borderColor = UIColor.systemBlue.cgColor
        button.layer.borderWidth = 1
        button.heightAnchor.constraint(greaterThanOrEqualToConstant: 46).isActive = true
        button.addTarget(self, action: action, for: .touchUpInside)
    }

    private func updateSelection() {
        let config = ServerConfiguration.shared
        currentServer.text = "\(config.baseURL)\n(\(config.kind.rawValue.uppercased()))"
        picker.selectedSegmentIndex = config.kind == .live ? 0 : (config.kind == .test ? 1 : 2)
        if config.kind == .custom { customField.text = config.baseURL }
        selectionChanged()
    }

    @objc private func selectionChanged() {
        customField.isHidden = picker.selectedSegmentIndex != 2
        statusLabel.text = "Select Test connection to check this URL (optional). Save and switch will sign you out."
    }

    @objc private func editingFinished() { view.endEditing(true) }

    private func candidateURL() throws -> String {
        switch picker.selectedSegmentIndex {
        case 0: return ServerConfiguration.shared.preferredLiveURL
        case 1: return ServerConfiguration.testingURL
        case 2: return try ServerConfiguration.normalizedURL(customField.text ?? "")
        default: throw ServerConfigurationError.invalidURL
        }
    }

    private func setBusy(_ busy: Bool) {
        testButton.isEnabled = !busy
        saveButton.isEnabled = !busy
        picker.isEnabled = !busy
        customField.isEnabled = !busy
    }

    @objc private func testTapped() {
        do {
            let url = try candidateURL()
            setBusy(true)
            statusLabel.text = "Checking \(url)…"
            ServerConfiguration.checkConnection(to: url) { [weak self] result in
                guard let self = self else { return }
                self.setBusy(false)
                switch result {
                case .success: self.statusLabel.text = "Connection successful: CAFM API is healthy."
                case .failure(let error): self.statusLabel.text = "Connection failed: \(error.localizedDescription)"
                }
            }
        } catch { statusLabel.text = error.localizedDescription }
    }

    @objc private func saveTapped() {
        guard isAdmin else { return }
        let target: String
        do { target = try candidateURL() }
        catch { statusLabel.text = error.localizedDescription; return }
        if target == ServerConfiguration.shared.baseURL {
            statusLabel.text = "Already connected to this server."
            return
        }
        // A failed or unavailable health endpoint must NOT silently prevent
        // an admin switching servers. The Test connection button remains optional.
        // Confirmation makes the sign-out and change of environment explicit.
        confirmSwitch(to: target)
    }

    private func confirmSwitch(to url: String) {
        let alert = UIAlertController(title: "Switch CAFM server?",
            message: "Switch to \(url)? You will be signed out. Save any unfinished inspection before continuing.",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Switch and sign out", style: .destructive) { [weak self] _ in
            guard let self = self, self.isAdmin else { return }
            self.switchServer(to: url)
        })
        present(alert, animated: true)
    }

    private func switchServer(to target: String) {
        do {
            try CAFMServerSessionSwitch.switchTo(target)
            logOutScreen()
        } catch {
            statusLabel.text = "Server not changed: \(error.localizedDescription)"
        }
    }
}

/// Shared by Admin Settings and the LIVE / TEST login chooser.
/// A session must never be carried from one CAFM host to another.
enum CAFMServerSessionSwitch {
    static func switchTo(_ target: String) throws {
        let normalized = try ServerConfiguration.normalizedURL(target)
        guard normalized != ServerConfiguration.shared.baseURL else { return }
        AF.session.getAllTasks { tasks in tasks.forEach { $0.cancel() } }
        URLSession.shared.getAllTasks { tasks in tasks.forEach { $0.cancel() } }
        UserConstants.shared.logoutUser()
        backUPUserEmailId = nil
        URLCache.shared.removeAllCachedResponses()
        try ServerConfiguration.shared.saveValidatedURL(normalized)
    }
}
