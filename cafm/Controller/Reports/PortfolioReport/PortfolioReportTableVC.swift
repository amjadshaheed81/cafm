//
//  PortfolioReportTableVC.swift
//  cafm
//
//  Created by NS on 27/10/24.
//
//

import UIKit
import SpreadsheetView
import SCLAlertView

class PortfolioReportTableVC: UIViewController {
    
    @IBOutlet weak var emptyView: EmptyView!
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var SearchXIB: CustomTextField!
    @IBOutlet weak var CityXIB: OptionBtnXib!
    @IBOutlet weak var AreaXIB: OptionBtnXib!
    @IBOutlet weak var StatusXIB: OptionBtnXib!
    @IBOutlet weak var ExportXIB: ExportBtnXib!
    
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
    
    var siteItemArray: [CreateSiteRequestModel] = []
    private var itemArray: [CreateSiteRequestModel] = []
    private var headerColumnNames: [TableFields] = TableFields.allCases
    
    private var selectedCity: String?
    private var selectedArea: String?
    private var selectedStatus: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isModalInPresentation = true
        self.configureNavigationBar()
        self.emptyView.delegate = self
        self.setupViews()
        self.loadData()
    }
    
    func configureNavigationBar() {
        self.title = "Portfolio Report"
        let closeBtn = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(self.navCloseBtnClicked(_:)))
        self.navigationItem.leftBarButtonItem = closeBtn
    }
    
    @objc func navCloseBtnClicked(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    @objc func exportBtnClicked(_ sender: UIButton) {
    }
    
}

//MARK: - Fields enum
extension PortfolioReportTableVC {
    enum Fields: String, CaseIterable {
        case Search = "Search Site"
        case City = "City"
        case Area = "Area"
        case Status = "Status"
        case Export = "Export"
        
        var placeholder: String {
            return rawValue
        }
    }
    enum TableFields: String, CaseIterable {
        case site = "Site"
        case Address = "Address"
        case Status = "Status"
        case OutstandingRisk = "Outstanding Risk"
        case Area = "Area"
        case ClientResponsibility = "Client Responsibility"
    }
}

//MARK: - EmptyViewDelegate
extension PortfolioReportTableVC: EmptyViewDelegate {
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
extension PortfolioReportTableVC {
    
    func loadData() {
        
    }
    
}

//MARK: - setup views
extension PortfolioReportTableVC {
    
