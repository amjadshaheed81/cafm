//
//  SiteAssetsActionXIB.swift
//  cafm
//
//  Created by Savan Lakhani on 07/09/24.
//

import Foundation
import SpreadsheetView

class SiteAssetsActionXIB: Cell {
    
    @IBOutlet weak var qrImage: UIImageView!
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var viewButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var qrButton: UIButton!
    
    @IBOutlet weak var deleteView: DesignableCornerView!
    @IBOutlet weak var qrView: UIView!
    @IBOutlet weak var editView: DesignableCornerView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let userRole: UserEnum = UserDefaults.standard.userRole
        if !(userRole == .admin || userRole == .manager) {
            self.qrView.alpha = 0.0
            self.deleteView.alpha = 0.0
            self.editView.alpha = 0.0
        }
    }
    
}
