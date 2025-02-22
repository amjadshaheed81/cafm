//
//  BasicReportsTableVC.swift
//  cafm
//
//  Created by NS on 01/12/24.
//
//

import UIKit
import SpreadsheetView
import SCLAlertView

class BasicReportsTableVC: UIViewController {
    
    @IBOutlet weak var emptyView: EmptyView!
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var spreadsheetContainerView: DesignableView!
    @IBOutlet weak var spreadsheetView: SpreadsheetView!
    @IBOutlet weak var spreadsheetViewWidth: NSLayoutConstraint!
    @IBOutlet weak var spreadsheetViewHeight: NSLayoutConstraint!
    
    private let loadingSCLAlertView = SCLAlertView(appearance: loadingSCLAppearance)
    private var loadingStatus: LoadingStatus = .default {
        didSet {
            if self.loadingStatus.hasData {
                self.mainView.isHidden = false
                self.emptyView.isHidden = true
            }else {
                if self.loadingStatus == .loading || self.loadingStatus.shouldReload {
                    self.emptyView.mainLbl.text = self.loadingStatus.rawValue
                    self.emptyView.isHidden = false
                    self.mainView.isHidden = true
                }else {
                    self.mainView.isHidden = false
                    self.emptyView.isHidden = true
                }
            }
        }
    }
    
    private var headerColumnNames: [TableFields] = []
    var question: BasicReportsQuestion = ("", "", "")
    var itemArrayJson: [[String: Any]] = []
    private var itemArray: [CreateSiteRequestModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureNavigationBar()
        self.emptyView.delegate = self
        self.setupViews()
        self.loadData()
    }
    
    func configureNavigationBar() {
        self.title = "Basic Report"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.down"), style: .plain, target: self, action: #selector(self.exportBtnClicked(_:)))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.adjustSpreadsheetView()
    }
    
    @objc func exportBtnClicked(_ sender: UIBarButtonItem) {
        var csvString = headerColumnNames.compactMap({ $0.rawValue }).joined(separator: ",")
        csvString += "\n"
        for index in 0..<self.itemArray.count {
            if self.itemArray.count > index, self.itemArrayJson.count > index {
                let item = self.itemArray[index]
                let itemJson = self.itemArrayJson[index]
                csvString += "\(item.siteId?.stringValue ?? ""),\(item.siteName ?? ""),\((itemJson[question.main] as? [String: Any])?[question.key] != nil ? "Yes" : "No"),\(item.status ?? "")\n"
            }
        }
        
        let fileName = "basic-report.csv"
        let fileURL = documentDirectory().appendingPathComponent(fileName)
        
        do {
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
            CAFMFileUtils.shared.shareFile(from: self, fileURL: fileURL, sender: self.view)
        } catch {
            print("Failed to create CSV file: \(error)")
        }
    }
    
}

//MARK: - Fields enum
extension BasicReportsTableVC {
    enum TableFields {
        case ID
        case SiteName
        case key(key: String)
        case Status
        
        var rawValue: String {
            switch self {
            case .ID: return "ID"
            case .SiteName: return "SiteName"
            case .key(key: let key): return key
            case .Status: return "Status"
            }
        }
    }
}

//MARK: - EmptyViewDelegate
extension BasicReportsTableVC: EmptyViewDelegate {
    func emptyViewDidTapView(_ view: EmptyView) {
        if self.loadingStatus.shouldReload {
            self.loadData()
        }
    }
    
    func hideLoadingAndShowError(message: String? = nil) {
        self.loadingSCLAlertView.hideView()
        let subTitle: String = message ?? "Something went wrong, Please try again!"
        SCLAlertView.showErrorAlert(title: "Error", message: subTitle, cancelButtonTitle: "OK")
    }
}

//MARK: - load data
extension BasicReportsTableVC {
    
    func loadData() {
        
    }
    
}

//MARK: - setup views
extension BasicReportsTableVC {
    
    func setupViews() {
        self.headerColumnNames = [
            .ID,
            .SiteName,
            .key(key: question.key),
            .Status
        ]
        self.itemArray = [CreateSiteRequestModel](JSONArray: self.itemArrayJson)
        self.loadingStatus = .default
        
        self.spreadsheetView.addCorner(value: 12)
        self.spreadsheetView.addBorder(width: 1, color: UIColor(appColor: .Separator2))
        self.spreadsheetView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.spreadsheetView.showsVerticalScrollIndicator = false
        self.spreadsheetView.showsHorizontalScrollIndicator = false
        self.spreadsheetView.bounces = false
        self.spreadsheetView.register(UINib(nibName: DashboardTableCell.className(), bundle: nil), forCellWithReuseIdentifier: DashboardTableCell.className())
        self.spreadsheetView.dataSource = self
        self.spreadsheetView.delegate = self
        
        self.reloadViews()
        self.reloadSpreadsheetView()
    }
    
    func reloadViews() {
        
    }
    
    func reloadSpreadsheetView() {
        self.spreadsheetView.reloadData()
        self.adjustSpreadsheetView()
    }
    
    func adjustSpreadsheetView() {
        let spreadsheetSize = self.spreadsheetView.contentSize
        let width = min(self.spreadsheetContainerView.frame.width, spreadsheetSize.width)
        self.spreadsheetViewWidth.constant = width
        self.spreadsheetView.frame.size.width = width
        let height = min(self.spreadsheetContainerView.frame.height, spreadsheetSize.height)
        self.spreadsheetViewHeight.constant = height
        self.spreadsheetView.frame.size.height = height
    }
    
}

