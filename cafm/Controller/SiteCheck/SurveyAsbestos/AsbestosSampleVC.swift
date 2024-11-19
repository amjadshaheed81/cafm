//
//  AsbestosSampleVC.swift
//  cafm
//
//  Created by NS on 04/10/24.
//
//

import UIKit
import SCLAlertView
import SpreadsheetView

class AsbestosSampleVC: UIViewController {
    
    @IBOutlet weak var emptyView: EmptyView!
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var buttonsViewHeight: NSLayoutConstraint!
    @IBOutlet weak var addNewSampleBtn: ActionButton!
    
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
    var siteCheckModel: SiteCheckModel?
    var itemArray: [SiteCheckAsbestosSample] = []
    var asbestosLOVDict: [LOVTypeEnum: [LOV_Model]] = [:]
    var siteLayoutItemArray: [SiteLayoutModel] = []
    
    private var headerColumnNames: [Fields] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isModalInPresentation = true
        self.configureNavigationBar()
        self.emptyView.delegate = self
        self.setupViews()
        self.loadData()
    }
    
    func configureNavigationBar() {
        self.title = "Asbestos Samples"
        let closeBtn = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(self.navCloseBtnClicked(_:)))
        self.navigationItem.leftBarButtonItem = closeBtn
        self.configureNavigationBackButton()
    }
    
    @objc func navCloseBtnClicked(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    @IBAction func addNewSampleBtnClicked(_ sender: ActionButton) {
        let item = SiteCheckAsbestosSample()
        if self.itemArray.count > 0, let sampleId = self.itemArray[self.itemArray.count-1].sampleId {
            item.sampleNo = "AS00"+"\(sampleId+1)"
        }else {
            item.sampleNo = "AS00NaN"
        }
        item.isEditing = true
        item.isForAddNew = true
        self.itemArray.append(item)
        self.reloadSpreadsheetView()
    }
    
    @objc func expandItemBtnAction(_ sender: ActionButton) {
        let index = sender.tag
        if self.itemArray.count > index {
            let item = self.itemArray[index]
            let vc = siteCheckSB.instantiateViewController(withIdentifier: "AsbestosSampleDetailVC") as! AsbestosSampleDetailVC
            vc.addSiteCheckVC = self.addSiteCheckVC
            vc.asbestosSampleVC = self
            vc.siteCheckModel = self.siteCheckModel
            vc.response = item
            vc.asbestosLOVDict = self.asbestosLOVDict
            vc.siteLayoutItemArray = self.siteLayoutItemArray
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}

//MARK: - Fields enum
extension AsbestosSampleVC {
    enum Fields: String, CaseIterable {
        case SampleNo = "Sample No."
        case Location = "Location"
        case Product = "Product"
        case Qty = "Qty"
        case SurfaceCoating = "Surface Coating"
        case Condition = "Condition"
        case Access = "Access"
        case AsbestosType = "Asbestos Type"
        case MaterialScore = "Material Score"
        case PriorityScore = "Priority Score"
        case TotalScore = "Total Score"
        case Empty = ""
        
        var lovType: LOVTypeEnum? {
            switch self {
            case .SampleNo: return nil
            case .Location: return .ASBESTOS_PA_LOCATION
            case .Product: return .ASBESTOS_MATERIAL_ASSESSMENT_PRODUCT_TYPE
            case .Qty: return nil
            case .SurfaceCoating: return .ASBESTOS_MATERIAL_SURFACE
            case .Condition: return .ASBESTOS_MATERIAL_DAMAGE
            case .Access: return .ASBESTOS_PA_ACCESSIBILITY
            case .AsbestosType: return .ASBESTOS_MATERIAL_ASBESTOS_TYPE
            case .MaterialScore: return nil
            case .PriorityScore: return nil
            case .TotalScore: return nil
            case .Empty: return nil
            }
        }
        
        func getDisplayValue(_ item: SiteCheckAsbestosSample?, asbestosLOVDict: [LOVTypeEnum: [LOV_Model]]) -> String? {
            guard let item else { return nil }
            var value: String?
            switch self {
            case .SampleNo: return getSiteCheckAsbestosSampleNo(item)
            case .Location: value = item.location
            case .Product: value = item.productType
            case .Qty: return item.quantity?.stringValue
            case .SurfaceCoating: value = item.surfaceTreatment
            case .Condition: value = item.damage
            case .Access: value = item.accessibility
            case .AsbestosType: value = item.asbestosType
            case .MaterialScore: return item.totalMatScore?.stringValue
            case .PriorityScore: return item.totalPriScore?.stringValue
            case .TotalScore: return item.totalRiskScore?.stringValue
            case .Empty: return nil
            }
            if let value, let lovType = self.lovType, let desc = asbestosLOVDict[lovType]?.first(where: { $0.lovValue == value })?.lovDesc {
                return desc
            }
            return nil
        }
    }
}

//MARK: - EmptyViewDelegate
extension AsbestosSampleVC: EmptyViewDelegate {
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
extension AsbestosSampleVC {
    
    func loadData() {
        
    }
    
    func reloadAfterGetSiteCheckAsbestosSampleByCheckId(array: [SiteCheckAsbestosSample]) {
        self.itemArray = array
        self.reloadViews()
    }
    
}

//MARK: - setup views
extension AsbestosSampleVC {
    
    func setupViews() {
        self.headerColumnNames = [
            .SampleNo,
            .Location,
            .Product,
            .Qty,
            .SurfaceCoating,
            .Condition,
            .Access,
            .AsbestosType,
            .MaterialScore,
            .PriorityScore,
            .TotalScore,
            .Empty,
        ]
        
        if self.itemArray.isEmpty {
            let item = SiteCheckAsbestosSample()
            item.sampleNo = "AS001"
            item.isEditing = true
            item.isForAddNew = true
            self.itemArray.append(item)
        }
        
        self.spreadsheetView.addCorner(value: 12)
        self.spreadsheetView.addBorder(width: 1, color: UIColor(appColor: .Separator2))
        self.spreadsheetView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.spreadsheetView.showsVerticalScrollIndicator = false
        self.spreadsheetView.showsHorizontalScrollIndicator = false
        self.spreadsheetView.bounces = false
        self.spreadsheetView.register(UINib(nibName: DashboardTableCell.className(), bundle: nil), forCellWithReuseIdentifier: DashboardTableCell.className())
        self.spreadsheetView.register(UINib(nibName: ActionButtonsCell.className(), bundle: nil), forCellWithReuseIdentifier: ActionButtonsCell.className())
        self.spreadsheetView.dataSource = self
        self.spreadsheetView.delegate = self
        
        self.reloadViews()
        self.reloadSpreadsheetView()
    }
    
    func reloadViews() {
        //if !self.itemArray.filter({ $0.isEditing != true && $0.isForAddNew != true }).isEmpty {
        //    self.buttonsViewHeight.constant = .zero
        //    self.buttonsView.frame.size.height = self.buttonsViewHeight.constant
        //    self.buttonsView.isHidden = true
        //}
    }
    
    func reloadSpreadsheetView() {
        self.spreadsheetView.reloadData()
        self.spreadsheetView.contentOffset = CGPoint.zero
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
extension AsbestosSampleVC: SpreadsheetViewDataSource, SpreadsheetViewDelegate {
    
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
                let isEditing = item.isEditing ?? false
                //let isForAddNew = item.isForAddNew ?? false
                //let bgColor = isEditing ? UIColor.white : UIColor(appColor: .GrayStatusBG)
                
                if headerText == .Empty {
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: ActionButtonsCell.className(), for: indexPath) as! ActionButtonsCell
                    cell.setGridLines(width: 1, color: UIColor(appColor: .Separator2))
                    cell.backgroundColor = UIColor.white
                    
                    cell.isCenterHorizontally = true
                    cell.stackView.arrangedSubviews.forEach { view in
                        cell.stackView.removeArrangedSubview(view)
                        view.removeFromSuperview()
                    }
                    
                    let refHeight = cell.stackView.frame.height
                    let btn = getActionButton(size: CGSize(width: refHeight, height: refHeight), tag: index, image: UIImage(systemName: "plus"), target: self, action: #selector(self.expandItemBtnAction(_:)))
                    cell.stackView.addArrangedSubview(btn)
                    return cell
                }else {
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: DashboardTableCell.className(), for: indexPath) as! DashboardTableCell
                    cell.setGridLines(width: 1, color: UIColor(appColor: .Separator2))
                    
                    cell.backgroundColor = UIColor.white
                    cell.mainLbl.font = UIFont(name: .MontserratRegular, size: dashboardPrimaryTextSize)
                    cell.mainLbl.textColor = UIColor.black
                    
                    cell.mainLbl.text = headerText.getDisplayValue(item, asbestosLOVDict: self.asbestosLOVDict) ?? ""
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
                if headerText == .Empty {
                    return max(headerWidth, 12+40+12)
                }else {
                    let textArray = self.itemArray.compactMap { headerText.getDisplayValue($0, asbestosLOVDict: self.asbestosLOVDict) ?? "" }
                    let maxColumnWidth = getMaxLabelSize(textArray: textArray, font: UIFont(name: .MontserratRegular, size: dashboardPrimaryTextSize), minWidth: minWidth, widthAddition: widthAddition, maxWidth: maxWidth).width
                    return max(headerWidth, maxColumnWidth)
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
                let textArray = Fields.allCases.filter({ $0 != .Empty }).compactMap { $0.getDisplayValue(item, asbestosLOVDict: self.asbestosLOVDict) }
                let maxHeight = getMaxLabelSize(textArray: textArray, font: UIFont(name: .MontserratRegular, size: dashboardPrimaryTextSize), maxWidth: maxWidth, minHeight: minHeight, heightAddition: heightAddition).height
                return max(maxHeight, 10+40+10)
            }
            return 0
        }
    }
    
}
