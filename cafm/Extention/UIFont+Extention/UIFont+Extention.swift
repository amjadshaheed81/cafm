//
//  UIFont+Extention.swift
//  cafm
//
//  Created by Savan Lakhani on 17/08/24.
//

import UIKit

extension UIFont {
    convenience init?(name: CustomFont, size: CGFloat) {
        self.init(name: name.rawValue, size: size)
    }
}

enum CustomFont: String {
    case MontserratBlack = "Montserrat-Black"
    case MontserratBlackItalic = "Montserrat-BlackItalic"
    case MontserratBold = "Montserrat-Bold"
    case MontserratBoldItalic = "Montserrat-BoldItalic"
    case MontserratExtraBold = "Montserrat-ExtraBold"
    case MontserratExtraBoldItalic = "Montserrat-ExtraBoldItalic"
    case MontserratExtraLight = "Montserrat-ExtraLight"
    case MontserratExtraLightItalic = "Montserrat-ExtraLightItalic"
    case MontserratItalic = "Montserrat-Italic"
    case MontserratLight = "Montserrat-Light"
    case MontserratLightItalic = "Montserrat-LightItalic"
    case MontserratMedium = "Montserrat-Medium"
    case MontserratMediumItalic = "Montserrat-MediumItalic"
    case MontserratRegular = "Montserrat-Regular"
    case MontserratSemiBold = "Montserrat-SemiBold"
    case MontserratSemiBoldItalic = "Montserrat-SemiBoldItalic"
    case MontserratThin = "Montserrat-Thin"
    case MontserratThinItalic = "Montserrat-ThinItalic"
}