//MARK: - SpreadsheetViewDataSource, SpreadsheetViewDelegate
extension BasicReportsTableVC: SpreadsheetViewDataSource, SpreadsheetViewDelegate {
    
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return self.headerColumnNames.count
    }
    
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        if self.loadingStatus.hasData {
            return 1+self.itemArray.count
        }else {
            return 1+1
        }
    }
    
    func mergedCells(in spreadsheetView: SpreadsheetView) -> [CellRange] {
        if !self.loadingStatus.hasData {
            let totalColumn = self.headerColumnNames.count
            return [CellRange(from: IndexPath(row: 1, column: 0), to: IndexPath(row: 1, column: totalColumn-1))]
        }else {
            return []
        }
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        let column = indexPath.section
        guard self.headerColumnNames.count > column else { return nil }
        let headerText = self.headerColumnNames[column]
        if indexPath.row == 0 {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: DashboardTableCell.className(), for: indexPath) as! DashboardTableCell
            cell.setGridLines(width: 1, color: UIColor(appColor: .AppTint))
            
            cell.backgroundColor = UIColor(appColor: .AppTint)
            cell.mainLbl.font = UIFont(name: .MontserratSemiBold, size: dashboardPrimaryTextSize)
            cell.mainLbl.textColor = UIColor.white
            
            cell.mainLbl.text = headerText.rawValue
            return cell
        }else if !self.loadingStatus.hasData {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: DashboardTableCell.className(), for: indexPath) as! DashboardTableCell
            cell.setGridLines(width: 1, color: UIColor(appColor: .Separator2))
            
            cell.backgroundColor = UIColor.white
            cell.mainLbl.font = UIFont(name: .MontserratRegular, size: dashboardPrimaryTextSize)
            cell.mainLbl.textColor = UIColor.black
            
            cell.mainLbl.text = self.loadingStatus.rawValue
            return cell
        }else {
            let index = indexPath.row-1
            if self.itemArray.count > index, self.itemArrayJson.count > index {
                let item = self.itemArray[index]
                let itemJson = self.itemArrayJson[index]
                
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: DashboardTableCell.className(), for: indexPath) as! DashboardTableCell
                cell.setGridLines(width: 1, color: UIColor(appColor: .Separator2))
                cell.backgroundColor = UIColor.white
                cell.mainLbl.font = UIFont(name: .MontserratRegular, size: dashboardPrimaryTextSize)
                cell.mainLbl.textColor = UIColor.black
                
                switch headerText {
                case .ID:
                    cell.mainLbl.text = item.siteId?.stringValue
                case .SiteName:
                    cell.mainLbl.text = item.siteName
                case .key(key: _):
                    cell.mainLbl.text = (itemJson[question.main] as? [String: Any])?[question.key] != nil ? "Yes" : "No"
                case .Status:
                    cell.mainLbl.text = item.status
                }
                
                return cell
            }
        }
        return nil
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        if self.headerColumnNames.count > column {
            let headerText = self.headerColumnNames[column]
            let refSize = CGSize(width: 12+30+12, height: 10+18+10)
            let widthAddition: CGFloat = 12+12
            let minWidth = refSize.width-widthAddition
            let maxWidth: CGFloat = isiPadDevice ? 300 : 200
            
            let headerWidth = getLabelSize(text: headerText.rawValue, font: UIFont(name: .MontserratSemiBold, size: dashboardPrimaryTextSize), minWidth: minWidth, widthAddition: widthAddition, maxWidth: maxWidth).width
            
            var textArray: [String] = []
            switch headerText {
            case .ID:
                textArray = self.itemArray.compactMap { $0.siteId?.stringValue ?? "" }
            case .SiteName:
                textArray = self.itemArray.compactMap { $0.siteName ?? "" }
            case .key(key: _):
                textArray = self.itemArrayJson.compactMap { ($0[question.main] as? [String: Any])?[question.key] != nil ? "Yes" : "No" }
            case .Status:
                textArray = self.itemArray.compactMap { $0.status ?? "" }
            }
            let maxColumnWidth = getMaxLabelSize(textArray: textArray, font: UIFont(name: .MontserratRegular, size: dashboardPrimaryTextSize), minWidth: minWidth, widthAddition: widthAddition, maxWidth: maxWidth).width
            return max(headerWidth, maxColumnWidth)
        }
        return 0
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        let refSize = CGSize(width: 12+30+12, height: 10+18+10)
        let heightAddition: CGFloat = 10+10
        let minHeight = refSize.height-heightAddition
        let maxWidth: CGFloat = isiPadDevice ? 300 : 200
        
        if row == 0 {
            let headerHeight = getMaxLabelSize(textArray: self.headerColumnNames.compactMap({ $0.rawValue }), font: UIFont(name: .MontserratSemiBold, size: dashboardPrimaryTextSize), maxWidth: maxWidth, minHeight: minHeight, heightAddition: heightAddition).height
            return headerHeight
        }else {
            let index = row-1
            if self.itemArray.count > index, self.itemArrayJson.count > index {
                let item = self.itemArray[index]
                let itemJson = self.itemArrayJson[index]
                
                let textArray = [
                    item.siteId?.stringValue,
                    item.siteName,
                    (itemJson[question.main] as? [String: Any])?[question.key] != nil ? "Yes" : "No",
                    item.status,
                ]
                let maxHeight = getMaxLabelSize(textArray: textArray, font: UIFont(name: .MontserratRegular, size: dashboardPrimaryTextSize), maxWidth: maxWidth, minHeight: minHeight, heightAddition: heightAddition).height
                return max(maxHeight, 10+40+10)
            }
            return 0
        }
    }
    
}
