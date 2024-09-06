//
//  SSTextFieldCell.swift
//  cafm
//
//  Created by NS on 04/09/24.
//
//

import UIKit
import SpreadsheetView

class SSTextFieldCell: Cell {
    
    @IBOutlet weak var mainView: DesignableView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var rightSideView: UIView!
    @IBOutlet weak var rightSideViewWidth: NSLayoutConstraint!
    @IBOutlet weak var rightSideImageView: UIImageView!
    @IBOutlet weak var actionBtn: UIButton!
    
    var isViewModeEdit: Bool = true
    
    let rolesArray = [
        "",
        "Admin Property Manager",
        "Site Action Manager",
        "Site users",
        "Care Taker",
        "Contracter",
        "Surveyor",
        "Tradesman",
        "Electrician",
        "Gas Engineer",
        "Asbestos Surveyor",
        "AC Engineer",
        "Fire Door Install",
        "General Company",
        "Life Maintenance",
        "Plumber",
        "Auto Door Maintenance",
        "Refuse Collector",
        "Fire Alarm",
        "Asbestos Surveyor"
    ]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.textField.font = UIFont(name: .MontserratRegular, size: 14)
    }
    
    func hideAllViews() {
        self.textField.isHidden = true
        self.rightSideView.isHidden = true
        self.actionBtn.isHidden = true
    }
    
    func hideRightSideViews() {
        let rightSideViewWidth: CGFloat = 15
        self.rightSideViewWidth.constant = rightSideViewWidth
        self.rightSideView.frame.size.width = rightSideViewWidth
        self.rightSideImageView.isHidden = true
    }
    
    func setupTextField() {
        self.hideRightSideViews()
        self.textField.isHidden = false
        self.textField.isUserInteractionEnabled = self.isViewModeEdit
        self.actionBtn.isHidden = true
    }
    
    func setupDropDownMenu() {
        self.setupActionBtnForMenu()
        self.textField.isHidden = false
        let rightSideViewWidth: CGFloat = 10+20+10
        self.rightSideViewWidth.constant = rightSideViewWidth
        self.rightSideView.frame.size.width = rightSideViewWidth
        self.rightSideImageView.isHidden = false
        self.actionBtn.isHidden = false
        self.textField.isUserInteractionEnabled = false
    }
    
    func setupActionBtnForMenu() {
        guard self.isViewModeEdit else { return }
        self.actionBtn.menu = self.roleSelectionMenu()
        self.actionBtn.showsMenuAsPrimaryAction = true
        self.actionBtn.removeTarget(self, action: #selector(self.actionBtnClicked(_:)), for: .menuActionTriggered)
        self.actionBtn.addTarget(self, action: #selector(self.actionBtnClicked(_:)), for: .menuActionTriggered)
    }
    
    @IBAction func textFieldTextDidChange(_ sender: UITextField) {
        
    }
    
    @objc func actionBtnClicked(_ sender: UIButton) {
        self.actionBtn.menu = self.roleSelectionMenu()
        self.actionBtn.showsMenuAsPrimaryAction = true
    }
    
    func roleSelectionMenu() -> UIMenu {
        var actions: [UIMenuElement] = []
        for value in self.rolesArray {
            let action = UIAction(title: "\(value)", state: keyContactsRole == value ? .on : .off) { [weak self] _ in
                guard let strongSelf = self else { return }
                keyContactsRole = value
                strongSelf.textField.text = value
            }
            actions.append(action)
        }
        return UIMenu(children: actions)
    }
    
}
