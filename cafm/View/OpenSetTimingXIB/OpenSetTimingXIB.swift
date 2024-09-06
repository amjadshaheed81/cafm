//
//  OpenSetTimingXIB.swift
//  cafm
//
//  Created by Savan Lakhani on 30/08/24.
//

import Foundation
import SpreadsheetView

class OpenSetTimingXIB: Cell {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var actionBtn: UIButton!
    @IBOutlet weak var clockImg: UIImageView!
    @IBOutlet weak var timeDetailLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.mainView.addCorner(value: 8)
        self.mainView.addBorder(width: 1,color: .gray)
    }
    
}
