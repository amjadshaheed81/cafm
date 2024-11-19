//
//  ToastView.swift
//  cafm
//
//  Created by Savan Lakhani on 17/09/24.
//

import UIKit

class ToastView: NibView {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        addCornerToView(self.mainView, value: 8)
        addShadowToView(self.contentView, color: UIColor.lightGray, opacity: 0.4, offset: CGSize(width: 0.0, height: 0.0), radius: 5)
        self.messageLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
    }
    
}

extension UIViewController {
    func showToast(message: String) {
        self.view.subviews.filter({ $0 is ToastView }).forEach({ $0.removeFromSuperview() })
        
        let toastLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 50))
        toastLabel.text = message
        toastLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        toastLabel.textAlignment = .center
        toastLabel.sizeToFit()
        
        var width = 20+toastLabel.bounds.width+20
        
        let toast = ToastView(frame: CGRect(x: (self.view.frame.size.width-width)/2, y: self.view.frame.size.height, width: width, height: 50))
        if toast.frame.origin.x < 8 {
            toast.frame.origin.x = 8
        }
        if toast.frame.width >= screenWidth {
            toast.frame.size.width = screenWidth - 15
        }
        toast.messageLabel.text = message
        toast.messageLabel.adjustsFontSizeToFitWidth = true
        addShadowToView(toast, color: UIColor.black.withAlphaComponent(0.2), opacity: 1, offset: .zero, radius: 5)
        self.view.addSubview(toast)
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut) {
            toast.frame.origin.y = self.view.frame.size.height-(toast.frame.height+70+bottomSafeArea)
        } completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now()+1.0, execute: { [weak self] in
                guard let _ = self else { return }
                UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn) {
                    toast.alpha = 0.0
                } completion: { _ in
                    toast.removeFromSuperview()
                }
            })
        }
    }
}
