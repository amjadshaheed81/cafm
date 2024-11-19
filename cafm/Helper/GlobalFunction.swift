//
//  GlobalFunction.swift
//  cafm
//
//  Created by NS on 18/08/24.
//
//

import UIKit
import Alamofire
import CoreImage.CIFilterBuiltins

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

func stringToDate(_ dateString: String?) -> Date? {
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
            return date
        }else {
            return nil
        }
    }
    return date
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

func getFileNameAndExtension(from filePath: String) -> (fileName: String, fileExtension: String?) {
    let url = URL(fileURLWithPath: filePath)
    
    // Get the file name without extension
    let fileName = url.deletingPathExtension().lastPathComponent
    
    // Get the file extension
    let fileExtension = url.pathExtension.isEmpty ? nil : url.pathExtension
    
    return (fileName, fileExtension)
}

func generateQRCode(from string: String) -> UIImage? {
    let data = string.data(using: String.Encoding.ascii)
    
    // Create a filter to generate the QR code
    let filter = CIFilter.qrCodeGenerator()
    filter.setValue(data, forKey: "inputMessage")
    
    if let qrImage = filter.outputImage {
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledQRImage = qrImage.transformed(by: transform)
        
        // Convert the CIImage to a UIImage
        if let cgImage = CIContext().createCGImage(scaledQRImage, from: scaledQRImage.extent) {
            return UIImage(cgImage: cgImage)
        }
    }
    
    return nil
}

// Save to a file named "data.csv"
func generatePDF(from images: [UIImage]) -> Data {
    let pdfPageSize = CGSize(width: 1024, height: 1448) // Example size for an A4 PDF
    let imageSize = CGSize(width: 150, height: 150) // Example image size, adjust as needed
    let horizontalSpacing: CGFloat = 20.0
    let verticalSpacing: CGFloat = 20.0
    let margin: CGFloat = 20.0
    
    let pdfData = NSMutableData()
    
    // Create PDF context
    UIGraphicsBeginPDFContextToData(pdfData, CGRect(origin: .zero, size: pdfPageSize), nil)
    
    var xOffset: CGFloat = margin
    var yOffset: CGFloat = margin
    var imagesInCurrentPage = 0
    
    for (_, image) in images.enumerated() {
        // Start a new page if this is the first image or if the page is full
        if imagesInCurrentPage == 0 || (xOffset + imageSize.width + margin > pdfPageSize.width) {
            UIGraphicsBeginPDFPageWithInfo(CGRect(origin: .zero, size: pdfPageSize), nil)
            xOffset = margin
            yOffset = margin
        }
        
        // Draw the image at the calculated position
        let imageRect = CGRect(x: xOffset, y: yOffset, width: imageSize.width, height: imageSize.height)
        image.draw(in: imageRect)
        
        // Update xOffset and yOffset for the next image
        xOffset += imageSize.width + horizontalSpacing
        if xOffset + imageSize.width + margin > pdfPageSize.width {
            xOffset = margin
            yOffset += imageSize.height + verticalSpacing
        }
        
        // Start a new page if this image is the last one that fits on the current page
        if yOffset + imageSize.height + margin > pdfPageSize.height {
            xOffset = margin
            yOffset = margin
            imagesInCurrentPage = 0
        } else {
            imagesInCurrentPage += 1
        }
    }
    
    // End the PDF context
    UIGraphicsEndPDFContext()
    
    return pdfData as Data
}

// Convert the array to a CSV format string
func createCSV(from data: [[String]]) -> String {
    var csvString = ""
    
    for row in data {
        csvString += row.joined(separator: ",") + "\n"
    }
    
    return csvString
}

// Save CSV to a file in the documents directory
func saveCSVToFile(csvString: String, fileName: String) -> URL? {
    // Get the path to the documents directory
    let fileManager = FileManager.default
    let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
    guard let documentDirectory = urls.first else {
        print("Failed to access document directory")
        return nil
    }
    
    // Create the file URL
    let fileURL = documentDirectory.appendingPathComponent(fileName).appendingPathExtension("csv")
    
    // Write the CSV string to the file
    do {
        try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
        print("CSV saved successfully at: \(fileURL)")
        return fileURL
    } catch {
        print("Error saving CSV: \(error)")
        return nil
    }
    
}

