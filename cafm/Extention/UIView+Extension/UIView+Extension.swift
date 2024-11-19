//
//  UIView+Extension.swift
//  cafm
//
//  Created by NS on 17/08/24.
//
//

import UIKit
import SkeletonView

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
    
    func addDashedBorder(width: CGFloat = 1, color: UIColor = UIColor(appColor: .AppTint), cornerRadius: CGFloat = 5, dashPattern: [NSNumber] = [5, 5]) {
        let borderRect = self.bounds.inset(by: UIEdgeInsets(top: width, left: width, bottom: width, right: width))
        if let shapeLayer = self.layer.sublayers?.first(where: { $0.name == "dashedBorder" }) as? CAShapeLayer {
            shapeLayer.frame = self.bounds
            shapeLayer.path = UIBezierPath(roundedRect: borderRect, cornerRadius: cornerRadius).cgPath
        }else {
            let shapeLayer = CAShapeLayer()
            shapeLayer.frame = self.bounds
            shapeLayer.name = "dashedBorder"
            shapeLayer.path = UIBezierPath(roundedRect: borderRect, cornerRadius: cornerRadius).cgPath
            shapeLayer.fillColor = UIColor.clear.cgColor
            shapeLayer.strokeColor = color.cgColor
            shapeLayer.lineWidth = width
            shapeLayer.lineDashPhase = 5
            shapeLayer.lineDashPattern = dashPattern
            self.layer.addSublayer(shapeLayer)
        }
    }
    
}

//MARK: Skeleton
extension UIView {
    
    func startSkeleton() {
        self.isSkeletonable = true
        let animation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .topLeftBottomRight)
        self.showAnimatedGradientSkeleton(usingGradient: SkeletonGradient(baseColor: UIColor.clouds, secondaryColor: UIColor.silver), animation: animation)
    }
    
    func stopSkeleton() {
        self.hideSkeleton()
        self.isSkeletonable = false
    }
    
}
