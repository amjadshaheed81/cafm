//
//  LoginVC.swift
//  cafm
//
//  Created by ShitaRam on 17/08/24.
//

import UIKit
import SCLAlertView
import LocalAuthentication

class LoginVC: PortraitViewController, UITextFieldDelegate {
    
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet var tfPassword: UITextField!
    
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var passwordLbl: UILabel!
    @IBOutlet weak var forgotPasswordLbl: UILabel!
    
    private let environmentPicker = UISegmentedControl(items: ["LIVE", "TEST"])
    private let environmentLabel = UILabel()
    private var loginAttemptID = UUID()
    private weak var loginScrollView: UIScrollView?
    private weak var loginFormWidth: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tfEmail.delegate = self
        self.tfPassword.delegate = self
        self.initialViewSetup()
        self.tfEmail.text = backUPUserEmailId
        installEnvironmentChooser()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameChanged(_:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshEnvironmentChooser()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // The original storyboard hardcodes a 350pt form width. Avoid horizontal
        // clipping on small devices without changing the existing storyboard.
        loginFormWidth?.constant = min(350, max(260, view.bounds.width - 36))
    }

    /// The LOGIN screen intentionally permits LIVE / TEST selection before
    /// authentication. Arbitrary custom URLs remain Admin-only after login.
    private func installEnvironmentChooser() {
        guard let loginForm = tfEmail.superview else { return }
        let previousLayout = view.constraints.filter {
            ($0.firstItem as? UIView) === loginForm || ($0.secondItem as? UIView) === loginForm
        }
        NSLayoutConstraint.deactivate(previousLayout)
        loginForm.removeFromSuperview()

        let bottomPanel = UIView()
        bottomPanel.translatesAutoresizingMaskIntoConstraints = false
        bottomPanel.backgroundColor = .secondarySystemBackground
        bottomPanel.layer.cornerRadius = 12
        bottomPanel.layer.borderColor = UIColor.separator.cgColor
        bottomPanel.layer.borderWidth = 0.5
        view.addSubview(bottomPanel)

        environmentPicker.accessibilityLabel = "Login server: LIVE or TEST"
        environmentPicker.addTarget(self, action: #selector(environmentPickerChanged), for: .valueChanged)
        environmentPicker.heightAnchor.constraint(greaterThanOrEqualToConstant: 36).isActive = true

        let helpButton = UIButton(type: .system)
        helpButton.setTitle("Options", for: .normal)
        helpButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        helpButton.accessibilityLabel = "Server options and recovery"
        helpButton.addTarget(self, action: #selector(serverOptionsTapped), for: .touchUpInside)
        helpButton.setContentHuggingPriority(.required, for: .horizontal)

        environmentLabel.font = .systemFont(ofSize: 11, weight: .medium)
        environmentLabel.textAlignment = .center
        environmentLabel.textColor = .secondaryLabel
        environmentLabel.adjustsFontSizeToFitWidth = true
        environmentLabel.minimumScaleFactor = 0.75
        environmentLabel.numberOfLines = 1

        let topRow = UIStackView(arrangedSubviews: [environmentPicker, helpButton])
        topRow.axis = .horizontal
        topRow.alignment = .center
        topRow.distribution = .fill
        topRow.spacing = 12
        let panelStack = UIStackView(arrangedSubviews: [topRow, environmentLabel])
        panelStack.axis = .vertical
        panelStack.spacing = 5
        panelStack.translatesAutoresizingMaskIntoConstraints = false
        bottomPanel.addSubview(panelStack)
        NSLayoutConstraint.activate([
            bottomPanel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            bottomPanel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            bottomPanel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            panelStack.topAnchor.constraint(equalTo: bottomPanel.topAnchor, constant: 8),
            panelStack.bottomAnchor.constraint(equalTo: bottomPanel.bottomAnchor, constant: -8),
            panelStack.leadingAnchor.constraint(equalTo: bottomPanel.leadingAnchor, constant: 12),
            panelStack.trailingAnchor.constraint(equalTo: bottomPanel.trailingAnchor, constant: -12)
        ])

        // Scroll only the original storyboard form. The footer stays visible,
        // even on compact iPhones. The content centres vertically when space allows.
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsVerticalScrollIndicator = false
        scroll.keyboardDismissMode = .interactive
        view.addSubview(scroll)
        loginScrollView = scroll
        let canvas = UIView()
        canvas.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(canvas)
        canvas.addSubview(loginForm)
        loginForm.translatesAutoresizingMaskIntoConstraints = false
        loginFormWidth = loginForm.constraints.first(where: {
            $0.firstAttribute == .width && $0.secondItem == nil
        })
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: bottomPanel.topAnchor, constant: -5),
            canvas.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            canvas.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            canvas.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor),
            canvas.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor),
            canvas.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor),
            canvas.heightAnchor.constraint(greaterThanOrEqualTo: scroll.frameLayoutGuide.heightAnchor),
            loginForm.centerXAnchor.constraint(equalTo: canvas.centerXAnchor),
            loginForm.centerYAnchor.constraint(equalTo: canvas.centerYAnchor),
            loginForm.topAnchor.constraint(greaterThanOrEqualTo: canvas.topAnchor, constant: 12),
            loginForm.bottomAnchor.constraint(lessThanOrEqualTo: canvas.bottomAnchor, constant: -12)
        ])
        refreshEnvironmentChooser()
    }

    private func refreshEnvironmentChooser() {
        let config = ServerConfiguration.shared
        switch config.kind {
        case .live:
            environmentPicker.selectedSegmentIndex = 0
            environmentLabel.textColor = .secondaryLabel
            environmentLabel.text = "LIVE · \(config.displayServer)"
        case .test:
            environmentPicker.selectedSegmentIndex = 1
            environmentLabel.textColor = .systemOrange
            environmentLabel.text = "TEST MODE · \(config.displayServer) · Not production"
        case .custom:
            environmentPicker.selectedSegmentIndex = UISegmentedControl.noSegment
            environmentLabel.textColor = .systemOrange
            environmentLabel.text = "CUSTOM · \(config.displayServer)"
        }
    }

    @objc private func environmentPickerChanged() {
        let config = ServerConfiguration.shared
        let target = environmentPicker.selectedSegmentIndex == 1
            ? ServerConfiguration.testingURL : config.preferredLiveURL
        guard target != config.baseURL else { refreshEnvironmentChooser(); return }
        let targetLabel = environmentPicker.selectedSegmentIndex == 1 ? "TEST" : "LIVE"
        refreshEnvironmentChooser() // only show the new environment once saved
        let alert = UIAlertController(title: "Switch to \(targetLabel)?",
            message: "Server: \(target)\n\nThis signs out any existing session. Unsaved work will be lost. You can switch back from this screen.",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Switch", style: .destructive) { [weak self] _ in
            self?.switchFromLogin(to: target)
        })
        present(alert, animated: true)
    }

    @objc private func serverOptionsTapped() {
        let alert = UIAlertController(title: "Server options",
            message: "Current: \(ServerConfiguration.shared.displayServer)\nChoose a trusted LIVE address or use the LIVE / TEST buttons below the login form.",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Use app.corecafm.com (LIVE)", style: .default) { [weak self] _ in
            self?.switchFromLogin(to: ServerConfiguration.productionURL)
        })
        alert.addAction(UIAlertAction(title: "Use property.unitetheunion.org (LIVE)", style: .default) { [weak self] _ in
            self?.switchFromLogin(to: ServerConfiguration.legacyProductionURL)
        })
        present(alert, animated: true)
    }

    private func switchFromLogin(to target: String) {
        guard target != ServerConfiguration.shared.baseURL else { refreshEnvironmentChooser(); return }
        do {
            try CAFMServerSessionSwitch.switchTo(target)
            loginAttemptID = UUID() // Reject late replies from the previous server.
            tfPassword.text = nil
            tfEmail.text = nil
            view.endEditing(true)
            refreshEnvironmentChooser()
            EnvironmentBadge.shared.update(in: view.window)
        } catch {
            refreshEnvironmentChooser()
            let alert = UIAlertController(title: "Unable to change server",
                message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }

    @objc private func keyboardFrameChanged(_ notification: Notification) {
        guard let scroll = loginScrollView,
              let endFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardInView = view.convert(endFrame, from: nil)
        let covered = max(0, view.bounds.maxY - keyboardInView.minY)
        let panelArea = max(0, view.bounds.maxY - scroll.frame.maxY)
        let extraInset = max(0, covered - panelArea) + (covered > 0 ? 14 : 0)
        scroll.contentInset.bottom = extraInset
        scroll.verticalScrollIndicatorInsets.bottom = extraInset
        if covered > 0 {
            let focusedField: UITextField? = tfPassword.isFirstResponder ? tfPassword : (tfEmail.isFirstResponder ? tfEmail : nil)
            if let field = focusedField {
                let rect = field.convert(field.bounds, to: scroll).insetBy(dx: 0, dy: -16)
                scroll.scrollRectToVisible(rect, animated: true)
            }
        }
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.tfEmail {
            addBorderToView(self.tfEmail, width: 1, color: UIColor(appColor: .AppTint))
            addBorderToView(self.tfPassword, width: 1, color: UIColor(appColor: .GrayStatusBG))
        }else if textField == self.tfPassword {
            addBorderToView(self.tfPassword, width: 1, color: UIColor(appColor: .AppTint))
            addBorderToView(self.tfEmail, width: 1, color: UIColor(appColor: .GrayStatusBG))
        }
        return true
    }
    
    func initialViewSetup() {
        self.tfEmail.keyboardType = .emailAddress
        self.tfPassword.isSecureTextEntry = true
        self.tfPassword.textContentType = .password
        self.tfEmail.textContentType = .username
        
        self.titleLabel.font = UIFont(name: .MontserratBold, size: 20)
        self.emailLbl.font = UIFont(name: .MontserratRegular, size: 14)
        self.passwordLbl.font = UIFont(name: .MontserratRegular, size: 14)
        self.forgotPasswordLbl.font = UIFont(name: .MontserratRegular, size: 15)
        self.signInButton.titleLabel?.font = UIFont(name: .MontserratMedium, size: 15)

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: .MontserratRegular, size: 13) as Any,
            .foregroundColor: UIColor(appColor: .GrayText)
        ]
        self.tfPassword.attributedPlaceholder = NSAttributedString(string: "6+ Characters, 1 Capital letter", attributes: attributes)
        self.tfEmail.attributedPlaceholder = NSAttributedString(string: "Enter your email", attributes: attributes)

        addCornerToView(self.tfEmail, value: 7)
        addCornerToView(self.tfPassword, value: 7)
        addBorderToView(self.tfEmail, width: 1, color: UIColor(appColor: .GrayStatusBG))
        addBorderToView(self.tfPassword, width: 1, color: UIColor(appColor: .GrayStatusBG))
        addCornerToView(self.signInButton, value: 7)
        
        self.initialForgotPWSetup()
    }
    
    func initialForgotPWSetup() {
        let fullText = "Forgot Password? Click here"
        let clickableText = "Click here"
        let regularText = "Forgot Password?"
        
        // Create a mutable attributed string
        let attributedString = NSMutableAttributedString(string: fullText)
        
        // Apply color to "Forgot Password?"
        let regularTextColor = UIColor(appColor: .GrayText)
        let regularRange = (fullText as NSString).range(of: regularText)
        attributedString.addAttribute(.foregroundColor, value: regularTextColor, range: regularRange)

        // Apply color to "Click here"
        let clickableTextColor = UIColor(appColor: .AppTint)
        let clickableRange = (fullText as NSString).range(of: clickableText)
        attributedString.addAttribute(.foregroundColor, value: clickableTextColor, range: clickableRange)

        // Set the attributed text to the label
        self.forgotPasswordLbl.attributedText = attributedString
        
        self.setUpTapGestureToLabel()
    }
    
    func setUpTapGestureToLabel() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapOnClickHere(_:)))
        self.forgotPasswordLbl.isUserInteractionEnabled = true
        self.forgotPasswordLbl.addGestureRecognizer(tapGesture)
    }
    
    @objc func tapOnClickHere(_ gesture: UITapGestureRecognizer) {
        let fullText = "Forgot Password? Click here"
        let clickableText = "Click here"
        
        // Get the range of the clickable text
        let clickableRange = (fullText as NSString).range(of: clickableText)
        
        // Determine the position of the tap within the label
        if let label = gesture.view as? UILabel {
            let tapLocation = gesture.location(in: label)
            let labelSize = label.bounds.size
            let textStorage = NSTextStorage(attributedString: label.attributedText!)
            let layoutManager = NSLayoutManager()
            textStorage.addLayoutManager(layoutManager)
            let textContainer = NSTextContainer(size: labelSize)
            textContainer.lineFragmentPadding = 0
            textContainer.maximumNumberOfLines = label.numberOfLines
            textContainer.lineBreakMode = label.lineBreakMode
            layoutManager.addTextContainer(textContainer)
            let characterIndex = layoutManager.characterIndex(for: tapLocation, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
            
            // Check if the tap is within the clickable text range
            if NSLocationInRange(characterIndex, clickableRange) {
                let vc = storyboard?.instantiateViewController(withIdentifier: "ResetPasswordVC") as! ResetPasswordVC
                self.present(vc, animated: true)
            }
        }
    }
    
    func handleLoginSuccess() {
        // Get the current window
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        // Instantiate HomeVC
        let homeVC = generalSB.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
        
        // Create a new UINavigationController with HomeVC as the root
        let navigationController = UINavigationController(rootViewController: homeVC)
        
        // Replace the root view controller with HomeVC
        navigationController.delegate = sceneDelegate
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        EnvironmentBadge.shared.update(in: window)
    }
    
    @IBAction func signInButtonTapped(_ sender: UIButton) {
        guard let email = self.tfEmail.text, !email.isEmpty else {
            let sclAlertView = SCLAlertView()
            sclAlertView.showError("Error", subTitle: "Please enter your email.")
            return
        }
        
        guard let password = self.tfPassword.text, !password.isEmpty else {
            let sclAlertView = SCLAlertView()
            sclAlertView.showError("Error", subTitle: "Please enter your password.")
            return
        }
        
        // Validate email and password
        if !validateEmail(email) {
            let sclAlertView = SCLAlertView()
            sclAlertView.showError("Error", subTitle: "Please enter a valid email address.")
            return
        }
        
        if !validatePassword(password) {
            let sclAlertView = SCLAlertView()
            sclAlertView.showError("Error", subTitle: "Password must be at least 6 characters long and contain at least one uppercase letter.")
            return
        }
        
        let requestModel = LoginRequestModel()
        requestModel.password = password
        requestModel.email = email
        
        let loginServerAtStart = ServerConfiguration.shared.baseURL
        let attemptAtStart = loginAttemptID
        let loginService = ApiService.loginApi(model: requestModel)
                
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false // if you dont want the close button use false
        )
        let sclAlert = SCLAlertView(appearance: appearance)
        sclAlert.showWait("", subTitle: "Getting Everything Ready...", closeButtonTitle: "")
        APIClient.loginRequest(loginService) { (result: Result<APIClient.MappableResult<LoginUserDetail>, Error>) in
            // Ignore a late response from a server the user has since left.
            guard attemptAtStart == self.loginAttemptID &&
                  loginServerAtStart == ServerConfiguration.shared.baseURL else {
                sclAlert.hideView()
                return
            }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single(let loginDetail):
                    if let status = loginDetail.status, status == 401 {
                        sclAlert.hideView()
                        SCLAlertView().showError("Error", subTitle: "Please enter valid email and password.")
                    }else {
                        guard let token = loginDetail.jwtToken, !token.isEmpty else {
                            sclAlert.hideView()
                            SCLAlertView().showError("Login failed", subTitle: "The server did not return a login session.")
                            return
                        }
                        userEmailId = self.tfEmail.text
                        backUPUserEmailId = self.tfEmail.text
                        UserConstants.shared.currentUserID = loginDetail.user?.id
                        jwtToken = "JWTSESSIONID=" + token
                        guard jwtToken != nil else {
                            sclAlert.hideView()
                            SCLAlertView().showError("Login failed", subTitle: "Could not securely save the login session.")
                            return
                        }
                        sasToken = loginDetail.sasToken
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(Int(0.2))) {
                            sclAlert.hideView()
                            if let userRole = loginDetail.user?.role {
                                UserDefaults.standard.setValue(userRole, forKey: "UserRole")
                            }
                            let sclAlertView = SCLAlertView()
                            sclAlertView.showSuccess("", subTitle: "Success! Thanks for your effort, everything is complete.")
                            self.handleLoginSuccess()
                        }
                    }
                case .array:
                    sclAlert.hideView()
                    SCLAlertView().showError("Error", subTitle: "Oops! It looks like you're not logged in. Please sign in to continue.")
                    break
                }
            case .failure(let error):
                sclAlert.hideView()
                SCLAlertView().showError("Error", subTitle: "Oops! It looks like you're not logged in. Please sign in to continue.")
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
}

//validate user details
// Validate email format
func validateEmail(_ email: String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailPred.evaluate(with: email)
}

// Validate password requirements
func validatePassword(_ password: String) -> Bool {
    let capitalLetterRegEx = ".*[A-Z]+.*"
    let capitalLetterTest = NSPredicate(format: "SELF MATCHES %@", capitalLetterRegEx)
    return password.count >= 6 /*&& capitalLetterTest.evaluate(with: password)*/
}
