//
//  ResetPasswordVC.swift
//  cafm
//
//  Created by Savan Lakhani on 18/08/24.
//

import UIKit

class ResetPasswordVC : UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var resetBtn: UIButton!
    
    @IBOutlet weak var tfEmail: UITextField!
    
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tfEmail.delegate = self
        self.initialViewSetup()
    }
    
    func initialViewSetup() {
        self.titleLbl.font = UIFont(name: .MontserratBold, size: 20)
        self.emailLbl.font = UIFont(name: .MontserratRegular, size: 14)
        self.descLbl.font = UIFont(name: .MontserratMedium, size: 17)
        self.resetBtn.titleLabel?.font = UIFont(name: .MontserratMedium, size: 16)

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: .MontserratRegular, size: 13) as Any,
            .foregroundColor: UIColor(appColor: .GrayText)
        ]

        self.tfEmail.attributedPlaceholder = NSAttributedString(string: "Enter your email", attributes: attributes)
        addCornerToView(self.tfEmail, value: 7)
        addBorderToView(self.tfEmail, width: 1, color: UIColor(appColor: .GrayStatusBG))
        addCornerToView(self.resetBtn, value: 7)
    }
    
    @IBAction func resetPasswordClick(_ sender: Any) {
        
        
    }
    
}
