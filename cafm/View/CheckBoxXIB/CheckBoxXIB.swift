//
//  CheckBoxXIB.swift
//  cafm
//
//  Created by Savan Lakhani on 30/08/24.
//

import UIKit
import SpreadsheetView

class CheckBoxXIB: Cell {
    
    @IBOutlet weak var checkImageView: UIImageView!
    @IBOutlet weak var checkImageHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.checkImageHeight.constant = 40.0
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.backgroundColor = .clear
    }
    
}
