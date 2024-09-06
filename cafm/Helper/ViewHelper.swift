//
//  ViewHelper.swift
//  cafm
//
//  Created by Savan Lakhani on 18/08/24.
//

import UIKit

//MARK: Constant
var screenWidth: CGFloat {
    return UIScreen.main.bounds.width
}

var screenHeight: CGFloat {
    return UIScreen.main.bounds.height
}

var bottomSafeArea: CGFloat {
    return UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? .zero
}

var topSafeArea: CGFloat {
    return UIApplication.shared.keyWindow?.safeAreaInsets.top ?? UIApplication.shared.statusBarFrame.size.height
}

//MARK: - Corner
func addCornerToView(_ view: UIView, value: CGFloat = 8) {
    view.layer.cornerRadius = value
    view.clipsToBounds = true
}

func addBorderToView(_ view: UIView, width: CGFloat = 1, color: UIColor = UIColor(appColor: .AppTint)) {
    view.layer.borderWidth = width
    view.layer.borderColor = color.cgColor
    view.clipsToBounds = true
}
