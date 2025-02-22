//
//  WaterOutletTempAddReadingVC.swift
//  cafm
//
//  Created by NS on 12/10/24.
//
//

import UIKit
import SpreadsheetView
import SCLAlertView

class WaterOutletTempAddReadingVC: UIViewController {
    
    @IBOutlet weak var emptyView: EmptyView!
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var titleLbl: DefaultFontLabel!
    @IBOutlet weak var OutletTypeXIB: TextFiledDataXib!
    @IBOutlet weak var TemperatureXIB: TextFiledDataXib!
    @IBOutlet weak var LocationXIB: TextFiledDataXib!
    
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
    var siteCheckModel: SiteCheckModel?
    var siteCheckWaterOutletTemp: SiteCheckWaterOutletTemp?
    var assetsItemArray: [AssetDetailsResponse] = []
    var siteLayoutItemArray: [SiteLayoutModel] = []
    let itemArray: [ReadingData] = {
        let regularAttr: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: .MontserratRegular, size: dashboardPrimaryTextSize) as Any,
            .foregroundColor: UIColor.black
        ]
        let semiBoldAttr: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: .MontserratSemiBold, size: dashboardPrimaryTextSize) as Any,
            .foregroundColor: UIColor.red
        ]
        
        return [30, 60, 120].enumerated().compactMap { (index, time) in
            let attrStr1 = NSAttributedString(string: "Reading \(index+1) ", attributes: regularAttr)
            let attrStr2 = NSAttributedString(string: "\(time) seconds", attributes: semiBoldAttr)
            let attrStr = NSMutableAttributedString()
            attrStr.append(attrStr1)
            attrStr.append(attrStr2)
            return ReadingData(attributedString: attrStr)
        }
    }()
    
    private var headerColumnNames: [Fields] = Fields.spreadsheetFields
    
    private let kResponseDateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    private let kRequestDateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    private let ddMMyyyyStr = "dd/MM/yyyy"
    private let responseSavedStr = "Water outlet temperature data saved."
    private let pleaseFillInAllFieldsStr = "Please fill in all fields"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isModalInPresentation = true
        self.configureNavigationBar()
        self.emptyView.delegate = self
        self.setupViews()
        self.loadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.adjustSpreadsheetView()
    }
    
    func configureNavigationBar() {
        self.title = "Add Reading"
        
        let closeBtn = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(self.navCloseBtnClicked(_:)))
        self.navigationItem.leftBarButtonItem = closeBtn
        
        let saveBtn = getPrimaryNavigationBtn(title: "Save")
        saveBtn.addTarget(self, action: #selector(self.saveBtnClicked(_:)), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveBtn)
    }
    
    @objc func navCloseBtnClicked(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    @objc func saveBtnClicked(_ sender: UIButton) {
        guard self.itemArray.count >= 3 else { return }
        
        if self.itemArray[0].reading?.intValue != nil {
        }else {
            SCLAlertView.showErrorAlert(title: "Error", message: "Please enter Reading 1", cancelButtonTitle: "OK")
            return
        }
        if self.itemArray[1].reading?.intValue != nil {
        }else {
            SCLAlertView.showErrorAlert(title: "Error", message: "Please enter Reading 2", cancelButtonTitle: "OK")
            return
        }
        if self.itemArray[2].reading?.intValue != nil {
        }else {
            SCLAlertView.showErrorAlert(title: "Error", message: "Please enter Reading 3", cancelButtonTitle: "OK")
            return
        }
        
        let vc = siteCheckSB.instantiateViewController(withIdentifier: "WaterOutletTempActionVC") as! WaterOutletTempActionVC
        vc.addSiteCheckVC = self.addSiteCheckVC
        vc.waterOutletTempVC = self.waterOutletTempVC
        vc.waterOutletTempAddReadingVC = self
        vc.siteCheckModel = self.siteCheckModel
        vc.siteCheckWaterOutletTemp = self.siteCheckWaterOutletTemp
        vc.assetsItemArray = self.assetsItemArray
        let nav = UINavigationController(rootViewController: vc)
        self.present(nav, animated: true)
    }
    
    func continueSave() {
        let model = self.siteCheckWaterOutletTemp
        model?.r1Date = (self.itemArray[0].testDate ?? self.itemArray[0].testDate ?? self.itemArray[0].testDate)?.transformToString(dateFormat: kResponseDateFormat)
        model?.r2Date = model?.r1Date
        model?.r3Date = model?.r1Date
        model?.reading1 = self.itemArray[0].reading?.intValue
        model?.reading2 = self.itemArray[1].reading?.intValue
        model?.reading3 = self.itemArray[2].reading?.intValue

        self.dismiss(animated: true) { [weak self] in
            guard let self else { return }
            self.waterOutletTempVC?.action = true
            self.waterOutletTempVC?.action2 = false
            self.waterOutletTempVC?.continueSaveFromAddReading()
        }
    }
    
    func getLocationDisplayStr(_ model: SiteCheckWaterOutletTemp?) -> String? {
        if let model {
            if let floor = model.floor, let floorStr = self.siteLayoutItemArray.filter({ $0.nodeType == .floor }).first(where: { $0.id == floor.intValue })?.nodeName, let room = model.room, let roomStr = self.siteLayoutItemArray.filter({ $0.nodeType == .room }).first(where: { $0.id == room.intValue })?.nodeName {
                return "\(floorStr) > \(roomStr)"
            }
        }
        return nil
    }
}

