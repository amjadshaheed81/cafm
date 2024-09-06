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
    @IBOutlet weak var mainLbl: DefaultFontLabel!
    @IBOutlet weak var selectionView: DesignableView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
