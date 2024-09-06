//
//  EmptyView.swift
//  cafm
//
//  Created by NS on 26/08/24.
//  
//

import UIKit

class EmptyView: NibView {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var mainLbl: DefaultFontLabel!
    @IBOutlet weak var actionBtn: UIButton!
    
    weak var delegate: EmptyViewDelegate?
    
    @IBAction func actionBtnClicked(_ sender: UIButton) {
        self.delegate?.emptyViewDidTapView(self)
    }
}

protocol EmptyViewDelegate: AnyObject {
    func emptyViewDidTapView(_ view: EmptyView)
}
