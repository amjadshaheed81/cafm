//
//  UIImage+Extension.swift
//  cafm
//
//  Created by NS on 22/08/24.
//
//

import UIKit

extension UIImage {
    
    enum CommonSystemImage: String {
        case favorite = "star.fill"
        case unfavorite = "star"
    }
    
    convenience init?(appSystemImage: CommonSystemImage) {
        self.init(systemName: appSystemImage.rawValue)
    }
    
}