func getUserDisplayStr(_ user: User?) -> String? {
    if let user {
        let role = user.role ?? ""
        let name = user.name ?? ""
        let email = user.email ?? ""
        let companyName = user.companyName ?? ""
        return "\(role) - \(name) (\(email)) - \(companyName)"
    }
    return nil
}

func getSiteCheckDisplayStr(_ model: SiteCheckModel?) -> String? {
    if let model {
        let type = model.type ?? ""
        let subType = model.subType ?? ""
        let category = model.category ?? ""
        return "\(type) - \(subType) - \(category)"
    }
    return nil
}

func getAssetDisplayStrForSiteCheck(_ model: AssetDetailsResponse?) -> String? {
    if let model {
        return "\(model.assetName ?? "") - \(model.category ?? "")"
    }
    return nil
}

func getLOVDisplayStr(_ model: LOV_Model?) -> String? {
    if let model {
        return "\(model.lovValue ?? "") - \(model.lovDesc ?? "")"
    }
    return nil
}

func calculatedMatScore(_ model: SiteCheckAsbestosSample?) -> Int {
    guard let model else { return 0 }
    let productType: Int = model.productType?.intValue ?? 0
    let damage: Int = model.damage?.intValue ?? 0
    let surfaceTreatment: Int = model.surfaceTreatment?.intValue ?? 0
    let asbestosType: Int = model.asbestosType?.intValue ?? 0
    return productType + damage + surfaceTreatment + asbestosType
}

func calculatedPriScore(_ model: SiteCheckAsbestosSample?) -> Int {
    guard let model else { return 0 }
    let mainActivityScore: Int = model.mainActivityScore ?? 0
    let secondaryActivityScore: Int = model.secondaryActivityScore ?? 0
    let location: Int = model.location?.intValue ?? 0
    let accessibility: Int = model.accessibility?.intValue ?? 0
    let extent: Int = model.extent?.intValue ?? 0
    let occupants: Int = model.occupants ?? 0
    let frequencyOfUse: Int = model.frequencyOfUse?.intValue ?? 0
    let avgTimeInUse: Int = model.avgTimeInUse?.intValue ?? 0
    let maintenanceActivityType: Int = model.maintenanceActivityType?.intValue ?? 0
    let maintenanceFrequency: Int = model.maintenanceFrequency?.intValue ?? 0
    return mainActivityScore + secondaryActivityScore + location + accessibility + extent + occupants + frequencyOfUse + avgTimeInUse + maintenanceActivityType + maintenanceFrequency
}

func getSiteCheckAsbestosSampleNo(_ model: SiteCheckAsbestosSample?) -> String? {
    if let model {
        if let sampleId = model.sampleId {
            return "AS00" + sampleId.stringValue
        }else if let sampleNo = model.sampleNo {
            return sampleNo
        }
        return "AS00" + "NaN"
    }
    return nil
}

func getReadingForWaterOutletTemp(_ model: SiteCheckWaterOutletTemp?) -> String?  {
    if let model {
        let kResponseDateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let ddMMyyyyStr = "yyyy-MM-dd"
        
        let reading1 = model.reading1?.stringValue ?? ""
        let reading2 = model.reading2?.stringValue ?? ""
        let reading3 = model.reading3?.stringValue ?? ""
        let r1Date: String
        if let value = model.r1Date?.transformToNewDateString(dateFormat: kResponseDateFormat, newDateFormat: ddMMyyyyStr) {
            r1Date = "(\(value))"
        }else {
            r1Date = "N/A"
        }
        let r2Date: String
        if let value = model.r2Date?.transformToNewDateString(dateFormat: kResponseDateFormat, newDateFormat: ddMMyyyyStr) {
            r2Date = "(\(value))"
        }else {
            r2Date = "N/A"
        }
        let r3Date: String
        if let value = model.r3Date?.transformToNewDateString(dateFormat: kResponseDateFormat, newDateFormat: ddMMyyyyStr) {
            r3Date = "(\(value))"
        }else {
            r3Date = "N/A"
        }
        
        return """
1st : \(reading1) \(r1Date)
2nd : \(reading2) \(r2Date)
3rd : \(reading3) \(r3Date)
"""
    }
    return nil
}

