//
//  UIImageview+Extention.swift
//  cafm
//
//  Created by Savan Lakhani on 19/08/24.
//

import UIKit

extension UIImageView {
    
    //use this function for set the inset to UIImageView Insets
    func setImageWithInsets(image: UIImage, insets: UIEdgeInsets) {
        let newSize = CGSize(
            width: image.size.width + insets.left + insets.right,
            height: image.size.height + insets.top + insets.bottom
        )
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, image.scale)
        defer { UIGraphicsEndImageContext() }
        
        let origin = CGPoint(x: insets.left, y: insets.top)
        image.draw(at: origin)
        
        let insetImage = UIGraphicsGetImageFromCurrentImageContext()
        self.image = insetImage
    }
    
}