    func setupViews() {
        self.itemArray = self.siteItemArray
        self.loadingStatus = .default
        
        let userRole: UserEnum = UserDefaults.standard.userRole
        if userRole != .admin {
            self.ExportXIB.isHidden = true
        }
        
        self.SearchXIB.textField.placeholder = Fields.Search.placeholder
        self.SearchXIB.textField.textChanged { [weak self] in
            guard let self else { return }
            self.searchFilter(searchText: self.SearchXIB.textField.text)
        }
        
        self.CityXIB.lblText.text = Fields.City.placeholder
        self.AreaXIB.lblText.text = Fields.Area.placeholder
        self.StatusXIB.lblText.text = Fields.Status.placeholder
        self.setupCityMenu()
        self.setupAreaMenu()
        self.setupStatusMenu()
        self.ExportXIB.btnExport.addTarget(self, action: #selector(self.exportBtnClicked(_:)), for: .touchUpInside)
        
        self.spreadsheetView.addCorner(value: 12)
        self.spreadsheetView.addBorder(width: 1, color: UIColor(appColor: .Separator2))
        self.spreadsheetView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.spreadsheetView.showsVerticalScrollIndicator = false
        self.spreadsheetView.showsHorizontalScrollIndicator = false
        self.spreadsheetView.bounces = false
        self.spreadsheetView.register(UINib(nibName: DashboardTableCell.className(), bundle: nil), forCellWithReuseIdentifier: DashboardTableCell.className())
        self.spreadsheetView.register(UINib(nibName: RiskViewXIB.className(), bundle: nil), forCellWithReuseIdentifier: RiskViewXIB.className())
        self.spreadsheetView.register(UINib(nibName: BadgeLabelCell.className(), bundle: nil), forCellWithReuseIdentifier: BadgeLabelCell.className())
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
    
    func setupCityMenu() {
        let view: OptionBtnXib = self.CityXIB
        let defaultStr = Fields.City.placeholder
        
        let allCases: [String] = self.siteItemArray.compactMap({ $0.city ?? "" }).reduce([String](), { $0.contains($1) ? $0 : $0 + [$1] })
        
        let performAction: ((String?) -> Void) = { [weak self] item in
            guard let self else { return }
            self.selectedCity = item
            view.lblText.text = item ?? defaultStr
            self.searchFilter(searchText: self.SearchXIB.textField.text)
            self.setupCityMenu()
        }
        
        var actions: [UIMenuElement] = []
        let titleAction = UIAction(title: defaultStr, state: self.selectedCity == nil ? .on : .off) { [weak self] action in
            guard self != nil else { return }
            performAction(nil)
        }
        actions.append(titleAction)
        
        for item in allCases {
            let action = UIAction(title: item, state: self.selectedCity == item ? .on : .off) { [weak self] action in
                guard self != nil else { return }
                performAction(item)
            }
            actions.append(action)
        }
        view.btnDownClick.menu = UIMenu(children: actions)
        view.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func setupAreaMenu() {
        let view: OptionBtnXib = self.AreaXIB
        let defaultStr = Fields.Area.placeholder
        
        let allCases: [String] = self.siteItemArray.compactMap({ $0.area ?? "" }).reduce([String](), { $0.contains($1) ? $0 : $0 + [$1] })
        
        let performAction: ((String?) -> Void) = { [weak self] item in
            guard let self else { return }
            self.selectedArea = item
            view.lblText.text = item ?? defaultStr
            self.searchFilter(searchText: self.SearchXIB.textField.text)
            self.setupAreaMenu()
        }
        
        var actions: [UIMenuElement] = []
        let titleAction = UIAction(title: defaultStr, state: self.selectedArea == nil ? .on : .off) { [weak self] action in
            guard self != nil else { return }
            performAction(nil)
        }
        actions.append(titleAction)
        
        for item in allCases {
            let action = UIAction(title: item, state: self.selectedArea == item ? .on : .off) { [weak self] action in
                guard self != nil else { return }
                performAction(item)
            }
            actions.append(action)
        }
        view.btnDownClick.menu = UIMenu(children: actions)
        view.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func setupStatusMenu() {
        let view: OptionBtnXib = self.StatusXIB
        let defaultStr = Fields.Status.placeholder
        
        let allCases: [String] = ["Open", "Closed", "Sold"]
        
        let performAction: ((String?) -> Void) = { [weak self] item in
            guard let self else { return }
            self.selectedStatus = item
            view.lblText.text = item ?? defaultStr
            self.searchFilter(searchText: self.SearchXIB.textField.text)
            self.setupStatusMenu()
        }
        
        var actions: [UIMenuElement] = []
        let titleAction = UIAction(title: defaultStr, state: self.selectedStatus == nil ? .on : .off) { [weak self] action in
            guard self != nil else { return }
            performAction(nil)
        }
        actions.append(titleAction)
        
        for item in allCases {
            let action = UIAction(title: item, state: self.selectedStatus == item ? .on : .off) { [weak self] action in
                guard self != nil else { return }
                performAction(item)
            }
            actions.append(action)
        }
        view.btnDownClick.menu = UIMenu(children: actions)
        view.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func searchFilter(searchText: String?) {
        guard let text = searchText?.trimmingSpacesAndLinesLowercased() else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            if text.isEmpty {
                self.itemArray = self.siteItemArray
            }else {
                self.itemArray = self.siteItemArray.filter({ item in
                    if item.siteName?.lowercased().contains(text) ?? false {
                        return true
                    }else if item.address1?.lowercased().contains(text) ?? false {
                        return true
                    }
                    return false
                })
            }
            
            if let selectedCity, selectedCity != Fields.City.placeholder {
                self.itemArray = self.siteItemArray.filter({ $0.city?.lowercased() == selectedCity.lowercased() })
            }
            if let selectedArea, selectedArea != Fields.Area.placeholder {
                self.itemArray = self.siteItemArray.filter({ $0.area?.lowercased() == selectedArea.lowercased() })
            }
            if let selectedStatus, selectedStatus != Fields.Status.placeholder {
                self.itemArray = self.siteItemArray.filter({ $0.status?.lowercased() == selectedStatus.lowercased() })
            }
            
            self.loadingStatus = self.itemArray.isEmpty ? .noResponse : .default
            self.reloadSpreadsheetView()
        }
    }
    
    func getSiteAttributedText(_ item: CreateSiteRequestModel) -> NSAttributedString {
        let siteName = (item.siteName ?? "") + "\n"
        let postCode = item.postCode ?? ""
        
        let attributedText = NSMutableAttributedString()
        
        // Define attributes
        let siteNameAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: .MontserratRegular, size: dashboardPrimaryTextSize) as Any,
            .foregroundColor: UIColor(appColor: .AppTint)
        ]
        let postCodeAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: .MontserratRegular, size: dashboardPrimaryTextSize) as Any,
            .foregroundColor: UIColor.black
        ]
        
        // Create attributed strings
        let siteNameString = NSAttributedString(string: siteName, attributes: siteNameAttributes)
        let postCodeString = NSAttributedString(string: postCode, attributes: postCodeAttributes)
        
        // Append to attributedText
        attributedText.append(siteNameString)
        attributedText.append(postCodeString)
        
        return attributedText
    }
    
}

//MARK: - SpreadsheetViewDataSource, SpreadsheetViewDelegate
extension PortfolioReportTableVC: SpreadsheetViewDataSource, SpreadsheetViewDelegate {
    
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
                
