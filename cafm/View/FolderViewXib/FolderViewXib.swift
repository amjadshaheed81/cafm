//
//  FolderViewXib.swift
//  cafm
//
//  Created by ShitaRam on 31/08/24.
//

import Foundation
import SpreadsheetView

class FolderViewXib: Cell {
    
    @IBOutlet weak var lblFolderName: UILabel!
    @IBOutlet weak var btnFolder: UIButton!
    
    @IBOutlet weak var consLeadingFolder: NSLayoutConstraint!
    
    @IBOutlet weak var imgFolder: UIImageView!
    
    func setUpFolderView(isSubFolder: Bool) {
        imgFolder.image = isSubFolder ? UIImage(systemName: "folder") : UIImage(systemName: "folder.fill")
        consLeadingFolder.constant = isSubFolder ? 15+5 : 5
    }
    
    func setUpDocView(isForVersionHistory : Bool = false) {
        imgFolder.image = UIImage(systemName: "doc.text")
        if isForVersionHistory {
            consLeadingFolder.constant = 5
        }else {
            consLeadingFolder.constant = 15+5
        }
    }
    
}