func isAllFilledForWaterOutletTemp(_ model: SiteCheckWaterOutletTemp?) -> Bool  {
    return model?.assetId != nil &&
    model?.outletType != nil &&
    model?.temperature != nil &&
    model?.normalRunTime != nil &&
    model?.usageFrequency != nil &&
    model?.floor != nil &&
    model?.room != nil
}

//func processMonthlyBudget(data: [ProjectContract]) -> [(label: String, dataValue: Double)] {
//    var monthlyBudget: [(label: String, dataValue: Double)] = []
//    data.forEach { item in
//        if item.status == "Active", let budget = Double(item.budget ?? "") {
//            let category = item.category ?? ""
//            if let index = monthlyBudget.firstIndex(where: { $0.label == category }) {
//                monthlyBudget[index].dataValue += budget
//            }else {
//                monthlyBudget.append((label: category, dataValue: budget))
//            }
//            
//        }
//    }
//    return monthlyBudget
//}



func getUniqueSitesWithUserCount(
    users: [User],
    sites: [CreateSiteRequestModel],
    area: String? = nil,
    allSites: Bool = true
) -> [(siteName: String, totalUsers: Int)] {
    let globalSite: CreateSiteRequestModel? = UserConstants.shared.allSites.first { $0.siteId == UserConstants.shared.selectedSiteID }

    var siteUserCount = [(siteName: String, totalUsers: Int)]()
    
    // Filter sites by open status and area if provided
    let filteredSites = sites.filter { site in
        site.status == "open" &&
        (area == nil || site.area == area) &&
        (allSites || site.siteName == globalSite?.siteName)
    }
    
    // Map site names to ensure only counting users for filtered sites
    let filteredSiteNames = filteredSites.map { $0.siteName ?? "" }.reduce([String]()) { partialResult, value in
        partialResult.contains(value) ? partialResult : partialResult + [value]
    }
    
    // Count users tagged to filtered sites
    users.forEach { user in
        user.taggedSites?.forEach { taggedSite in
            if filteredSiteNames.contains(taggedSite.name ?? "") {
                let name = taggedSite.name ?? ""
                if let index = siteUserCount.firstIndex(where: { $0.siteName == name }) {
                    siteUserCount[index].totalUsers += 1
                }else {
                    siteUserCount.append((siteName: name, totalUsers: 1))
                }
            }
        }
    }
    
    return siteUserCount
}

func formatDateString(_ dateString: String) -> String? {
    // Create a DateFormatter for the input date string
    let inputFormatter = DateFormatter()
    inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss" // Expect the date part before 'T'
    inputFormatter.locale = Locale(identifier: "en_US_POSIX") // Ensure locale-independent parsing
    
    // Remove any extra part after the main time format (like 'UTC')
    if let endIndex = dateString.range(of: "T")?.upperBound {
        let trimmedString = String(dateString.prefix(upTo: endIndex) + "23:59:59")
        
        // Convert the trimmed date string to a Date object
        if let date = inputFormatter.date(from: trimmedString) {
            // Create a DateFormatter for the desired output format
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "yyyy/MM/dd"
            return outputFormatter.string(from: date)
        }
    }
    return nil
}

func getCurrentDateWithTime() -> String {
    // Get the current date and time
    let currentDate = Date()
    
    // Create a DateFormatter to format the date and time
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
    dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Locale-independent format
    
    // Convert the date to the desired string format
    return dateFormatter.string(from: currentDate)
}

func getCurrentTimeInISO8601Format() -> String? {
    // Get the current date
    let currentDate = Date()
    
    // Create an instance of ISO8601DateFormatter
    let formatter = ISO8601DateFormatter()
    
    // Set the format options to include milliseconds and time zone (UTC)
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    
    // Set the time zone to UTC
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    
    // Convert the current date to the desired format
    let formattedDate = formatter.string(from: currentDate)
    
    return formattedDate
}

