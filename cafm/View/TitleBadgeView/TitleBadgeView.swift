//
//  TitleBadgeView.swift
//  cafm
//
//  Created by NS on 17/09/24.
//
//

import UIKit

class TitleBadgeView: NibView {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var titleLbl: DefaultFontLabel!
    @IBOutlet weak var badgeView: UIView!
    @IBOutlet weak var badgeViewWidth: NSLayoutConstraint!
    @IBOutlet weak var badgeViewHeight: NSLayoutConstraint!
    
    weak var badgeXIB: BadgeLabelCell!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupBadgeXIB()
    }
    
    func setupBadgeXIB() {
        let nib = UINib(nibName: BadgeLabelCell.className(), bundle: nil)
        if let view = nib.instantiate(withOwner: nil, options: nil).first as? BadgeLabelCell {
            view.autoresizingMask = [
                //.flexibleLeftMargin,
                .flexibleWidth,
                //.flexibleRightMargin,
                //.flexibleTopMargin,
                .flexibleHeight,
                //.flexibleBottomMargin,
            ]
            view.frame = self.badgeView.bounds
            self.badgeView.addSubview(view)
            self.badgeXIB = view
        }
    }
    
    func setBadgeData(text: String?, font: UIFont? = UIFont(name: .MontserratSemiBold, size: dashboardPrimaryTextSize), textColor: UIColor? = UIColor(appColor: .AppTint) , bgColor: UIColor? = UIColor(appColor: .AppTintBG), maxWidth: CGFloat = 100, roundedCorner: Bool = true) {
        guard let view = self.badgeXIB else { return }
        if text == nil {
            self.badgeViewWidth.constant = CGFloat.zero
            self.badgeView.frame.size.width = self.badgeViewWidth.constant
            self.badgeViewHeight.constant = CGFloat.zero
            self.badgeView.frame.size.height = self.badgeViewHeight.constant
            self.badgeView.isHidden = true
            return
        }
        
        view.mainLbl.font = font
        view.badgeView.backgroundColor = bgColor
        view.mainLbl.textColor = textColor
        view.mainLbl.text = text
        
        let size = getLabelSize(text: view.mainLbl.text, font: view.mainLbl.font, minWidth: 20, widthAddition: 12+8+8+12, maxWidth: maxWidth, minHeight: 20, heightAddition: 10+4+4+10)
        self.badgeViewWidth.constant = size.width
        self.badgeView.frame.size.width = self.badgeViewWidth.constant
        self.badgeViewHeight.constant = size.height
        self.badgeView.frame.size.height = self.badgeViewHeight.constant
        self.badgeView.isHidden = false
        view.frame = self.badgeView.bounds
        view.badgeView.addCorner(value: roundedCorner ? view.badgeView.frame.height/2 : 5)
    }
    
}
