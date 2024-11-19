//
//  DeleteActionXIB.swift
//  cafm
//
//  Created by Savan Lakhani on 15/09/24.
//

import UIKit
import SpreadsheetView

class DeleteActionXIB: Cell {
    
    @IBOutlet weak var stackView: UIStackView!

    @IBOutlet weak var deleteMainView: UIView!
    @IBOutlet weak var deleteView: DesignableCornerView!
    @IBOutlet weak var deleteImageView: UIImageView!
    @IBOutlet weak var deleteAction: UIButton!
    
    @IBOutlet weak var checkMainView: UIView!
    @IBOutlet weak var checkImageView: UIImageView!
    @IBOutlet weak var checkActionBtn: UIButton!
    @IBOutlet weak var checkSubView: DesignableCornerView!
    @IBOutlet weak var checkImageHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        self.deleteView.addCorner()
        self.deleteImageView.image?.withRenderingMode(.alwaysTemplate)
        self.deleteImageView.tintColor = .red
        self.deleteView.isUserInteractionEnabled = false
        
//        self.checkSubView.addCorner()
//        self.checkSubView.addBorder(color: .gray)
        self.checkSubView.tintColor = UIColor(appColor: .AppTintBG)
        self.checkSubView.isUserInteractionEnabled = false
    }
    
}