//MARK: - Fields enum
extension WaterOutletTempAddReadingVC {
    enum Fields: String {
        case OutletType = "Outlet Type"
        case Temperature = "Temperature"
        case Location = "Location"
        
        case Empty = ""
        case TestDate = "Test Date"
        case Reading = "Reading"
        
        static var spreadsheetFields: [Fields] {
            return [.Empty, .TestDate, .Reading]
        }
    }
    
    class ReadingData {
        let attributedString: NSAttributedString
        var testDate: Date?
        var reading: String?
        
        init(attributedString: NSAttributedString) {
            self.attributedString = attributedString
        }
    }
}

//MARK: - EmptyViewDelegate
extension WaterOutletTempAddReadingVC: EmptyViewDelegate {
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
extension WaterOutletTempAddReadingVC {
    
    func loadData() {
        
    }
    
    typealias SuccessCompletion = (() -> Void)
    
}

//MARK: - setup views
extension WaterOutletTempAddReadingVC {
    
    func setupViews() {        
        self.OutletTypeXIB.title = Fields.OutletType.rawValue
        self.TemperatureXIB.title = Fields.Temperature.rawValue
        self.LocationXIB.title = Fields.Location.rawValue

        self.spreadsheetView.addCorner(value: 12)
        self.spreadsheetView.addBorder(width: 1, color: UIColor(appColor: .Separator2))
        self.spreadsheetView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.spreadsheetView.showsVerticalScrollIndicator = false
        self.spreadsheetView.showsHorizontalScrollIndicator = false
        self.spreadsheetView.bounces = false
        self.spreadsheetView.register(UINib(nibName: DashboardTableCell.className(), bundle: nil), forCellWithReuseIdentifier: DashboardTableCell.className())
        self.spreadsheetView.register(UINib(nibName: CustomTextFieldCell.className(), bundle: nil), forCellWithReuseIdentifier: CustomTextFieldCell.className())
        self.spreadsheetView.register(UINib(nibName: OptionBtnXibCell.className(), bundle: nil), forCellWithReuseIdentifier: OptionBtnXibCell.className())
        self.spreadsheetView.dataSource = self
        self.spreadsheetView.delegate = self
        
        self.reloadViews()
        self.reloadSpreadsheetView()
    }
    
