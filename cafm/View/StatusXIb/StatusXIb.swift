//
//  StatusXIb.swift
//  cafm
//
//  Created by ShitaRam on 19/08/24.
//

import SpreadsheetView
import UIKit

class StatusXIb: Cell {
    
    
    @IBOutlet weak var activeView: DesignableCornerView!
    
    @IBOutlet weak var inactiveView: DesignableCornerView!
    
    
    @IBOutlet weak var lblActive: UILabel!
    
    @IBOutlet weak var lblInactive: UILabel!
    
    func setUp(string: String) {
        let font = UIFont(name: .MontserratBold, size: textFontSize)
        lblActive.font = font
        lblInactive.font = font
        switch string.lowercased() {
        case "active", "open", "sold", "awarded", "pending":
            lblActive.text = string.capitalized
            lblActive.backgroundColor = .clear
            activeView.isHidden = false
            inactiveView.isHidden = true
        case "closed", "expired", "rejected":
            lblActive.text = string.capitalized
            lblActive.backgroundColor = .red
            activeView.isHidden = false
            inactiveView.isHidden = true
        case "terminated", "recieved":
            lblActive.text = string.capitalized
            lblActive.backgroundColor = inactiveView.backgroundColor
            activeView.isHidden = false
            inactiveView.isHidden = true
        default:
            activeView.isHidden = true
            inactiveView.isHidden = false
        }
    }
    
}
