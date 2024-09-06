//
//  SiteViewXib.swift
//  cafm
//
//  Created by ShitaRam on 19/08/24.
//

import UIKit
import SpreadsheetView

class SiteViewXib: Cell {
    
    
    
    @IBOutlet weak var site3View: UIView!
    
    @IBOutlet weak var lbl1View: DesignableCornerView!
    @IBOutlet weak var lbl1Text: UILabel!
    
    @IBOutlet weak var lbl1Height: NSLayoutConstraint!
    
    @IBOutlet weak var lbl1Btn: UIButton!
    
    @IBOutlet weak var lbl2Btn: UIButton!
    
    
    @IBOutlet weak var lbl3Btn: UIButton!
    
    @IBOutlet weak var bottom1View: NSLayoutConstraint!
    
    
    
    @IBOutlet weak var lbl2View: DesignableCornerView!
    
    @IBOutlet weak var lbl2Text: UILabel!
    @IBOutlet weak var lbl2Height: NSLayoutConstraint!
    
    @IBOutlet weak var bottom2View: NSLayoutConstraint!
    
    
    @IBOutlet weak var lbl3View: DesignableCornerView!
    
    @IBOutlet weak var lbl3Text: UILabel!
    
    @IBOutlet weak var lbl3Height: NSLayoutConstraint!
    
    
    
    func setUpSite(stringsArray: [String]) {
        site3View.isHidden = false
        let font = UIFont(name: .MontserratBold, size: textFontSize)
        lbl1Text.font = font
        lbl2Text.font = font
        lbl3Text.font = font
        if stringsArray.count == 0 {
            site3View.isHidden = true
        }else if stringsArray.count > 3 {
            lbl2View.isHidden = false
            lbl2Height.constant = 32
            lbl1Text.text = "\(stringsArray.count) Sites"
            bottom1View.constant = 0
            bottom2View.constant = 0
            
            lbl2View.isHidden = true
            lbl2Height.constant = 0
            lbl3View.isHidden = true
            lbl3Height.constant = 0
        }else if stringsArray.count == 1 {
            lbl2View.isHidden = false
            lbl2Height.constant = 32
            lbl1Text.text = stringsArray[0]
            bottom1View.constant = 0
            bottom2View.constant = 0

            
            lbl2View.isHidden = true
            lbl2Height.constant = 0
            lbl3View.isHidden = true
            lbl3Height.constant = 0
        }else if stringsArray.count == 2 {
            lbl1View.isHidden = false
            lbl1Height.constant = 32
            lbl1Text.text = stringsArray[0]
            bottom1View.constant = 5
            bottom2View.constant = 0

            
            lbl2View.isHidden = false
            lbl2Height.constant = 32
            lbl2Text.text = stringsArray[1]
            
            lbl3View.isHidden = true
            lbl3Height.constant = 0
        }else if stringsArray.count == 3 {
            lbl2View.isHidden = false
            lbl2Height.constant = 32
            lbl1Text.text = stringsArray[0]
            bottom1View.constant = 5
            bottom2View.constant = 5

            
            lbl2View.isHidden = false
            lbl2Height.constant = 32
            lbl2Text.text = stringsArray[1]

            lbl3View.isHidden = false
            lbl3Height.constant = 32
            lbl3Text.text = stringsArray[2]
        }
    }
        
}
