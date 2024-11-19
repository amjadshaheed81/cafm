//
//  UIViewController+Extension.swift
//  cafm
//
//  Created by NS on 24/08/24.
//  
//

import UIKit

//MARK: Container Helper
extension UIViewController {
    
    func add(childVC viewController: UIViewController, to containerView: UIView) {
        viewController.willMove(toParent: self)
        addChild(viewController)
        containerView.addSubview(viewController.view)
        viewController.view.frame = containerView.bounds
        viewController.didMove(toParent: self)
    }
    
    func removeFromContainer() {
        guard parent != nil else { return }
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
        didMove(toParent: nil)
    }
    
    func showViewController(_ viewController: UIViewController) {
        for child in children {
            child.view.isHidden = true
        }
        viewController.view.isHidden = false
    }
    
}

//MARK: Navigation Helper
extension UIViewController {
    var navigationHeight: CGFloat {
        return self.navigationController?.navigationBar.frame.height ?? 44
    }
    
    func configureNavigationBackButton() {
        if #available(iOS 14.0, *) {
            self.navigationItem.backButtonDisplayMode = .minimal
        }
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
    }
    
    func changeNavigationBarAppearance(appDefault: Bool = true, backgroundColor: UIColor = UIColor.white, tintColor: UIColor = UIColor(appColor: .AppTint)) {
        if appDefault {
            self.navigationController?.navigationBar.tintColor = UIColor(appColor: .AppTint)
            self.navigationController?.navigationBar.titleTextAttributes = navTitleTextAttributes
        }else {
            self.navigationController?.navigationBar.tintColor = tintColor
            var titleTextAttributes = navTitleTextAttributes
            titleTextAttributes[.foregroundColor] = tintColor
            self.navigationController?.navigationBar.titleTextAttributes = titleTextAttributes
        }
    }

}

extension UIViewController {
    
    func getPresentedVC<T: UIViewController>(ofType type: T.Type) -> T? {
        return (self.presentedViewController as? UINavigationController)?.viewControllers.first(where: { $0 is T }) as? T
    }
    
}
