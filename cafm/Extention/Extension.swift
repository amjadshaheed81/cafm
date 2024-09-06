//
//  Extension.swift
//  cafm
//
//  Created by NS on 18/08/24.
//
//

import UIKit
import SpreadsheetView

extension NSObject {
    static func className() -> String {
        return String(describing: Self.self)
    }
}

//MARK: Date Transform
extension String {
    func transformToDate(dateFormat: String) -> Date? {
        let df = cafmDateFormatter()
        df.dateFormat = dateFormat
        return df.date(from: self)
    }
    
    func transformToNewDateString(dateFormat: String, newDateFormat: String) -> String? {
        if let date = self.transformToDate(dateFormat: dateFormat) {
            let df = cafmDateFormatter()
            df.dateFormat = newDateFormat
            return df.string(from: date)
        }
        return nil
    }
}

extension UserDefaults {
    var userRole: UserEnum {
        get {
            let roleString = UserDefaults.standard.string(forKey: "UserRole") ?? "Unknown"
            return UserEnum(rawValue: roleString) ?? .unknown
        }
        set {
            UserDefaults.standard.setValue(newValue.rawValue, forKey: "UserRole")
        }
    }
}

extension Cell {
    func setGridLines(width: CGFloat = 1, color: UIColor = UIColor(appColor: .Separator2)) {
        gridlines.top = .solid(width: width, color: color)
        gridlines.bottom = .solid(width: width, color: color)
        gridlines.left = .solid(width: width, color: color)
        gridlines.right = .solid(width: width, color: color)
    }
    
    func setBottomGridLines(width: CGFloat = 1, color: UIColor = UIColor(appColor: .Separator2)) {
        gridlines.top = .none
        gridlines.bottom = .solid(width: width, color: color)
        gridlines.left = .none
        gridlines.right = .none
    }
}
