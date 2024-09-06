//
//  ActionBtnViewXIB.swift
//  cafm
//
//  Created by Savan Lakhani on 26/08/24.
//

import UIKit
import SpreadsheetView

class ActionBtnViewXIB: NibView {
    
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if let cancelBtn = cancelBtn {
            addCornerToView(cancelBtn)
        }
        
        if let saveBtn = saveBtn {
            addCornerToView(saveBtn)
        }
    }
    
    @IBAction func cancelBtnAction(_ sender: Any) {
        
    }
    
    @IBAction func saveBtnAction(_ sender: Any) {
        
    }
    
}
