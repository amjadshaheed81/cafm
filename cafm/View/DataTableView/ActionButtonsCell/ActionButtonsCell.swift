//
//  ActionButtonsCell.swift
//  cafm
//
//  Created by NS on 26/08/24.
//  
//

import UIKit
import SpreadsheetView

class ActionButtonsCell: Cell {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet private weak var stackViewLeading: NSLayoutConstraint!
    @IBOutlet private weak var stackViewCenterX: NSLayoutConstraint!
    
    var isCenterHorizontally: Bool = false {
        didSet {
            self.stackViewLeading.isActive = !isCenterHorizontally
            self.stackViewCenterX.isActive = isCenterHorizontally
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.stackView.addShadow(color: UIColor.lightGray, opacity: 0.4, radius: 2)
    }
}