    func reloadViews() {
        guard let response = self.siteCheckWaterOutletTemp else { return }
        
        if let assetId = response.assetId, let asset = self.assetsItemArray.first(where: { $0.assetId == Int(assetId) }) {
            self.titleLbl.text = getAssetDisplayStrForSiteCheck(asset)
        }
        
        self.OutletTypeXIB.bgColor = UIColor(appColor: .GrayStatusBG)
        self.OutletTypeXIB.isUserInteractionEnabled = false
        self.TemperatureXIB.bgColor = UIColor(appColor: .GrayStatusBG)
        self.TemperatureXIB.isUserInteractionEnabled = false
        self.LocationXIB.bgColor = UIColor(appColor: .GrayStatusBG)
        self.LocationXIB.isUserInteractionEnabled = false
        
        self.OutletTypeXIB.text = response.outletType ?? ""
        self.TemperatureXIB.text = response.temperature ?? ""
        self.LocationXIB.text = self.getLocationDisplayStr(response) ?? ""
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
        //let height = min(self.spreadsheetContainerView.frame.height, spreadsheetSize.height)
        let height = spreadsheetSize.height
        self.spreadsheetViewHeight.constant = height
        self.spreadsheetView.frame.size.height = height
    }
    
}

//MARK: - SpreadsheetViewDataSource, SpreadsheetViewDelegate
extension WaterOutletTempAddReadingVC: SpreadsheetViewDataSource, SpreadsheetViewDelegate {
    
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return self.headerColumnNames.count
    }
    
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 1+self.itemArray.count
    }
    
    func mergedCells(in spreadsheetView: SpreadsheetView) -> [CellRange] {
        let column = self.headerColumnNames.firstIndex(of: .TestDate) ?? 1
        return [CellRange(from: IndexPath(row: 1, column: column), to: IndexPath(row: self.itemArray.count, column: column))]
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
        }else {
            let index = indexPath.row-1
            if self.itemArray.count > index {
                let item = self.itemArray[index]
                let isEditing = true
                let bgColor = UIColor.white
                
                switch headerText {
                case .Empty:
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: DashboardTableCell.className(), for: indexPath) as! DashboardTableCell
                    cell.setGridLines(width: 1, color: UIColor(appColor: .Separator2))
                    
                    cell.backgroundColor = UIColor.white
                    cell.mainLbl.font = UIFont(name: .MontserratRegular, size: dashboardPrimaryTextSize)
                    cell.mainLbl.textColor = UIColor.black
                    
                    cell.mainLbl.attributedText = item.attributedString
                    return cell
                case .TestDate:
                    if index == 0 {
                        let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: OptionBtnXibCell.className(), for: indexPath) as! OptionBtnXibCell
                        cell.setGridLines(width: 1, color: UIColor(appColor: .Separator2))
                        cell.backgroundColor = UIColor.white
                        cell.isUserInteractionEnabled = isEditing
                        cell.optionXIB.dummyTF.backgroundColor = bgColor
                        
                        cell.optionXIB.btnDownClick.menu = nil
                        cell.optionXIB.btnDownClick.showsMenuAsPrimaryAction = false
                        cell.optionXIB.btnDownClick.removeAction()
                        
                        cell.optionXIB.imageView.image = UIImage(systemName: "calendar")
                        cell.optionXIB.lblText.text = item.testDate?.transformToString(dateFormat: ddMMyyyyStr) ?? ddMMyyyyStr
                        cell.optionXIB.btnDownClick.tag = index
                        cell.optionXIB.btnDownClick.addAction { [weak self] in
                            guard let self else { return }
                            CAFMDatePicker(delegate: nil).openDatePicker(presentVC: self, sender: cell.optionXIB.btnDownClick, tag: cell.optionXIB.btnDownClick.tag, selectedDate: item.testDate, hideButton: true) { [weak self] date in
                                guard let self else { return }
                                item.testDate = date
                                cell.optionXIB.lblText.text = date?.transformToString(dateFormat: ddMMyyyyStr) ?? ddMMyyyyStr
                            }
                        }
                        return cell
                    }
                case .Reading:
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: CustomTextFieldCell.className(), for: indexPath) as! CustomTextFieldCell
                    cell.setGridLines(width: 1, color: UIColor(appColor: .Separator2))
                    cell.backgroundColor = UIColor.white
                    cell.isUserInteractionEnabled = isEditing
                    cell.xib.textField.backgroundColor = bgColor
                    
                    let textChangeHandler: (() -> Void) = { [weak self] in
                        guard let self else { return }
                        let tf: UITextField! = cell.xib.textField
                        item.reading = tf.text
                        if let value = Int(tf.text ?? "") {
                            let temp = self.siteCheckWaterOutletTemp?.temperature
                            tf.textColor = (temp == "Hot" && value < 50) || (temp == "Cold" && value > 20) ? UIColor.red : UIColor(hexString: "#008000")
                        }
                    }
                    
                    cell.setupStepper()
                    cell.xib.textField.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
                    cell.xib.textField.placeholder = ""
                    cell.xib.textField.text = item.reading ?? ""
                    if let value = Int(cell.xib.textField.text ?? "") {
                        cell.stepper?.value = Double(value)
                    }
                    cell.xib.textField.tag = -1
                    cell.xib.textField.delegate = nil
                                        
                    textChangeHandler()
                    cell.xib.textField.textChanged { [weak self] in
                        guard self != nil else { return }
                        let tf: UITextField! = cell.xib.textField
                        if let value = Int(tf.text ?? "") {
                            cell.stepper?.value = Double(value)
                        }
                        textChangeHandler()
                    }
                    cell.stepperValueHandler = { [weak self] value in
                        guard self != nil else { return }
                        let tf: UITextField! = cell.xib.textField
                        tf.text = String(value)
                        textChangeHandler()
                    }
                    return cell
                default:
                    break
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
            switch headerText {
            case .Empty:
                let textArray = self.itemArray.compactMap { $0.attributedString.string }
                let maxColumnWidth = getMaxLabelSize(textArray: textArray, font: UIFont(name: .MontserratSemiBold, size: dashboardPrimaryTextSize), minWidth: minWidth, widthAddition: widthAddition, maxWidth: maxWidth).width
                return max(headerWidth, maxColumnWidth)
            case .TestDate:
                return max(headerWidth, 12+200+12)
            case .Reading:
                return max(headerWidth, 12+150+4+94+4+12)
            default:
                break
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
                let textArray = [item.attributedString.string]
                let maxHeight = getMaxLabelSize(textArray: textArray, font: UIFont(name: .MontserratSemiBold, size: dashboardPrimaryTextSize), maxWidth: maxWidth, minHeight: minHeight, heightAddition: heightAddition).height
                return max(maxHeight, 10+40+10)
            }
            return 0
        }
    }
    
}
