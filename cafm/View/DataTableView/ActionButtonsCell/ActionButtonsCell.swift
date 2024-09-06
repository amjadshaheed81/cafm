//
//  ActionButtonsCell.swift
//  cafm
//
//  Created by NS on 26/08/24.
//  
//

import UIKit
import SpreadsheetView

class ActionButtonsCell: Cell {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.stackView.addShadow(color: UIColor.lightGray, opacity: 0.4, radius: 2)
    }
}

func getActionButton(size: CGSize, tag: Int, image: UIImage?, target: Any?, action: Selector) -> ActionButton {
    let btn = ActionButton(frame: CGRect(origin: CGPoint.zero, size: size))
    btn.tag = tag
    btn.setImage(image?.applyingSymbolConfiguration(UIImage.SymbolConfiguration(scale: .medium)), for: .normal)
    btn.addTarget(target, action: action, for: .touchUpInside)
    
    btn.widthAnchor.constraint(equalToConstant: size.width).isActive = true
    btn.heightAnchor.constraint(equalToConstant: size.height).isActive = true
    return btn
}

class ActionButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }
    
    func setup() {
        self.backgroundColor = UIColor(appColor: .BG1)
        self.tintColor = UIColor(appColor: .PrimaryText)
        self.addCorner()
        self.addBorder(color: UIColor(appColor: .Separator2))
    }
    
}
