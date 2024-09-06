//
//  UIColor+Extention.swift
//  cafm
//
//  Created by Savan Lakhani on 17/08/24.
//

import UIKit

extension UIColor {
    
    enum CommonColor: String {
        case AppTint = "#384BD3"
        case AppTintBG = "#E7E9FB" //"#DDE2F6"
        
        case AmberStatusBG = "#FDF0D7"
        case AmberStatus = "#FFA70B"
        case GrayStatusBG = "#E2E8F0"
        case GrayStatus = "#6B7C94"
        case GreenStatusBG = "#EDF7F1"
        case GreenStatus = "#219653"
        case RedStatusBG = "#FBF0F1"
        case RedStatus = "#D34053"
        
        //case AmberRiskScore = "#FFA70B"
        case GreenRiskScore = "#0FCF7E"
        case RedRiskScore = "#E03C3C"
        case YellowRiskScore = "#EFC531"
        
        case PrimaryText = "#000000"
        case GrayText = "#64748B"
        
        case BG1 = "#F1F5F9"
        
        //case Separator = "#E2E8F0"
        case Separator2 = "#D4D4D4"
        case ViewBorder = "#09194821"
        case ViewBorder2 = "#C8CEDA"
        
        //Building Layout Chart Colors
        case BLC_Lv1_Green_Border = "#1DCA5D"
        case BLC_Lv1_Green = "#EEFFF4" //#1DCA5D0A
        case BLC_Lv2_Yellow_Border = "#F3A515"
        case BLC_Lv2_Yellow = "#FFF7DE" //#F3A5150A
        case BLC_Lv3_Red_Border = "#F34040"
        case BLC_Lv3_Red = "#FFF5F4" //#F340400A
        case BLC_Lv4_Blue_Border = "#3B80F2"
        case BLC_Lv4_Blue = "#F0F8FF" //#3B80F20A
    }
    
    convenience init(appColor: CommonColor) {
        self.init(hexString: appColor.rawValue)
    }
    
}

extension UIColor {
    
    convenience init(hexString: String?) {
        var hex = hexString ?? "#000000"
        if hex.hasPrefix("#") {
            let index = hex.index(hex.startIndex, offsetBy: 1)
            hex = String(hex[index...])
        }
        var red: CGFloat   = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat  = 0.0
        var alpha: CGFloat = 1.0
        
        let scanner = Scanner(string: hex)
        var hexValue: CUnsignedLongLong = 0
        if scanner.scanHexInt64(&hexValue) {
            switch (hex.count) {
            case 3:
                red   = CGFloat((hexValue & 0xF00) >> 8)       / 15.0
                green = CGFloat((hexValue & 0x0F0) >> 4)       / 15.0
                blue  = CGFloat(hexValue & 0x00F)              / 15.0
            case 4:
                red   = CGFloat((hexValue & 0xF000) >> 12)     / 15.0
                green = CGFloat((hexValue & 0x0F00) >> 8)      / 15.0
                blue  = CGFloat((hexValue & 0x00F0) >> 4)      / 15.0
                alpha = CGFloat(hexValue & 0x000F)             / 15.0
            case 6:
                red   = CGFloat((hexValue & 0xFF0000) >> 16)   / 255.0
                green = CGFloat((hexValue & 0x00FF00) >> 8)    / 255.0
                blue  = CGFloat(hexValue & 0x0000FF)           / 255.0
            case 8:
                red   = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
                green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
                blue  = CGFloat((hexValue & 0x0000FF00) >> 8)  / 255.0
                alpha = CGFloat(hexValue & 0x000000FF)         / 255.0
            default:
                break
            }
        }
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    func toHexString() -> String {
        let comps = self.cgColor.components!
        let compsCount = self.cgColor.numberOfComponents
        let r: Int
        let g: Int
        var b: Int
        let a = Int(comps[compsCount - 1] * 255)
        if compsCount == 4 { // RGBA
            r = Int(comps[0] * 255)
            g = Int(comps[1] * 255)
            b = Int(comps[2] * 255)
        } else { // Grayscale
            r = Int(comps[0] * 255)
            g = Int(comps[0] * 255)
            b = Int(comps[0] * 255)
        }
        var hexString: String = "#"
        hexString += String(format: "%02X%02X%02X", r, g, b)
        
        if a != 255 {
            hexString += String(format: "%02X", a)
        }
        return hexString
    }
    
    static var randomColor: UIColor {
        return UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1.0)
    }
    
}
