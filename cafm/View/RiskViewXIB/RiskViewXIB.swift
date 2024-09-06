//
//  RiskViewXIB.swift
//  cafm
//
//  Created by Savan Lakhani on 25/08/24.
//

import UIKit
import SpreadsheetView

class RiskViewXIB: Cell {
    
    @IBOutlet weak var greenRiskLbl: UILabel!
    @IBOutlet weak var yelloriskLbl: UILabel!
    @IBOutlet weak var amberRiskLbl: UILabel!
    @IBOutlet weak var redRiskLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        [greenRiskLbl,
         yelloriskLbl,
         amberRiskLbl,
         redRiskLbl,].forEach { label in
            label.font = UIFont(name: .MontserratSemiBold, size: textFontSize + 2)
            addCornerToView(label, value: 7)
        }
    }
    
}
