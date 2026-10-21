//
//  SceneDelegate.swift
//  cafm
//
//  Created by ShitaRam on 17/08/24.
//

import UIKit

let isNeedLogOutKey = "isNeedLogOutForPro"
var isNeedLogOut: Bool {
    get {
        if UserDefaults.standard.value(forKey: isNeedLogOutKey) == nil {
            return true
        }
        return false
    }set {
        UserDefaults.standard.setValue(false, forKey: isNeedLogOutKey)
    }
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Ensure we have a window scene
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Create the UIWindow using the windowScene
        let window = UIWindow(windowScene: windowScene)
        
        // Instantiate the storyboard and the view controller
        let vc: UIViewController
        if isNeedLogOut {
            isNeedLogOut = false
            userEmailId = nil
            userPassword = nil
            jwtToken = nil
            sasToken = nil
        }
        if userEmailId == nil, userPassword == nil {
            vc = loginSB.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        }else {
            backUPUserEmailId = userEmailId
            backUPUserPassword = userPassword
            vc = generalSB.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
        }
        
        // Embed the view controller in a UINavigationController
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.delegate = self
        //navigationController.navigationBar.isHidden = true
        
        // Set the navigation controller as the root view controller of the window
        window.rootViewController = navigationController
        
        // Set the window as key and visible
        self.window = window
        self.window?.makeKeyAndVisible()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        
        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
    
    
}

extension SceneDelegate: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController is LoginVC {
            navigationController.navigationBar.isHidden = true
        }else {
            navigationController.navigationBar.isHidden = false
        }
    }
    
}
