//
//  TableViewCells.swift
//  cafm
//
//  Created by NS on 19/08/24.
//  
//

import UIKit

class EventCalendarTableCell: UITableViewCell {
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var mainLbl: UILabel!
    
}

class SearchSiteCell: UITableViewCell {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var favoriteImageView: UIImageView!
    @IBOutlet weak var siteImageContainerView: UIView!
    @IBOutlet weak var siteImageView: UIImageView!
    @IBOutlet weak var siteImageViewWidth: NSLayoutConstraint!
    @IBOutlet weak var siteNameLbl: DefaultFontLabel!
    @IBOutlet weak var siteIDLbl: DefaultFontLabel!
    
    var favoriteClickAction: ((UIView) -> Void)?
    
    func setSiteImageViewHidden(_ isHidden: Bool) {
        let width: CGFloat = isHidden ? 0.0 : 45.0
        self.siteImageViewWidth.constant = width
        self.siteImageContainerView.frame.size.width = width
        self.siteImageContainerView.isHidden = isHidden
    }
    
    @IBAction func favoriteViewClicked(_ sender: UIView) {
        self.favoriteClickAction?(sender)
    }
    
}

class TitleBadgeTableCell: UITableViewCell {
    
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
    
    func setBadgeData(text: String?, font: UIFont? = UIFont(name: .MontserratSemiBold, size: dashboardPrimaryTextSize), textColor: UIColor? = UIColor(appColor: .AppTint) , bgColor: UIColor? = UIColor(appColor: .AppTintBG)) {
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
        
        let size = getLabelSize(text: view.mainLbl.text, font: view.mainLbl.font, minWidth: 20, widthAddition: 12+8+8+12, maxWidth: 100, minHeight: 20, heightAddition: 10+4+4+10)
        self.badgeViewWidth.constant = size.width
        self.badgeView.frame.size.width = self.badgeViewWidth.constant
        self.badgeViewHeight.constant = size.height
        self.badgeView.frame.size.height = self.badgeViewHeight.constant
        view.frame = self.badgeView.bounds
        view.badgeView.addCorner(value: view.badgeView.frame.height/2)
    }

}

class RiskScoreTableCell: UITableViewCell {
    
    @IBOutlet weak var mainView: UIView!
    
    weak var xib: RiskViewXIB!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.loadXIB()
    }
    
    func loadXIB() {
        let nib = UINib(nibName: RiskViewXIB.className(), bundle: nil)
        if let view = nib.instantiate(withOwner: nil, options: nil).first as? RiskViewXIB {
            view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.frame = self.mainView.bounds
            self.mainView.addSubview(view)
            self.xib = view
        }
    }

}

class AssessmentQuestionTableCell: UITableViewCell {
    
    @IBOutlet weak var mainLbl: DefaultFontLabel!
    @IBOutlet weak var yesXIB: CheckboxLabelXIB!
    @IBOutlet weak var noXIB: CheckboxLabelXIB!
    @IBOutlet weak var badgeView: UIView!
    @IBOutlet weak var badgeViewWidth: NSLayoutConstraint!
    @IBOutlet weak var badgeViewHeight: NSLayoutConstraint!
    
    weak var badgeXIB: BadgeLabelCell!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        [self.yesXIB, self.noXIB].forEach { xib in
            if let xib = xib {
                xib.mainLbl.font = UIFont(name: .MontserratRegular, size: 17)
                xib.checkBoxHeight.constant = 24
                xib.squareImageView.frame.size.height = xib.checkBoxHeight.constant
                xib.checkmarkImageView.frame.size.height = xib.checkBoxHeight.constant
            }
        }
        self.yesXIB.title = "Yes"
        self.noXIB.title = "No"
        self.setupBadgeXIB()
    }
    
    func setupBadgeXIB() {
        let nib = UINib(nibName: BadgeLabelCell.className(), bundle: nil)
        if let view = nib.instantiate(withOwner: nil, options: nil).first as? BadgeLabelCell {
            view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.frame = self.badgeView.bounds
            self.badgeView.addSubview(view)
            self.badgeXIB = view
        }
    }
    
    func setBadgeData(text: String?, font: UIFont? = UIFont(name: .MontserratSemiBold, size: dashboardPrimaryTextSize), textColor: UIColor? = UIColor(appColor: .AppTint) , bgColor: UIColor? = UIColor(appColor: .AppTintBG), maxWidth: CGFloat? = nil) {
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
        
        let maxWidth = maxWidth ?? min(self.frame.width-self.yesXIB.frame.width-self.noXIB.frame.width, 100)
        let size = getLabelSize(text: view.mainLbl.text, font: view.mainLbl.font, minWidth: 20, widthAddition: 12+8+8+12, maxWidth: maxWidth, minHeight: 20, heightAddition: 10+4+4+10)
        self.badgeViewWidth.constant = size.width
        self.badgeView.frame.size.width = self.badgeViewWidth.constant
        self.badgeViewHeight.constant = max(5+34+5, size.height)
        self.badgeView.frame.size.height = self.badgeViewHeight.constant
        view.frame = self.badgeView.bounds
        view.badgeView.addCorner(value: view.badgeView.frame.height/2)
    }

}
