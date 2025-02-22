//
//  HomeVC.swift
//  cafm
//
//  Created by NS on 19/08/24.
//
//

import UIKit
import LocalAuthentication

class HomeVC: UIViewController, UITabBarDelegate {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tabBar: UITabBar!
    
    weak var vc1: DashboardVC!
    weak var vc2: EventCalendarContainerVC!
    
    var selectedTabIndex: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureNavigationBar()
        
        self.tabBar.delegate = self
        
        self.selectTabBarItem(index: self.selectedTabIndex)
        
//        authenticateUser()
    }
    
    // Biometric authentication method
    func authenticateUser() {
        let context = LAContext()
        var error: NSError?

        // Check if biometric authentication is available
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Authenticate to access your app") { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        // Authentication successful
                        self.showMainContent() // Example: show main content
                    } else {
                        // Authentication failed
                        self.showError(message: "Authentication failed. Please try again.")
                    }
                }
            }
        } else {
            // No biometrics available, fallback to passcode
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Authenticate to access your app") { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self.showMainContent()
                    } else {
                        self.showError(message: "Authentication failed. Please try again.")
                    }
                }
            }
        }
    }

    func showMainContent() {
        // Proceed to the main screen
        print("Authentication successful!")
    }

    func showError(message: String) {
        // Handle authentication failure (e.g., show an alert)
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.navLogOutBtnClicked(UIBarButtonItem())
            }
        }))
        present(alert, animated: true, completion: nil)
    }

    
    func configureNavigationBar() {
        //        self.title = "Welcome"
        self.configureNavigationBackButton()
        
        let settingBtn = UIBarButtonItem(image: UIImage(systemName: "gearshape.fill"), style: .plain, target: self, action: #selector(self.navSettingBtnClicked(_:)))
        self.navigationItem.leftBarButtonItems = [settingBtn]
        
        let notificationBtn = UIBarButtonItem(image: UIImage(systemName: "bell"), style: .plain, target: self, action: #selector(self.navNotificationBtnClicked(_:)))
        let logOutBtn = UIBarButtonItem(image: UIImage(systemName: "rectangle.portrait.and.arrow.right"), style: .plain, target: self, action: #selector(self.navLogOutBtnClicked(_:)))
        self.navigationItem.rightBarButtonItems = [logOutBtn, notificationBtn]
    }
    
    @objc func navSettingBtnClicked(_ sender: UIBarButtonItem) {
        let vc = generalSB.instantiateViewController(withIdentifier: "SettingsVC") as! SettingsVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func navNotificationBtnClicked(_ sender: UIBarButtonItem) {
        //TODO: RK - Open Notification Screen
        let vc = notificationSB.instantiateViewController(withIdentifier: "NotificationListVC") as! NotificationListVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func navLogOutBtnClicked(_ sender: UIBarButtonItem) {
        UserConstants.shared.logoutUser()
        
        let vc = loginSB.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.delegate = sceneDelegate
        sceneDelegate.window?.rootViewController = navigationController
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        self.selectTabBarItem(index: item.tag)
    }
    
    /// index is one-based
    func selectTabBarItem(index: Int) {
        if let item = self.tabBar.items?.first(where: { $0.tag == index }) {
            self.tabBar.selectedItem = item
        }
        switch index {
        case 1:
            self.selectedTabIndex = index
            if vc1 == nil {
                self.vc1 = generalSB.instantiateViewController(withIdentifier: "DashboardVC") as? DashboardVC
                self.vc1.homeVC = self
                add(childVC: self.vc1, to: self.containerView)
                self.vc1.view.isHidden = true
            }
            showViewController(self.vc1)
            break
        case 2:
            self.selectedTabIndex = index
            if vc2 == nil {
                self.vc2 = generalSB.instantiateViewController(withIdentifier: "EventCalendarContainerVC") as? EventCalendarContainerVC
                add(childVC: self.vc2, to: self.containerView)
                self.vc2.view.isHidden = true
            }
            showViewController(self.vc2)
            break
        default:
            break
        }
    }
    
}
