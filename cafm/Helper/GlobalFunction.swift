//
//  GlobalFunction.swift
//  cafm
//
//  Created by NS on 18/08/24.
//
//

import UIKit

func getAppPrimaryFont(from font: UIFont?) -> UIFont? {
    if let font = font {
        let weight: UIFont.Weight = ((font.fontDescriptor.object(forKey: UIFontDescriptor.AttributeName.traits) as? [UIFontDescriptor.TraitKey: Any])?[.weight] as? UIFont.Weight) ?? .regular
        let fontDesc = UIFontDescriptor(
            fontAttributes: [
                UIFontDescriptor.AttributeName.family: "Montserrat",
                UIFontDescriptor.AttributeName.traits: [UIFontDescriptor.TraitKey.weight: weight]
            ]
        )
        return UIFont(descriptor: fontDesc, size: font.pointSize)
    }
    return nil
}

func getMaxLabelSize(textArray: [String?], font: UIFont?, minWidth: CGFloat = CGFloat.zero, widthAddition: CGFloat = CGFloat.zero, maxWidth: CGFloat? = nil, minHeight: CGFloat = CGFloat.zero, heightAddition: CGFloat = CGFloat.zero) -> CGSize {
    var maxW: CGFloat = CGFloat.zero
    var maxH: CGFloat = CGFloat.zero
    for text in textArray {
        let label = UILabel()
        label.text = text
        label.font = font
        label.numberOfLines = 0
        label.textAlignment = .center
        if let maxWidth {
            let size = label.sizeThatFits(CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude))
            maxW = max(maxW, size.width)
            maxH = max(maxH, size.height)
        }else {
            label.sizeToFit()
            maxW = max(maxW, label.frame.size.width)
            maxH = max(maxH, label.frame.size.height)
        }
    }
    return CGSize(
        width: max(minWidth, ceil(maxW))+widthAddition,
        height: max(minHeight, ceil(maxH))+heightAddition
    )
}

func getLabelSize(text: String?, font: UIFont?, minWidth: CGFloat = CGFloat.zero, widthAddition: CGFloat = CGFloat.zero, maxWidth: CGFloat? = nil, minHeight: CGFloat = CGFloat.zero, heightAddition: CGFloat = CGFloat.zero) -> CGSize {
    let label = UILabel()
    label.text = text
    label.font = font
    label.numberOfLines = 0
    label.textAlignment = .center
    if let maxWidth {
        let size = label.sizeThatFits(CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude))
        return CGSize(
            width: max(minWidth, ceil(size.width))+widthAddition,
            height: max(minHeight, ceil(size.height))+heightAddition
        )
    }else {
        label.sizeToFit()
        return CGSize(
            width: max(minWidth, ceil(label.frame.size.width))+widthAddition,
            height: max(minHeight, ceil(label.frame.size.height))+heightAddition
        )
    }
}

func getTotalLabelSize(textArray: [String?], font: UIFont?, minWidth: CGFloat = CGFloat.zero, widthAddition: CGFloat = CGFloat.zero, maxWidth: CGFloat? = nil, minHeight: CGFloat = CGFloat.zero, heightAddition: CGFloat = CGFloat.zero) -> CGSize {
    var totalWidth: CGFloat = CGFloat.zero
    var totalHeight: CGFloat = CGFloat.zero
    for text in textArray {
        let label = UILabel()
        label.text = text
        label.font = font
        label.numberOfLines = 0
        label.textAlignment = .center
        if let maxWidth {
            let size = label.sizeThatFits(CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude))
            totalWidth += max(minWidth, ceil(size.width))+widthAddition
            totalHeight += max(minHeight, ceil(size.height))+heightAddition
        }else {
            label.sizeToFit()
            totalWidth += max(minWidth, ceil(label.frame.size.width))+widthAddition
            totalHeight += max(minHeight, ceil(label.frame.size.height))+heightAddition
        }
    }
    return CGSize(width: totalWidth, height: totalHeight)
}

func convertDateString(_ dateString: String?) -> String? {
    // Define the input date format
    guard let dateString else {return nil}
    let inputFormatter = DateFormatter()
    inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
    
    // Convert the string to a Date object
    guard let date = inputFormatter.date(from: dateString) else {
        let inputDateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let outputDateFormat = "dd-MM-yyyy"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = inputDateFormat
        dateFormatter.timeZone = TimeZone.current
        
        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = outputDateFormat
            let formattedDateString = dateFormatter.string(from: date)
            return formattedDateString
        }
        
        return nil
    }
    
    // Define the output date format
    let outputFormatter = DateFormatter()
    outputFormatter.dateFormat = "dd-MM-yyyy"
    
    // Convert the Date object back to a string
    let outputDateString = outputFormatter.string(from: date)
    
    return outputDateString
}

func setNavigationBarAppearance(appDefault: Bool = true, backgroundColor: UIColor = UIColor.white, tintColor: UIColor = UIColor(appColor: .AppTint)) {
    if appDefault {
        UINavigationBar.appearance().titleTextAttributes = navTitleTextAttributes
        UINavigationBar.appearance().tintColor = UIColor(appColor: .AppTint)
    }else {
        UINavigationBar.appearance().tintColor = tintColor
        var titleTextAttributes = navTitleTextAttributes
        titleTextAttributes[.foregroundColor] = tintColor
        UINavigationBar.appearance().titleTextAttributes = titleTextAttributes
    }
}

func documentDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let documentsDirectory = paths[0]
    return documentsDirectory
}

func splitName(fullName: String) -> (firstName: String, lastName: String?) {
    let nameComponents = fullName.split(separator: " ")
    
    let firstName = String(nameComponents.first ?? "")
    let lastName = nameComponents.count > 1 ? String(nameComponents.dropFirst().joined(separator: " ")) : nil
    
    return (firstName, lastName)
}

func convertDateStringToNewString(from originalFormat: String, originalDateString: String, to targetFormat: String) -> String? {
    // Step 1: Create a DateFormatter for the original format
    let originalFormatter = DateFormatter()
    originalFormatter.dateFormat = originalFormat
    originalFormatter.locale = Locale(identifier: "en_US_POSIX")
    
    // Step 2: Convert the original string to a Date object
    guard let date = originalFormatter.date(from: originalDateString) else {
        print("Error: Cannot convert the date string to Date object")
        return nil
    }
    
    // Step 3: Create a DateFormatter for the target format
    let targetFormatter = DateFormatter()
    targetFormatter.dateFormat = targetFormat
    targetFormatter.locale = Locale(identifier: "en_US_POSIX")
    
    // Step 4: Convert the Date object to the target format string
    let targetDateString = targetFormatter.string(from: date)
    
    return targetDateString
}

func getCurrentAndOneYearLaterDates() -> (currentDate: String, oneYearLaterDate: String) {
    // Get the current date
    let currentDate = Date()

    // Create a date formatter
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

    // Convert the current date to a string
    let currentDateString = dateFormatter.string(from: currentDate)

    // Get the date one year from now
    if let oneYearLaterDate = Calendar.current.date(byAdding: .year, value: 1, to: currentDate) {
        // Convert the one year later date to a string
        let oneYearLaterDateString = dateFormatter.string(from: oneYearLaterDate)

        // Return the dates as a tuple
        return (currentDateString, oneYearLaterDateString)
    }

    // Return empty strings in case of failure (should not happen)
    return ("", "")
}


func showAlert(vc: UIViewController, message: String) {
    let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    vc.present(alert, animated: true, completion: nil)
}
