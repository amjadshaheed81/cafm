//
//  LoginVC.swift
//  cafm
//
//  Created by ShitaRam on 17/08/24.
//

import UIKit
import SCLAlertView

class LoginVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet var tfPassword: UITextField!
    
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var passwordLbl: UILabel!
    @IBOutlet weak var forgotPasswordLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tfEmail.delegate = self
        self.tfPassword.delegate = self
        self.initialViewSetup()
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
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
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
        
        let loginService = ApiService.loginApi(model: requestModel)
                
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false // if you dont want the close button use false
        )
        let sclAlert = SCLAlertView(appearance: appearance)
        sclAlert.showWait("", subTitle: "Getting Everything Ready...", closeButtonTitle: "")
        APIClient.loginRequest(loginService) { (result: Result<APIClient.MappableResult<LoginUserDetail>, Error>) in
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single(let loginDetail):
                    if let status = loginDetail.status, status == 401 {
                        sclAlert.hideView()
                        SCLAlertView().showError("Error", subTitle: "Please enter valid email and password.")
                    }else {
                        userEmailId = self.tfEmail.text
                        userPassword = self.tfPassword.text
                        UserConstants.shared.currentUserID = loginDetail.user?.id
                        jwtToken = "JWTSESSIONID="+(loginDetail.jwtToken ?? "")
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
