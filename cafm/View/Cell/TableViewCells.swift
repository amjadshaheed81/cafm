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
