//
//  ChooseFileCapsuleXIB.swift
//  cafm
//
//  Created by NS on 07/09/24.
//
//

import UIKit

class ChooseFileCapsuleXIB: NibView {
    
    @IBOutlet weak var fileNameLbl: UILabel!
    @IBOutlet weak var chooseFileBtn: UIButton!
    
    var chooseFileBtnAction: ((UIButton) -> Void)?
    
    @IBAction func chooseFileBtnClicked(_ sender: UIButton) {
        self.chooseFileBtnAction?(sender)
    }
    
}
