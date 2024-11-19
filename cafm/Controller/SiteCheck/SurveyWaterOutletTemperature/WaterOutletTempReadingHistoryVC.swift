//
//  WaterOutletTempReadingHistoryVC.swift
//  cafm
//
//  Created by NS on 13/10/24.
//  
//

import UIKit
import SpreadsheetView
import SCLAlertView

class WaterOutletTempReadingHistoryVC: UIViewController {

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
    
    weak var addSiteCheckVC: AddSiteCheckVC?
    weak var waterOutletTempVC: WaterOutletTempVC?
    var itemArray: [SiteCheckWaterOutletTemp] = []
    
    private var headerColumnNames: [Fields] = Fields.allCases
    
    private let kResponseDateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    private let kRequestDateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    private let ddMMyyyyStr = "dd/MM/yyyy"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isModalInPresentation = true
        self.configureNavigationBar()
        self.emptyView.delegate = self
        self.setupViews()
        self.loadData()
    }
    
    func configureNavigationBar() {
        self.title = "Reading History"

        let closeBtn = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(self.navCloseBtnClicked(_:)))
        self.navigationItem.leftBarButtonItem = closeBtn
        self.configureNavigationBackButton()
    }
    
    @objc func navCloseBtnClicked(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
}

//MARK: - Fields enum
extension WaterOutletTempReadingHistoryVC {
    enum Fields: String, CaseIterable {
        case TestDate = "Test Date"
        case ExpiryDate = "Expiry Date"
        case Reading1 = "Reading 1"
        case Reading2 = "Reading 2"
        case Reading3 = "Reading 3"
    }
}

//MARK: - EmptyViewDelegate
extension WaterOutletTempReadingHistoryVC: EmptyViewDelegate {
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
extension WaterOutletTempReadingHistoryVC {
    
    func loadData() {
        
    }
    
    typealias SuccessCompletion = (() -> Void)
}

extension WaterOutletTempReadingHistoryVC {
    
    func setupViews() {
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
extension WaterOutletTempReadingHistoryVC: SpreadsheetViewDataSource, SpreadsheetViewDelegate {
    
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
            if self.itemArray.count > index {
                let item = self.itemArray[index]
                //let isEditing = item.isEditing ?? false
                //let isForAddNew = item.isForAddNew ?? false
                //let bgColor = isEditing ? UIColor.white : UIColor(appColor: .GrayStatusBG)
                
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: DashboardTableCell.className(), for: indexPath) as! DashboardTableCell
                cell.setGridLines(width: 1, color: UIColor(appColor: .Separator2))
                cell.backgroundColor = UIColor.white
                
                switch headerText {
                case .TestDate, .ExpiryDate:
                    cell.mainLbl.font = UIFont(name: .MontserratRegular, size: dashboardPrimaryTextSize)
                    cell.mainLbl.textColor = UIColor.black
                    
                    cell.mainLbl.text = item.r1Date?.transformToNewDateString(dateFormat: kResponseDateFormat, newDateFormat: ddMMyyyyStr) ?? ""
                    break
                case .Reading1, .Reading2, .Reading3:
                    cell.mainLbl.font = UIFont(name: .MontserratSemiBold, size: dashboardPrimaryTextSize)
                    
                    var value: Int?
                    if headerText == .Reading1 {
                        value = item.reading1
                    }else if headerText == .Reading2 {
                        value = item.reading2
                    }else if headerText == .Reading3 {
                        value = item.reading3
                    }
                    
                    cell.mainLbl.text = value?.stringValue ?? ""

                    if let value {
                        let temp = item.temperature
                        cell.mainLbl.textColor = (temp == "Hot" && value < 50) || (temp == "Cold" && value > 20) ? UIColor.red : UIColor(hexString: "#008000")
                    }
                    break
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
            
            
            switch headerText {
            case .TestDate, .ExpiryDate:
                let textArray = self.itemArray.compactMap { $0.r1Date?.transformToNewDateString(dateFormat: kResponseDateFormat, newDateFormat: ddMMyyyyStr) ?? "" }
                let maxColumnWidth = getMaxLabelSize(textArray: textArray, font: UIFont(name: .MontserratRegular, size: dashboardPrimaryTextSize), minWidth: minWidth, widthAddition: widthAddition, maxWidth: maxWidth).width
                return max(headerWidth, maxColumnWidth)
            case .Reading1, .Reading2, .Reading3:
                var textArray: [String] = []
                if headerText == .Reading1 {
                    textArray = self.itemArray.compactMap { $0.reading1?.stringValue ?? "" }
                }else if headerText == .Reading2 {
                    textArray = self.itemArray.compactMap { $0.reading2?.stringValue ?? "" }
                }else if headerText == .Reading3 {
                    textArray = self.itemArray.compactMap { $0.reading3?.stringValue ?? "" }
                }
                let maxColumnWidth = getMaxLabelSize(textArray: textArray, font: UIFont(name: .MontserratSemiBold, size: dashboardPrimaryTextSize), minWidth: minWidth, widthAddition: widthAddition, maxWidth: maxWidth).width
                return max(headerWidth, maxColumnWidth)
            }
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
            if self.itemArray.count > index {
                let item = self.itemArray[index]
                let textArray1 = [
                    item.r1Date?.transformToNewDateString(dateFormat: kResponseDateFormat, newDateFormat: ddMMyyyyStr) ?? "",
                    item.r1Date?.transformToNewDateString(dateFormat: kResponseDateFormat, newDateFormat: ddMMyyyyStr) ?? "",
                ]
                let maxHeight1 = getMaxLabelSize(textArray: textArray1, font: UIFont(name: .MontserratRegular, size: dashboardPrimaryTextSize), maxWidth: maxWidth, minHeight: minHeight, heightAddition: heightAddition).height
                let textArray2 = [
                    item.reading1?.stringValue ?? "",
                    item.reading2?.stringValue ?? "",
                    item.reading3?.stringValue ?? "",
                ]
                let maxHeight2 = getMaxLabelSize(textArray: textArray2, font: UIFont(name: .MontserratSemiBold, size: dashboardPrimaryTextSize), maxWidth: maxWidth, minHeight: minHeight, heightAddition: heightAddition).height
                return max(maxHeight1, maxHeight2, 10+40+10)
            }
            return 0
        }
    }
    
}
