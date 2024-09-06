//
//  NibView.swift
//  cafm
//
//  Created by NS on 18/08/24.
//
//

import UIKit

class NibView: UIView {
    
    private var view: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNib()
    }
    
    func loadNib() {
        let bundle = Bundle(for: Self.self)
        view = UINib(nibName: String(describing: type(of: self)), bundle: bundle).instantiate(withOwner: self).first as? UIView
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.frame = bounds
        addSubview(view)
    }
    
}