func calculateDueDays(createdAt: String, dueInDays: String?, riskScore: Int) -> String {
    return getTimeRemaining(creationDate: createdAt, riskScore: riskScore)
    
    
//    let dateFormatter = DateFormatter()
//    dateFormatter.dateFormat = "yyyy-MM-dd"
//    guard let createdDate = dateFormatter.date(from: createdAt) else {
//        return "Invalid date format"
//    }
//    
//    let calendar = Calendar.current
//    
//    // Convert dueInDays to Int if it's a valid string, else default to nil
//    let daysToAdd: Int? = dueInDays != nil ? Int(dueInDays!) : nil
//    let dueDate = daysToAdd != nil ? calendar.date(byAdding: .day, value: daysToAdd!, to: createdDate) : createdDate
//    
//    guard let finalDueDate = dueDate else {
//        return "Error calculating due days"
//    }
//    
//    let currentDate = Date()
//    let daysRemaining = calendar.dateComponents([.day], from: currentDate, to: finalDueDate).day ?? 0
//    
//    return daysRemaining < 0 ? "\(-daysRemaining) Days Overdue" : "\(daysRemaining) Days Remaining"
}

func getTimeRemaining(creationDate: String, riskScore: Int) -> String {
    // Define the risk levels
    let riskData: (badgeColor: UIColor, days: Int) = {
        switch riskScore {
        case let score where score > 16:
            return (.systemRed, 5)
        case let score where score > 9:
            return (.systemOrange, 30)
        case let score where score > 4:
            return (.systemBlue, 90)
        default:
            return (.systemGreen, 365)
        }
    }()
    
    // Parse creation date string to Date
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    guard let createdDate = dateFormatter.date(from: creationDate) else {
        return "" // Return an empty label if date parsing fails
    }
    
    // Calculate due date by adding days
    var dueDateComponents = DateComponents()
    dueDateComponents.day = riskData.days
    let calendar = Calendar.current
    let dueDate = calendar.date(byAdding: dueDateComponents, to: createdDate) ?? createdDate
    
    // Calculate time remaining in days
    let today = Date()
    let timeRemaining = calendar.dateComponents([.day], from: today, to: dueDate).day ?? 0
    return timeRemaining < 0 ? "\(abs(timeRemaining)) Days Overdue" : "\(timeRemaining) days remaining"
}


func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
    guard let url = URL(string: urlString) else {
        completion(nil)
        return
    }
    
    // Create a URL session data task to fetch the image data
    URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            print("Failed to load image: \(error)")
            completion(nil)
            return
        }
        
        // Convert data to UIImage
        if let data = data, let image = UIImage(data: data) {
            DispatchQueue.main.async {
                completion(image)
            }
        } else {
            completion(nil)
        }
    }.resume()
}

func getDueDate(creationDate: Date, riskScore: Int) -> String? {
    let days: Int
    switch riskScore {
    case let score where score > 16:
        days = 5
    case let score where score > 9:
        days = 30
    case let score where score > 4:
        days = 90
    default:
        days = 365
    }
    
    if let dueDate = Calendar.current.date(byAdding: .day, value: days, to: creationDate) {
        return dateToString(dueDate)
    }
    return nil
}

func getTimeRemaining(creationDate: Date, riskScore: Int) -> (status: String, badgeColor: String) {
    let days: Int
    let badgeColor: String
    
    switch riskScore {
    case let score where score > 16:
        days = 5
        badgeColor = "danger"
    case let score where score > 9:
        days = 30
        badgeColor = "warning"
    case let score where score > 4:
        days = 90
        badgeColor = "info"
    default:
        days = 365
        badgeColor = "success"
    }
    
    let dueDate = Calendar.current.date(byAdding: .day, value: days, to: creationDate) ?? creationDate
    let today = Date()
    let timeRemaining = Calendar.current.dateComponents([.day], from: today, to: dueDate).day ?? 0
    
    let status = timeRemaining < 0 ? "\(abs(timeRemaining)) Days Overdue" : "\(timeRemaining) days remaining"
    
    return (status, badgeColor)
}

func stringToDate(_ dateString: String, format: String = "yyyy-MM-dd") -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    dateFormatter.timeZone = TimeZone.current
    return dateFormatter.date(from: dateString)
}

func dateToString(_ date: Date, format: String = "yyyy-MM-dd") -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    dateFormatter.timeZone = TimeZone.current
    return dateFormatter.string(from: date)
}