                switch headerText {
                case .site:
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: DashboardTableCell.className(), for: indexPath) as! DashboardTableCell
                    cell.setGridLines(width: 1, color: UIColor(appColor: .Separator2))
                    cell.backgroundColor = UIColor.white
                    cell.mainLbl.font = UIFont(name: .MontserratRegular, size: dashboardPrimaryTextSize)
                    cell.mainLbl.attributedText = self.getSiteAttributedText(item)
                    return cell
                case .Address, .Area, .ClientResponsibility:
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: DashboardTableCell.className(), for: indexPath) as! DashboardTableCell
                    cell.setGridLines(width: 1, color: UIColor(appColor: .Separator2))
                    cell.backgroundColor = UIColor.white
                    cell.mainLbl.font = UIFont(name: .MontserratRegular, size: dashboardPrimaryTextSize)
                    cell.mainLbl.textColor = UIColor.black
                    if headerText == .Address {
                        cell.mainLbl.text = item.address1 ?? ""
                    }else if headerText == .Area {
                        cell.mainLbl.text = item.area ?? ""
                    }else if headerText == .ClientResponsibility {
                        cell.mainLbl.text = (item.clientResponsiblity ?? false).yesNoValue
                    }
                    return cell
                case .Status:
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: BadgeLabelCell.className(), for: indexPath) as! BadgeLabelCell
                    cell.setGridLines(width: 1, color: UIColor(appColor: .Separator2))
                    cell.backgroundColor = UIColor.white
                    cell.mainLbl.font = UIFont(name: .MontserratSemiBold, size: dashboardPrimaryTextSize)
                    cell.badgeView.addCorner(value: cell.badgeView.frame.height/2)
                    let status: ListStatusBadge = ListStatusBadge.status(from: item.status)
                    cell.badgeView.backgroundColor = status.bgColor
                    cell.mainLbl.textColor = status.textColor
                    cell.mainLbl.text = status.displayText
                    return cell
                case .OutstandingRisk:
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: RiskViewXIB.className(), for: indexPath) as! RiskViewXIB
                    cell.setGridLines(width: 1, color: UIColor(appColor: .Separator2))
                    [cell.redRiskLbl, cell.amberRiskLbl, cell.yelloriskLbl, cell.greenRiskLbl].forEach { label in
                        label.font = UIFont(name: .MontserratSemiBold, size: dashboardPrimaryTextSize+1)
                        addCornerToView(label, value: 5)
                    }
                    cell.redRiskLbl.text = "\(item.riskScoreModel?.riskScoreRed ?? 0)"
                    cell.amberRiskLbl.text = "\(item.riskScoreModel?.riskScoreAmber ?? 0)"
                    cell.yelloriskLbl.text = "\(item.riskScoreModel?.riskScoreYellow ?? 0)"
                    cell.greenRiskLbl.text = "\(item.riskScoreModel?.riskScoreGreen ?? 0)"
                    return cell
                }
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
            
            if !self.loadingStatus.hasData {
                let maxColumnWidth = getLabelSize(text: self.loadingStatus.rawValue, font: UIFont(name: .MontserratRegular, size: dashboardPrimaryTextSize), minWidth: minWidth, widthAddition: widthAddition).width
                return max(headerWidth, maxColumnWidth/CGFloat(self.headerColumnNames.count))
            }else {
                switch headerText {
                case .site, .Address, .Area, .ClientResponsibility:
                    var textArray: [String] = []
                    if headerText == .site {
                        textArray = itemArray.compactMap({ self.getSiteAttributedText($0).string })
                    }else if headerText == .Address {
                        textArray = itemArray.compactMap({ $0.address1 ?? "" })
                    }else if headerText == .Area {
                        textArray = itemArray.compactMap({ $0.area ?? "" })
                    }else if headerText == .ClientResponsibility {
                        textArray = itemArray.compactMap({ ($0.clientResponsiblity ?? false).yesNoValue })
                    }
                    let maxColumnWidth = getMaxLabelSize(textArray: textArray, font: UIFont(name: .MontserratRegular, size: dashboardPrimaryTextSize), minWidth: minWidth, widthAddition: widthAddition, maxWidth: maxWidth).width
                    return max(headerWidth, maxColumnWidth)
                case .Status:
                    let refSize = CGSize(width: 12+8+10+8+12, height: 10+4+18+4+10)
                    let widthAddition: CGFloat = 12+8+8+12
                    let minWidth = refSize.width-widthAddition
                    let textArray: [String] = itemArray.compactMap { ListStatusBadge.status(from: $0.status).displayText }
                    let maxColumnWidth = getMaxLabelSize(textArray: textArray, font: UIFont(name: .MontserratSemiBold, size: dashboardPrimaryTextSize), minWidth: minWidth, widthAddition: widthAddition, maxWidth: maxWidth).width
                    return max(headerWidth, maxColumnWidth)
                case .OutstandingRisk:
                    let totalItem: CGFloat = 4
                    let itemWidth: CGFloat = 40
                    let spacing: CGFloat = 5
                    let padding: CGFloat = 10
                    let refWidth = (padding*2)+(itemWidth*totalItem)+(spacing*(totalItem-1))
                    return max(headerWidth, refWidth)
                }
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
        }else if !self.loadingStatus.hasData {
            return getLabelSize(text: self.loadingStatus.rawValue, font: UIFont(name: .MontserratRegular, size: dashboardPrimaryTextSize), minHeight: minHeight, heightAddition: heightAddition).height
        }else {
            let index = row-1
            if self.itemArray.count > index {
                let item = self.itemArray[index]
                
                let textArray = [
                    self.getSiteAttributedText(item).string,
                    item.address1 ?? "",
                    item.area ?? "",
                    (item.clientResponsiblity ?? false).yesNoValue,
                ]
                let maxHeight = getMaxLabelSize(textArray: textArray, font: UIFont(name: .MontserratRegular, size: dashboardPrimaryTextSize), maxWidth: maxWidth, minHeight: minHeight, heightAddition: heightAddition).height
                
                let refSize1 = CGSize(width: 12+8+10+8+12, height: 10+4+18+4+10)
                let heightAddition1: CGFloat = 10+4+4+10
                let minHeight1 = refSize1.height-heightAddition1
                let textArray1 = [
                    ListStatusBadge.status(from: item.status).displayText
                ]
                let maxHeight1 = getMaxLabelSize(textArray: textArray1, font: UIFont(name: .MontserratSemiBold, size: dashboardPrimaryTextSize), maxWidth: maxWidth, minHeight: minHeight1, heightAddition: heightAddition1).height
                
                // risk score
                let minHeight2: CGFloat = 10+40+10
                
                return max(maxHeight, maxHeight1, minHeight2)
            }
        }
        return 0
    }
    
}
