//
//  UserActionCellXib.swift
//  cafm
//
//  Created by ShitaRam on 29/09/24.
//

import UIKit
import SpreadsheetView

class UserActionCellXib: Cell {
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var btnView: UIButton!
    @IBOutlet weak var btnEditView: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var btnLock: UIButton!
    
    @IBOutlet weak var lockImageView: UIImageView!
    @IBOutlet weak var deleteImageView: UIImageView!
    @IBOutlet weak var pencilImageView: UIImageView!
    @IBOutlet weak var eyeImageView: UIImageView!
    
    @IBOutlet weak var lockView: DesignableCornerView!
    @IBOutlet weak var deleteView: DesignableCornerView!
    @IBOutlet weak var editView: DesignableCornerView!
    @IBOutlet weak var view: DesignableCornerView!
        
    @IBOutlet weak var stackViewRightCons: NSLayoutConstraint!
    @IBOutlet weak var stackViewLeftCons: NSLayoutConstraint!
    @IBOutlet weak var stackViewHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.stackViewHeight.isActive = false
    }
    
}
