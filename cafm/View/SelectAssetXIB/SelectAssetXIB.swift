//
//  SelectAssetXIB.swift
//  cafm
//
//  Created by Savan Lakhani on 15/09/24.
//

import UIKit
import SpreadsheetView

class SelectAssetXIB: Cell {
    
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var selectAssetLbl: UILabel!
    @IBOutlet weak var closeIcon: UIImageView!
    @IBOutlet weak var downArrow: UIImageView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var downArrowBtn: UIButton!
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var arrowWidthCons: NSLayoutConstraint!
    @IBOutlet weak var closeIconWidthCons: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.mainView.addBorder(color: .gray.withAlphaComponent(0.3))
        self.mainView.addCorner()
        self.selectAssetLbl.font = UIFont(name: .MontserratRegular, size: 12)
    }
    
}


