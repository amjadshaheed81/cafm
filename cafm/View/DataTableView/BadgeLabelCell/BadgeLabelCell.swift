//
//  BadgeLabelCell.swift
//  cafm
//
//  Created by NS on 25/08/24.
//  
//

import UIKit
import SpreadsheetView

class BadgeLabelCell: Cell {
    
    @IBOutlet weak var badgeView: UIView!
    @IBOutlet weak var mainLbl: DefaultFontLabel!
    
    private var view: UIView!

    func loadNib() {
        let bundle = Bundle(for: Self.self)
        view = UINib(nibName: String(describing: type(of: self)), bundle: bundle).instantiate(withOwner: self).first as? UIView
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.frame = bounds
        addSubview(view)
    }
    
}
