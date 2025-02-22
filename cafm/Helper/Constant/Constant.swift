//
//  Constant.swift
//  cafm
//
//  Created by ShitaRam on 17/08/24.
//

import UIKit
import SCLAlertView

let loginSB = UIStoryboard(name: "LoginFlowSB", bundle: nil)
let generalSB = UIStoryboard(name: "GeneralSB", bundle: nil)
let siteActionSB = UIStoryboard(name: "SiteActionSB", bundle: nil)
let portfolioManagementSB = UIStoryboard(name: "PortfolioManagementSB", bundle: nil)
let userManagemnetSB = UIStoryboard(name: "UserManagementSB", bundle: nil)
let siteAssetsSB = UIStoryboard(name: "SiteAssetsSB", bundle: nil)
let reportsSB = UIStoryboard(name: "ReportsSB", bundle: nil)
let siteCheckSB = UIStoryboard(name: "SiteCheckSB", bundle: nil)
let statutoryRegisterSB = UIStoryboard(name: "StatutoryRegisterSB", bundle: nil)
let CompanyManagementSB = UIStoryboard(name: "CompanyManagementSB", bundle: nil)
let siteReadingsCostSB = UIStoryboard(name: "SiteReadingsCost", bundle: nil)
let dropdownSB = UIStoryboard(name: "DropdownSB", bundle: nil)
let notificationSB = UIStoryboard(name: "NotificationSB", bundle: nil)
let categoriesManagementSB = UIStoryboard(name: "CategoriesManagementSB", bundle: nil)

let documnetSB = UIStoryboard(name: "DocumnetSB", bundle: nil)
let siteContractsSB = UIStoryboard(name: "SiteContractsSB", bundle: nil)
let preActionSB = UIStoryboard(name: "PreActionSB", bundle: nil)

let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as! SceneDelegate

struct ItemArrayData {
    var index: Int
    var text: String
    var image: UIImage?
}

struct DashboardTableData {
    
    struct ColumnData {
        let text: String
        var textColor: UIColor?
        var textBGColor: UIColor?
    }
    
    let columnHeaderText: String
    var isStatusData: Bool = false
    let columnData: [ColumnData]
}

func cafmCalendar() -> Calendar {
    let cal = Calendar.current
    return cal
}

func cafmDateFormatter() -> DateFormatter {
    let df = DateFormatter()
    return df
}

let isiPadDevice = UIDevice.current.userInterfaceIdiom == .pad

let navTitleTextAttributes: [NSAttributedString.Key: Any] = [
    NSAttributedString.Key.font: UIFont(name: .MontserratSemiBold, size: 17) ?? UIFont.systemFont(ofSize: 17, weight: .semibold),
    NSAttributedString.Key.foregroundColor: UIColor(appColor: .AppTint)
]

enum LoadingStatus: String {
    case `default` = ""
    case loading = "Loading..."
    case failed = "Failed to get response, Tap to retry!"
    case noResponse = "No records!"
    case noInternet = "Unable to connect to the internet"
    
    var hasData: Bool {
        return self == .default
    }
    
    var shouldReload: Bool {
        return self == .failed || self == .noInternet
    }
}

let positionItemArray: [String] = [
    "Internal",
    "External",
]

//Login User Details
var userEmailId: String? {
    get {
        (UserDefaults.standard.value(forKey: "userEmailId") as? String) ?? nil
    }
    set {
        UserDefaults.standard.setValue(newValue, forKey: "userEmailId")
    }
}
     
var userPassword: String? {
    get {
        (UserDefaults.standard.value(forKey: "userPassword") as? String) ?? nil
    }
    set {
        UserDefaults.standard.setValue(newValue, forKey: "userPassword")
    }
}


//Login User Details
var backUPUserEmailId: String? {
    get {
        (UserDefaults.standard.value(forKey: "backUPUserEmailId") as? String) ?? nil
    }
    set {
        UserDefaults.standard.setValue(newValue, forKey: "backUPUserEmailId")
    }
}
     
var backUPUserPassword: String? {
    get {
        (UserDefaults.standard.value(forKey: "backUPUserPassword") as? String) ?? nil
    }
    set {
        UserDefaults.standard.setValue(newValue, forKey: "backUPUserPassword")
    }
}



//Login User Details
var jwtToken: String? {
    get {
        (UserDefaults.standard.value(forKey: "jwtToken") as? String) ?? nil
    }
    set {
        UserDefaults.standard.setValue(newValue, forKey: "jwtToken")
    }
}

var sasToken: String? {
    get {
        (UserDefaults.standard.value(forKey: "sasToken") as? String) ?? nil
    }
    set {
        UserDefaults.standard.setValue(newValue, forKey: "sasToken")
    }
}
