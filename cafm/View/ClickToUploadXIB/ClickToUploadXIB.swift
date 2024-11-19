//
//  ClickToUploadXIB.swift
//  cafm
//
//  Created by NS on 2024-09-23.
//

import UIKit

class ClickToUploadXIB: NibView {
    
    @IBOutlet weak var mainView: DesignableView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var mainLbl: DefaultFontLabel!
    @IBOutlet weak var actionBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.mainView.CornerRadius = 5
        //self.mainView.BorderWidth = 1
        //self.mainView.BorderColor = UIColor(appColor: .Separator2)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.mainView.addDashedBorder(color: UIColor(appColor: .ViewBorder3))
    }
    
    @IBAction func actionBtnClicked(_ sender: UIButton) {
        
    }
    
}
