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

extension Date {
    
    //MARK: Date to String Transform
    func transformToString(dateFormat: String) -> String {
        let df = cafmDateFormatter()
        df.dateFormat = dateFormat
        return df.string(from: self)
    }
    
}

extension String {
    
    //MARK: String to Date Transform
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
    //
    
    func trimmingSpacesAndLines() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    func trimmingSpacesAndLinesLowercased() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).lowercased()
    }
    
    func fileName() -> String {
        return NSURL(fileURLWithPath: self).deletingPathExtension?.lastPathComponent ?? ""
    }
    
    func fileExtension() -> String {
        return NSURL(fileURLWithPath: self).pathExtension ?? ""
    }
    
    var intValue: Int? {
        return Int(self)
    }
    
}

extension Int {
    
    var stringValue: String {
        return "\(self)"
    }
    
}

extension Bool {
    
    var stringValue: String {
        return "\(self)"
    }

    var yesNoValue: String {
        return self ? "Yes" : "No"
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

extension UITextField {
    
    func hideEditing() {
        if self.isEditing {
            self.endEditing(true)
        }
        if self.isFirstResponder {
            self.resignFirstResponder()
        }
    }
    
}

extension UITextView {
    
    func hideEditing() {
        if self.isFirstResponder {
            self.resignFirstResponder()
        }
    }
    
}

extension UITextField {
    
    private struct AssociatedKeys {
        static var textChangeClosure: UInt8 = 0
    }
    
    func textChanged(_ closure: @escaping () -> Void) {
        objc_setAssociatedObject(self, &AssociatedKeys.textChangeClosure, closure, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        addTarget(self, action: #selector(textChangeHandler), for: .editingChanged)
    }
    
    @objc private func textChangeHandler() {
        if let closure = objc_getAssociatedObject(self, &AssociatedKeys.textChangeClosure) as? () -> Void {
            closure()
        }
    }
    
}

extension UIMenu {
    
    static func booleanMenu(selectTitle: String? = "Select", boolValue: Bool?, actionHandler: @escaping ((Bool?) -> Void)) -> UIMenu {
        let selectAction = UIAction(title: selectTitle ?? "", state: boolValue == nil ? .on : .off) { _ in
            actionHandler(nil)
        }
        let yesAction = UIAction(title: "Yes", state: boolValue == true ? .on : .off) { _ in
            actionHandler(true)
        }
        let noAction = UIAction(title: "No", state: boolValue == false ? .on : .off) { _ in
            actionHandler(false)
        }
        return UIMenu(children: [selectAction, yesAction, noAction])
    }
    
    static func booleanStringMenu(selectTitle: String? = "Select", stringValue: String?, actionHandler: @escaping ((String?) -> Void)) -> UIMenu {
        let selectAction = UIAction(title: selectTitle ?? "", state: stringValue == nil ? .on : .off) { _ in
            actionHandler(nil)
        }
        let yesTitle = "Yes"
        let yesAction = UIAction(title: yesTitle, state: stringValue == yesTitle ? .on : .off) { _ in
            actionHandler(yesTitle)
        }
        let noTitle = "No"
        let noAction = UIAction(title: noTitle, state: stringValue == noTitle ? .on : .off) { _ in
            actionHandler(noTitle)
        }
        return UIMenu(children: [selectAction, yesAction, noAction])
    }
    
}

extension UIViewController {
    // Function to show an alert with a message
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension CGRect {
    
    init(center: CGPoint, size: CGSize) {
        self.init(x: center.x - size.width / 2, y: center.y - size.height / 2, width: size.width, height: size.height)
    }
    
}
