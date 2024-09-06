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

let documnetSB = UIStoryboard(name: "DocumnetSB", bundle: nil)

let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as! SceneDelegate

struct DataTableHeaderData {
    let name: String
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
