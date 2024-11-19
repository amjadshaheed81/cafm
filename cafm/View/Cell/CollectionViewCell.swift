//
//  CollectionViewCell.swift
//  cafm
//
//  Created by NS on 31/08/24.
//
//

import UIKit

class LabelSelectionCell: UICollectionViewCell {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var mainLbl: DefaultFontLabel!
    @IBOutlet weak var selectionView: DesignableView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        if self.imageView != nil {
            self.imageView.image = nil
        }
    }
    
}
