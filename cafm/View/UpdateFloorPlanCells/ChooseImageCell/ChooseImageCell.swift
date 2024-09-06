//
//  ChooseImageCell.swift
//  cafm
//
//  Created by NS on 31/08/24.
//
//

import UIKit
import SpreadsheetView

class ChooseImageCell: Cell {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var fileImageView: UIImageView!
    @IBOutlet weak var fileImageViewWidth: NSLayoutConstraint!
    @IBOutlet weak var fileNameLbl: UILabel!
    @IBOutlet weak var chooseFileBtn: UIButton!
    
    var chooseFileBtnAction: ((UIButton) -> Void)?
    
    @IBAction func chooseFileBtnClicked(_ sender: UIButton) {
        self.chooseFileBtnAction?(sender)
    }
    
}
