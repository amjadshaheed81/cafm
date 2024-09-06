//
//  CreateSiteKeyContactXIB.swift
//  cafm
//
//  Created by Savan Lakhani on 27/08/24.
//

import UIKit
import SpreadsheetView

class CreateSiteKeyContactXIB: Cell {
    
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
    
    @IBOutlet weak var addRowBtn: UIButton!
    @IBOutlet weak var btnLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var downArrow: UIImageView!
    @IBOutlet weak var txField: UITextField!
    
    @IBOutlet weak var deleteTralingCons: NSLayoutConstraint!
    @IBOutlet weak var deleteViewWidth: NSLayoutConstraint!
    @IBOutlet weak var deleteView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addCornerToView(self.addRowBtn, value: 6)
        addCornerToView(self.deleteView, value: 6)
        addRowBtn.addShadow()
        setUpDropDownMenu()
        self.actionButton.titleLabel?.textColor = .clear
        self.btnLabel.textAlignment = .left
        self.btnLabel.font = UIFont(name: .MontserratMedium, size: 18)
        self.deleteView.isHidden = true
        self.deleteViewWidth.constant = 0.0
        self.deleteTralingCons.constant = 0.0
    }
    
    func setUpDropDownMenu() {
        guard !self.rolesArray.isEmpty else { return }
        
        let actionClosure = { (action: UIAction) in
            self.btnLabel.text = action.title
            self.btnLabel.adjustsFontSizeToFitWidth = true
            keyContactsRole = action.title
            self.actionButton.setTitle("", for: .normal)
       }
        
        let menuChildren = self.rolesArray.map { item in
            UIAction(title: item, handler: actionClosure)
        }
        
        let menu = UIMenu(options: .displayInline, children: menuChildren)
        self.actionButton.menu = menu
        self.actionButton.showsMenuAsPrimaryAction = true
        
        if #available(iOS 15.0, *) {
            self.actionButton.changesSelectionAsPrimaryAction = true
        } else {
            self.actionButton.addTarget(self, action: #selector(handleSelection(_:)), for: .touchUpInside)
        }
    }
    
    @objc func handleSelection(_ sender: UIButton) {
        if let menu = sender.menu {
            sender.menu = menu
            sender.showsMenuAsPrimaryAction = true
            sender.sendActions(for: .touchUpInside)
        }
    }
    
}
