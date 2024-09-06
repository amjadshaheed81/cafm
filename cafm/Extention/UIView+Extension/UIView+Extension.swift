//
//  UIView+Extension.swift
//  cafm
//
//  Created by NS on 17/08/24.
//  
//

import UIKit

//MARK: View Helper
extension UIView {
    
    //MARK: - Corner
    func addCorner(value: CGFloat = 5) {
        layer.cornerRadius = value
        clipsToBounds = true
    }

    func addCorner(value: CGFloat = 5, maskedCorners: CACornerMask) {
        layer.cornerRadius = value
        layer.maskedCorners = maskedCorners
        clipsToBounds = true
    }

    func addCorner(value: CGFloat = 5, side: UIRectEdge) {
        layer.cornerRadius = value
        switch side {
        case .top:
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        case .left:
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        case .bottom:
            layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        case .right:
            layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        default:
            break
        }
        clipsToBounds = true
    }

    //MARK: - Shadow
    func addShadow(color: UIColor = UIColor.lightGray, opacity: Float = 0.8, offset: CGSize = .zero, radius: CGFloat = 5) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        clipsToBounds = false
    }

    //MARK: - Border
    func addBorder(width: CGFloat = 1, color: UIColor = UIColor(appColor: .AppTint)) {
        layer.borderWidth = width
        layer.borderColor = color.cgColor
        clipsToBounds = true
    }

}
