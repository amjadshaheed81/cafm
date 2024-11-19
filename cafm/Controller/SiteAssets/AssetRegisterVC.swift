//
//  AssetRegisterVC.swift
//  cafm
//
//  Created by Savan Lakhani on 07/09/24.
//

import UIKit
import SCLAlertView
import SpreadsheetView
import SDWebImage

class AssetRegisterVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var txField1: UITextField!
    @IBOutlet weak var txField2: UITextField!
    
    @IBOutlet weak var viewRoomXIB: OptionBtnXib!
    @IBOutlet weak var viewAssetCategoryXIB: OptionBtnXib!
    @IBOutlet weak var viewLocatinXIB: OptionBtnXib!
    @IBOutlet weak var viewFloorXIB: OptionBtnXib!
    
    @IBOutlet weak var cloneLbl: UILabel!
    @IBOutlet weak var spreedSheetView: SpreadsheetView!
    
    @IBOutlet weak var filterMainViewHeight: NSLayoutConstraint!
    @IBOutlet weak var filterControlView: UIControl!
    @IBOutlet weak var txField1Height: NSLayoutConstraint!
    @IBOutlet weak var txField2Height: NSLayoutConstraint!
    @IBOutlet weak var filterMainView: UIView!
    @IBOutlet weak var filterLbl: UILabel!
    @IBOutlet weak var viewAssetTopCons: NSLayoutConstraint!
    @IBOutlet weak var viewFloorTopCons: NSLayoutConstraint!
    @IBOutlet weak var txField1TopCons: NSLayoutConstraint!
    @IBOutlet weak var txField2TopCons: NSLayoutConstraint!
    
    @IBOutlet weak var showListImageView: UIImageView!
    
    @IBOutlet weak var filterControlHeight: NSLayoutConstraint!
    @IBOutlet weak var createAssetWidth: NSLayoutConstraint!
    @IBOutlet weak var cloneLblLeadingCons: NSLayoutConstraint!
    @IBOutlet weak var createAssetHeight: NSLayoutConstraint!
    @IBOutlet weak var printView: UIControl!
    @IBOutlet weak var exportView: UIControl!
    @IBOutlet weak var addNewLbl: UILabel!
    @IBOutlet weak var createAssetView: UIControl!
    
    @IBOutlet weak var cloneBtn: UIButton!
    @IBOutlet weak var exportViewLeading: NSLayoutConstraint!
    @IBOutlet weak var exportViewSafeAreaLeading: NSLayoutConstraint!
    
    var siteCategoryArray: [String] = []
    var assetCategoryResponse: [LOV_Model?] = []
    
    var searchAssetCategotyInd = 0
    //var searchAssetLocationInd = 0
    var searchAssetLocation: String?
    var searchAssetRoomInd = 0
    var searchAssetFloorInd = 0
    
    var selectedIndexes: Set<Int> = []
    
    let itemArray = ["SUMMARY", "DOORS", "PAT", "PASSIVE FIRE PROTECTION"]
    
    //header rows
    let summaryRowArray = ["Box", "Asset ID", "Asset Name", "Manufacturer", "Category", "Location", "Actions"]
    let doorRowArray = ["Box", "Asset ID", "Asset Name", "Door Size", "Fire Rating", "Location", "Door Finish",  "Vision Panel", "Frame", "Actions"]
    let patRowArray = ["Box", "Asset ID", "Asset Name", "Manufacturer", "Category", "Location", "Date Tested", "Next Test", "Status", "Actions"]
    let pfpRowArray = ["Box", "Asset ID", "Asset Name", "Material", "Product", "Location", "Service", "Dim","Qty", "Area", "Actions"]
    
    let qrBaseURL = "http://cpc-beta.ukwest.cloudapp.azure.com/#/view-asset?assetId="


    var selectedTabIndex: Int = 0

    var siteLayoutDataArray: [SiteLayoutModel] = []
    var assetDetailsResponse: [AssetDetailsResponse] = []
    var assetDetailsResponseList = [AssetDetailsResponse]()
    
    var loadingStatus: LoadingStatus = .loading
    
    let siteID = UserConstants.shared.selectedSiteID
    
    var assetRegisterData: AssetRegisterData = .none
    
    var isDataNotReceive : Bool {
        return (loadingStatus == .loading || loadingStatus == .failed || loadingStatus == .noResponse || loadingStatus == .noInternet)
    }

    var isFromReports: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureNavigationBackButton()
        self.initialSetUp()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if self.isFromReports {
            let userRole: UserEnum = UserDefaults.standard.userRole
            if userRole == .admin || userRole == .manager {
                self.exportViewLeading.isActive = false
                self.exportViewSafeAreaLeading.isActive = true
                self.exportView.frame.origin.x = self.exportViewSafeAreaLeading.constant
            }else {
                self.createAssetHeight.constant = 0
                self.createAssetView.frame.size.height = self.createAssetHeight.constant
            }
        }
        self.filterMainView.frame.size.height = self.filterMainViewHeight.constant
    }
    
    func toggleCheckbox(at row: Int) {
        if selectedIndexes.contains(row) {
            if selectedIndexes.contains(0) {
                selectedIndexes.remove(0)
            }
            selectedIndexes.remove(row)  // Uncheck the box
        } else {
            selectedIndexes.insert(row)  // Check the box
            if selectedIndexes.count == self.assetDetailsResponseList.count {
                if !selectedIndexes.contains(0) {
                    selectedIndexes.insert(0)
                }
            }
        }
        spreedSheetView.reloadData()
    }

    func toggleSelectAll() {
        if selectedIndexes.count == assetDetailsResponseList.count + 1 {
            selectedIndexes.removeAll()
        } else {
            selectedIndexes = Set(0..<assetDetailsResponseList.count+1)
        }
        spreedSheetView.reloadData()
    }
    
    @objc func navCloseBtnClicked(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    func initialSetUp() {
        self.title = "Asset Register"
        if self.isFromReports {
            self.isModalInPresentation = true
            let closeBtn = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(self.navCloseBtnClicked(_:)))
            self.navigationItem.leftBarButtonItem = closeBtn
            
            self.createAssetView.isHidden = true
            self.cloneLbl.isHidden = true
            self.cloneBtn.isHidden = true
            self.printView.isHidden = true
            let userRole: UserEnum = UserDefaults.standard.userRole
            if userRole != .admin && userRole != .manager {
                self.exportView.isHidden = true
            }
        }
        
        self.filterLbl.font = UIFont(name: .MontserratMedium, size: 20)
        
        if let siteID = self.siteID {
            self.assetRegisterData = .assetSummaryAPI(siteId: siteID)
        }
        
        self.cloneLbl.font = UIFont(name: .MontserratMedium, size: 17.5)
        self.addNewLbl.font = UIFont(name: .MontserratMedium, size: 17)
        self.viewAssetCategoryXIB.lblText.font = UIFont(name: .MontserratMedium, size: 17)
        self.viewLocatinXIB.lblText.font = UIFont(name: .MontserratMedium, size: 17)
        self.viewFloorXIB.lblText.font = UIFont(name: .MontserratMedium, size: 17)
        self.viewRoomXIB.lblText.font = UIFont(name: .MontserratMedium, size: 17)
        self.txField1.font = UIFont(name: .MontserratMedium, size: 15)
        self.txField2.font = UIFont(name: .MontserratMedium, size: 15)
        
        self.txField1Height.constant = 0.0
        self.txField2Height.constant = 0.0
        self.txField1TopCons.constant = 0.0
        self.txField2TopCons.constant = 0.0
        self.viewAssetTopCons.constant = 0.0
        self.viewFloorTopCons.constant = 0.0
        self.filterMainViewHeight.constant = 55.0
        self.filterControlHeight.constant = 45.0
        self.filterMainView.frame.size.height = self.filterMainViewHeight.constant
        self.filterMainView.clipsToBounds = true
        
        self.txField1.placeholder = "Asset Name"
        self.txField2.placeholder = "ManuFacturer"
        self.txField1.text = ""
        self.txField2.text = ""
        self.viewAssetCategoryXIB.lblText.text = "Category"
        self.viewLocatinXIB.lblText.text = "Location"
        self.viewFloorXIB.lblText.text = "Floor"
        self.viewRoomXIB.lblText.text = "Room"
                
        self.txField1.delegate = self
        self.txField2.delegate = self
        
        self.txField1.tag = 0
        self.txField2.tag = 1
        
        //set corner and border to view
        self.cloneLbl.addBorder(color: .gray.withAlphaComponent(0.3))
        self.txField1.addBorder(color: .gray.withAlphaComponent(0.3))
        self.txField2.addBorder(color: .gray.withAlphaComponent(0.3))
        self.filterMainView.addBorder(color: .gray.withAlphaComponent(0.3))
        self.viewAssetCategoryXIB.addBorder(color: .gray.withAlphaComponent(0.3))
        self.viewLocatinXIB.addBorder(color: .gray.withAlphaComponent(0.3))
        self.viewFloorXIB.addBorder(color: .gray.withAlphaComponent(0.3))
        self.viewRoomXIB.addBorder(color: .gray.withAlphaComponent(0.3))
        
        self.txField1.addCorner()
        self.txField2.addCorner()
        self.cloneLbl.addCorner()
        self.filterControlView.addCorner()
        self.filterMainView.addCorner()
        self.createAssetView.addCorner()
        self.exportView.addCorner()
        self.printView.addCorner()
        self.viewAssetCategoryXIB.addCorner()
        self.viewLocatinXIB.addCorner()
        self.viewFloorXIB.addCorner()
        self.viewRoomXIB.addCorner()
        
        //set constraint to view
        self.createAssetHeight.constant = 40.0
        self.createAssetWidth.constant = 110.0
        
        //api calling
        self.loadAssetCategory()
        self.loadLayoutsData()
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.reloadData()
        self.collectionView(self.collectionView, didSelectItemAt: IndexPath(row: 0, section: 0))
        
        self.setUpSpreedSheetView()
        
        if self.siteID != nil {
            //summary data api calling
            self.loadAssetRegisterData(apiService: assetRegisterData)
        }
    }
    
    func setUpSpreedSheetView() {
        self.spreedSheetView.register(UINib(nibName: String(describing: CellTextXib.self), bundle: nil), forCellWithReuseIdentifier: String(describing: CellTextXib.self))
        self.spreedSheetView.register(UINib(nibName: String(describing: SiteAssetsActionXIB.self), bundle: nil), forCellWithReuseIdentifier: String(describing: SiteAssetsActionXIB.self))
        self.spreedSheetView.register(UINib(nibName: String(describing: StatusXIb.self), bundle: nil), forCellWithReuseIdentifier: String(describing: StatusXIb.self))
        self.spreedSheetView.register(UINib(nibName: String(describing: CheckBoxXIB.self), bundle: nil), forCellWithReuseIdentifier: String(describing: CheckBoxXIB.self))
        spreedSheetView.bounces = false
        spreedSheetView.dataSource = self
        spreedSheetView.delegate = self
        spreedSheetView.showsHorizontalScrollIndicator = false
        spreedSheetView.showsVerticalScrollIndicator = false
        spreedSheetView.addCorner()
        spreedSheetView.addBorder(color: .gray.withAlphaComponent(0.4))
    }
    
    @IBAction func openFilterVIew(_ sender: Any) {
        UIView.animate(withDuration: 0.2) {
            if self.filterMainViewHeight.constant != 251.0 {
                self.filterMainViewHeight.constant = 251.0
                self.txField1Height.constant = 40.0
                self.txField2Height.constant = 40.0
                self.txField1TopCons.constant = 8.0
                self.txField2TopCons.constant = 8.0
                self.viewAssetTopCons.constant = 10.0
                self.viewFloorTopCons.constant = 10.0
                self.filterMainView.frame.size.height = self.filterMainViewHeight.constant
                self.filterControlHeight.constant = 45.0
                self.showListImageView.image = UIImage(systemName: "chevron.up")
            }else {
                self.filterMainViewHeight.constant = 55.0
                self.txField1Height.constant = 0.0
                self.txField2Height.constant = 0.0
                self.txField1TopCons.constant = 0.0
                self.txField2TopCons.constant = 0.0
                self.viewAssetTopCons.constant = 0.0
                self.viewFloorTopCons.constant = 0.0
                self.filterControlHeight.constant = 45.0
                self.filterMainView.frame.size.height = self.filterMainViewHeight.constant
                self.showListImageView.image = UIImage(systemName: "chevron.down")
            }
        }
    }
        
    func convertAssetDetailsToCSVRows(from assets: [AssetDetailsResponse]) -> [[String]] {
        
        // Create the header row
        let header = [
            "Asset ID", "Site ID", "Site Name", "Asset Name", "Manufacturer", "Category",
            "Sub Category", "Sub Category 2", "Sub Category 3", "Model", "Serial Number",
            "Related Asset ID", "Related Asset Name", "Folder ID", "Folder Name", "Image",
            "PAT Item", "PFP Item", "Door Item", "Barcode", "Position", "Floor", "Room",
            "Purchase Date", "Invoice File", "Supplier", "Transaction ID", "Cost",
            "Valuation Date", "Valuation Value", "Valuation User ID", "Valuation User Name",
            "Disposal Date", "Disposal Value", "Disposal To", "assetPATItems", "assetPFPItem", "assetDoorSpecifications"
        ]
        
        var csvData: [[String]] = []
        csvData.append(header)
        
        for asset in assets {
            // Split into sub-expressions for better compiler performance
            let assetId = "\(asset.assetId ?? 0)"
            let siteId = "\(asset.siteId ?? 0)"
            let siteName = asset.siteName ?? ""
            let assetName = asset.assetName ?? ""
            let manufacturer = asset.manufacturer ?? ""
            let category = asset.category ?? ""
            let subCategory = asset.subCategory ?? ""
            let subCategory2 = asset.subCategory2 ?? ""
            let subCategory3 = asset.subCategory3 ?? ""
            let model = asset.model ?? ""
            let serialNumber = asset.serialNumber ?? ""
            let relatedAssetId = asset.relatedAssetId ?? ""
            let relatedAssetName = asset.relatedAssetName ?? ""
            let folderId = "\(asset.folderId ?? 0)"
            let folderName = asset.folderName ?? ""
            let image = asset.image ?? ""
            let patItem = "\(asset.patItem ?? false)"
            let pfpItem = "\(asset.pfpItem ?? false)"
            let doorItem = "\(asset.doorItem ?? false)"
            let barcode = asset.barcode ?? ""
            let position = asset.position ?? ""
            let floor = asset.floor ?? ""
            let room = asset.room ?? ""
            let purchaseDate = asset.purchaseDate ?? ""
            let invoiceFile = asset.invoiceFile ?? ""
            let supplier = asset.supplier ?? ""
            let transactionId = asset.transactionId ?? ""
            let cost = asset.cost ?? ""
            let valuationDate = asset.valuationDate ?? ""
            let valuationValue = asset.valuationValue ?? ""
            let valuationUserId = "\(asset.valuationUserId ?? 0)"
            let valuationUserName = asset.valuationUserName ?? ""
            let disposalDate = asset.disposalDate ?? ""
            let disposalValue = asset.disposalValue ?? ""
            let disposalTo = asset.disposalTo ?? ""
            
            let row = [
                assetId, siteId, siteName, assetName, manufacturer, category, subCategory, subCategory2, subCategory3,
                model, serialNumber, relatedAssetId, relatedAssetName, folderId, folderName, image, patItem, pfpItem,
                doorItem, barcode, position, floor, room, purchaseDate, invoiceFile, supplier, transactionId, cost,
                valuationDate, valuationValue, valuationUserId, valuationUserName, disposalDate, disposalValue, disposalTo, "", "", ""
            ]
            
            csvData.append(row)

        }
 
        return csvData
    }
    
    func loadAssetRegisterData(apiService: AssetRegisterData) {
        
        loadingStatus = .loading
        
        let apiService = ApiService.getRegistedAssetDetail(model: apiService)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<AssetsResponse>, Error>) in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .array:
                    strongSelf.loadingStatus = .failed
                    break
                case .single(let single):
                    if let array = single.assets {
                        if array.isEmpty {
                            strongSelf.loadingStatus = .noResponse
                        }else {
                            strongSelf.loadingStatus = .default
                            strongSelf.assetDetailsResponse = array
                            strongSelf.assetDetailsResponseList = array
                            for assetDetail in strongSelf.assetDetailsResponseList {
                                assetDetail.isSelected = false
                            }
                        }
                        strongSelf.searchFilter(tx1SearchText: strongSelf.txField1.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "", tx2SearchText: strongSelf.txField2.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
                        strongSelf.spreedSheetView.reloadData()
                    }
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                strongSelf.loadingStatus = .failed
            }
        }
    }
        
    func loadLayoutsData() {
        guard let siteID = UserConstants.shared.selectedSiteID else {
            self.loadingStatus = .failed
            return
        }
        
        let apiService = ApiService.siteLayoutAPI(siteId: siteID)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<SiteLayoutModel>, Error>) in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single:
                    break
                case .array(let array):
                    if !array.isEmpty {
                        strongSelf.loadingStatus = .default
                        strongSelf.siteLayoutDataArray = array
                        strongSelf.setAssetFloorXib()
                        strongSelf.setAssetLocationXib()
                        strongSelf.setAssetRoomXib()
                    }
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
            }
        }   
    }
    
    func setAssetFloorXib() {
        var actions = [UIAction]()
        actions.append(UIAction(title: "Floor", state: searchAssetFloorInd == 0 ? .on : .off, handler: { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.viewFloorXIB.lblText.text = "Floor"
                self.searchAssetFloorInd = 0
                self.setAssetFloorXib()
                self.searchFilter(tx1SearchText: self.txField1.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "", tx2SearchText: self.txField2.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
            }
        }))
        var seenAreas = Set<String?>()
        
        for (key,item) in self.siteLayoutDataArray.enumerated() {
            if item.nodeType == .floor {
                let floor = item.nodeName ?? "No floor"
                
                if seenAreas.contains(floor) {
                    continue
                }
                
                seenAreas.insert(floor)
                
                actions.append(UIAction(title: floor, state: searchAssetFloorInd == key+1 ? .on : .off, handler: { [weak self] _ in
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        self.searchAssetFloorInd = key + 1
                        self.viewFloorXIB.lblText.text = item.nodeName
                        self.setAssetFloorXib()
                        self.searchFilter(tx1SearchText: self.txField1.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "", tx2SearchText: self.txField2.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
                    }
                }))
            }
        }
        self.viewFloorXIB.btnDownClick.menu = UIMenu(title: "", children: actions)
        self.viewFloorXIB.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func setAssetRoomXib() {
        var actions = [UIAction]()
        actions.append(UIAction(title: "Room", state: searchAssetRoomInd == 0 ? .on : .off, handler: { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.viewRoomXIB.lblText.text = "Room"
                self.searchAssetRoomInd = 0
                self.setAssetRoomXib()
                self.searchFilter(tx1SearchText: self.txField1.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "", tx2SearchText: self.txField2.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
            }
        }))
        var seenAreas = Set<String?>()
        
        for (key,item) in self.siteLayoutDataArray.enumerated() {
            if item.nodeType == .room {
                let room = item.nodeName ?? "No Room"
                
                if seenAreas.contains(room) {
                    continue
                }
                
                seenAreas.insert(room)
                
                actions.append(UIAction(title: room, state: searchAssetRoomInd == key+1 ? .on : .off, handler: { [weak self] _ in
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        self.searchAssetRoomInd = key + 1
                        self.viewRoomXIB.lblText.text = item.nodeName
                        self.setAssetRoomXib()
                        self.searchFilter(tx1SearchText: self.txField1.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "", tx2SearchText: self.txField2.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
                    }
                }))
            }
        }
        viewRoomXIB.btnDownClick.menu = UIMenu(title: "", children: actions)
        viewRoomXIB.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func setAssetLocationXib() {
        var actions = [UIAction]()
        actions.append(UIAction(title: "Location", state: searchAssetLocation == nil ? .on : .off, handler: { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.viewLocatinXIB.lblText.text = "Location"
                self.searchAssetLocation = nil
                self.setAssetLocationXib()
                self.searchFilter(tx1SearchText: self.txField1.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "", tx2SearchText: self.txField2.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
            }
        }))
        var seenAreas = Set<String?>()
        
        for (key, item) in ["External", "Internal"].enumerated() {
            actions.append(UIAction(title: item, state: searchAssetLocation == item ? .on : .off, handler: { [weak self] _ in
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.searchAssetLocation = item
                    self.viewLocatinXIB.lblText.text = item
                    self.setAssetLocationXib()
                    self.searchFilter(tx1SearchText: self.txField1.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "", tx2SearchText: self.txField2.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
                }
            }))
        }
        self.viewLocatinXIB.btnDownClick.menu = UIMenu(title: "", children: actions)
        self.viewLocatinXIB.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func setAssetCategoryXib() {
        var actions = [UIAction]()
        actions.append(UIAction(title: "Category", state: searchAssetCategotyInd == 0 ? .on : .off, handler: { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.viewAssetCategoryXIB.lblText.text = "Category"
                self.searchAssetCategotyInd = 0
                self.setAssetCategoryXib()
                self.searchFilter(tx1SearchText: self.txField1.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "", tx2SearchText: self.txField2.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
            }
        }))
        var seenAreas = Set<String?>()

        for (key,item) in self.assetCategoryResponse.enumerated() {
            let area = item?.lovValue ?? "No Category"
            
            if seenAreas.contains(area) {
                continue
            }
            
            seenAreas.insert(area) // Add the area to the set
            
            actions.append(UIAction(title: area, state: searchAssetCategotyInd == key+1 ? .on : .off, handler: { [weak self] _ in
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.searchAssetCategotyInd = key + 1
                    self.viewAssetCategoryXIB.lblText.text = item?.lovValue
                    self.setAssetCategoryXib()
                    self.searchFilter(tx1SearchText: self.txField1.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "", tx2SearchText: self.txField2.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
                }
            }))
        }
        self.viewAssetCategoryXIB.btnDownClick.menu = UIMenu(title: "", children: actions)
        self.viewAssetCategoryXIB.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func loadAssetCategory() {
        let apiService = ApiService.siteAssetsCategory
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<LOV_Model>, Error>) in
            switch result {
            case .success(let responseResult):
                if case .array(let siteAssetCategoryArray) = responseResult {
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        self.viewAssetCategoryXIB.lblText.text = "Category"
                        self.assetCategoryResponse = siteAssetCategoryArray
                        self.setAssetCategoryXib()
                    }
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func selectTabItem(index: Int) {
        guard let siteID = UserConstants.shared.selectedSiteID else {
            return
        }
        switch index {
        case 0:
            if self.selectedTabIndex != index {
                self.selectedTabIndex = index
                self.createAssetWidth.constant = 110.0
                self.cloneLblLeadingCons.constant = 15.0
                
                self.loadingStatus = .loading
                self.assetRegisterData = .assetSummaryAPI(siteId: siteID)
                self.assetDetailsResponseList = []
                self.spreedSheetView.reloadData()
                self.loadAssetRegisterData(apiService: .assetSummaryAPI(siteId: siteID))
                self.selectedIndexes.removeAll()
            }
            break
        case 1:
            if self.selectedTabIndex != index {
                self.createAssetWidth.constant = 0.0
                self.cloneLblLeadingCons.constant = 0.0
                
                self.loadingStatus = .loading
                self.assetRegisterData = .assetDoorAPI(siteId: siteID)
                self.assetDetailsResponseList = []
                self.spreedSheetView.reloadData()
                self.loadAssetRegisterData(apiService: .assetDoorAPI(siteId: siteID))
                self.selectedIndexes.removeAll()
            }
            break
        case 2:
            if self.selectedTabIndex != index {
                self.createAssetWidth.constant = 0.0
                self.cloneLblLeadingCons.constant = 0.0
                
                self.loadingStatus = .loading
                self.assetRegisterData = .assetPatAPI(siteId: siteID)
                self.assetDetailsResponseList = []
                self.spreedSheetView.reloadData()
                self.loadAssetRegisterData(apiService: .assetPatAPI(siteId: siteID))
                self.selectedIndexes.removeAll()
            }
            break
        case 3:
            if self.selectedTabIndex != index {
                self.createAssetWidth.constant = 0.0
                self.cloneLblLeadingCons.constant = 0.0
                
                self.loadingStatus = .loading
                self.assetRegisterData = .assetPFPAPI(siteId: siteID)
                self.assetDetailsResponseList = []
                self.spreedSheetView.reloadData()
                self.loadAssetRegisterData(apiService: .assetPFPAPI(siteId: siteID))
                self.selectedIndexes.removeAll()
            }
            break
        default:
            break
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string).trimmingCharacters(in: .whitespacesAndNewlines)
        
        if textField.tag == 0 {
            searchFilter(tx1SearchText: updatedText, tx2SearchText: self.txField2.text ?? "")
        }else {
            searchFilter(tx1SearchText: self.txField1.text ?? "", tx2SearchText: updatedText)
        }

        return true
    }

    func searchFilter(tx1SearchText: String, tx2SearchText: String) {
        if self.assetDetailsResponse.isEmpty {
            return
        }
        DispatchQueue.main.async { [weak self] in
            guard let self else {return}
            if tx1SearchText == "" && tx2SearchText == "" {
                self.assetDetailsResponseList = self.assetDetailsResponse
            }
            
            if tx1SearchText != "" {
                self.assetDetailsResponseList = assetDetailsResponse.filter({ user in
                    user.assetName?.lowercased().contains(tx1SearchText.lowercased()) ?? false
                }).sorted { user1, user2 in
                    let name1 = user1.assetName?.lowercased() ?? ""
                    let name2 = user2.assetName?.lowercased() ?? ""
                    
                    let startsWith1 = name1.hasPrefix(tx1SearchText.lowercased())
                    let startsWith2 = name2.hasPrefix(tx1SearchText.lowercased())
                    
                    if startsWith1 && !startsWith2 {
                        return true
                    } else if !startsWith1 && startsWith2 {
                        return false
                    } else {
                        return name1 < name2
                    }
                }
            }
            
            if tx2SearchText != "" {
                self.assetDetailsResponseList = assetDetailsResponse.filter({ user in
                    user.manufacturer?.lowercased().contains(tx2SearchText.lowercased()) ?? false
                }).sorted { user1, user2 in
                    let name1 = user1.manufacturer?.lowercased() ?? ""
                    let name2 = user2.manufacturer?.lowercased() ?? ""
                    
                    let startsWith1 = name1.hasPrefix(tx2SearchText.lowercased())
                    let startsWith2 = name2.hasPrefix(tx2SearchText.lowercased())
                    
                    if startsWith1 && !startsWith2 {
                        return true
                    } else if !startsWith1 && startsWith2 {
                        return false
                    } else {
                        return name1 < name2
                    }
                }
            }
            
            if self.viewAssetCategoryXIB.lblText.text?.lowercased() != "Category".lowercased() {
                self.assetDetailsResponseList = self.assetDetailsResponseList.filter({ user in
                    (user.category?.lowercased() ?? "") == self.viewAssetCategoryXIB.lblText.text?.lowercased()
                })
            }
            
            if self.viewLocatinXIB.lblText.text?.lowercased() != "Location".lowercased() {
                self.assetDetailsResponseList = self.assetDetailsResponseList.filter({ user in
                    (user.position?.lowercased() ?? "") == self.viewLocatinXIB.lblText.text?.lowercased()
                })
            }
            
            if self.viewFloorXIB.lblText.text?.lowercased() != "Floor".lowercased() {
                self.assetDetailsResponseList = self.assetDetailsResponseList.filter({ user in
                    (user.floor?.lowercased() ?? "") == self.viewFloorXIB.lblText.text?.lowercased()
                })
            }
            
            if self.viewRoomXIB.lblText.text?.lowercased() != "Room".lowercased() {
                self.assetDetailsResponseList = self.assetDetailsResponseList.filter({ user in
                    (user.room?.lowercased() ?? "") == self.viewRoomXIB.lblText.text?.lowercased()
                })
            }
            
            let selectedRows = self.selectedIndexes.compactMap { row in
                self.assetDetailsResponseList.firstIndex { $0 == self.assetDetailsResponse[row] }
            }
            self.selectedIndexes = Set(selectedRows)
            
            if self.assetDetailsResponseList.isEmpty {
                self.loadingStatus = .noResponse
            }else {
                self.loadingStatus = .default
            }
            self.spreedSheetView.reloadData()
        }
        
    }
    
    @IBAction func addNewAssetAction(_ sender: Any) {
        let vc = siteAssetsSB.instantiateViewController(withIdentifier: "CreateNewAssetVC") as! CreateNewAssetVC
        vc.isForCreateNew = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func cloneBtnTapped(_ sender: Any) {
        let validSelectedIndexes = selectedIndexes.filter { $0 != 0 }
        
        if validSelectedIndexes.count == 1 || (selectedIndexes.count == 2 && selectedIndexes.contains(0)) {
            let selectedIndex = validSelectedIndexes.first ?? 0
            let assetDetail = assetDetailsResponseList[selectedIndex - 1]
            
            let vc = siteAssetsSB.instantiateViewController(withIdentifier: "CloneAssetVC") as! CloneAssetVC
            vc.assetName = assetDetail.assetName ?? ""
            vc.manufacture = assetDetail.manufacturer ?? ""
            if let assetId = assetDetail.assetId {
                vc.assetID =  assetId
            }
            
            present(vc, animated: true)
            
        } else {
            let message = selectedIndexes.isEmpty ? "Please select assets to clone."
                        : selectedIndexes.contains(0) && selectedIndexes.count >= 3 ? "Please select only one assets to clone."
                        : "Please select only one assets to clone."
            selectAssetToInfo(message: message)
        }
    }

    @IBAction func exportClick(_ sender: Any) {
    
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let scl = SCLAlertView(appearance: appearance)
        scl.showWait("", subTitle: "please wait...", closeButtonTitle: "")
    
        var fileName = "AssetDetails"
        if let siteID = self.siteID {
            switch self.assetRegisterData {
            case .assetSummaryAPI(siteId: let siteId):
                fileName = "site-assets-lists"
                break
            case .assetDoorAPI(siteId: let siteId):
                fileName = "site-door-assets"
                break
            case .assetPatAPI(siteId: let siteId):
                fileName = "site-pat-item-list"
                break
            case .assetPFPAPI(siteId: let siteId):
                fileName = "site-pfp-item-list"
                break
            case .none:
                break
            }
        }
        
        let csvRows = convertAssetDetailsToCSVRows(from: assetDetailsResponseList)
        let csvString = createCSV(from: csvRows)
        let fileURL = saveCSVToFile(csvString: csvString, fileName: fileName)
        
        if let _ = fileURL {
            scl.hideView()
            SCLAlertView().showSuccess("", subTitle: "File downloaded successfully!!")
        }

    }
    
    @IBAction func printQRClicked(_ sender: Any) {
        guard !selectedIndexes.isEmpty else {
            return selectAssetToInfo(message: "Please select assets to print.")
        }
        
        let scl = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
        scl.showWait("", subTitle: "please wait...")

        let validSelectedIndexes = selectedIndexes.filter { $0 != 0 }
        
        guard !validSelectedIndexes.isEmpty else {
            scl.hideView()
            return selectAssetToInfo(message: "Please select assets to print.")
        }
        
        var imageArray: [UIImage] = []
        for index in validSelectedIndexes {
            if let assetId = assetDetailsResponseList[index - 1].assetId,
               let qrImage = generateQRCode(from: qrBaseURL + String(assetId)) {
                imageArray.append(qrImage)
            }
        }
        
        guard !imageArray.isEmpty else {
            scl.hideView()
            return
        }
        
        let pdfData = generatePDF(from: imageArray)
        let pdfURL = documentDirectory().appendingPathComponent("assets-qr-codes.pdf")
        
        scl.hideView()
        do {
            try pdfData.write(to: pdfURL)
            SCLAlertView().showSuccess("", subTitle: "File downloaded successfully!!")
        } catch {
            SCLAlertView().showError("", subTitle: "Download failed")
        }
    }
    
}

extension AssetRegisterVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.itemArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LabelSelectionCell", for: indexPath) as! LabelSelectionCell
        
        if self.itemArray.count > indexPath.row {
            let item = self.itemArray[indexPath.row]
            cell.mainLbl.text = item
        }
        
        if self.selectedTabIndex == indexPath.row {
            cell.selectionView.isHidden = false
            cell.mainLbl.textColor = UIColor(appColor: .AppTint)
        }else if indexPath.row != 0 {
            cell.selectionView.isHidden = true
            cell.mainLbl.textColor = UIColor(appColor: .GrayText).withAlphaComponent(0.5)
        }else {
            cell.selectionView.isHidden = true
            cell.mainLbl.textColor = UIColor(appColor: .GrayText)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectTabItem(index: indexPath.row)
        self.selectedTabIndex = indexPath.row
        
        self.txField1.placeholder = "Asset Name"
        self.txField2.placeholder = "ManuFacturer"
        self.txField1.text = ""
        self.txField2.text = ""
        self.viewAssetCategoryXIB.lblText.text = "Category"
        self.viewLocatinXIB.lblText.text = "Location"
        self.viewFloorXIB.lblText.text = "Floor"
        self.viewRoomXIB.lblText.text = "Room"
        
        self.searchAssetCategotyInd = 0
        self.searchAssetLocation = nil
        self.searchAssetRoomInd = 0
        self.searchAssetFloorInd = 0
        
        self.collectionView.reloadData()
        self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.itemArray.count > indexPath.row {
            let item = self.itemArray[indexPath.row]
            
            let refSize = CGSize(width: 12+50+12, height: 20+20+20)
            let widthAddition: CGFloat = 12+12
            let minWidth = refSize.width-widthAddition
            
            let width = getLabelSize(text: item, font: UIFont(name: .MontserratMedium, size: 17), minWidth: minWidth, widthAddition: widthAddition).width
            return CGSize(width: width, height: collectionView.frame.height)
        }
        return CGSize.zero
    }
    
}

extension AssetRegisterVC: SpreadsheetViewDataSource, SpreadsheetViewDelegate {
    
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        switch self.assetRegisterData {
        case .assetSummaryAPI(siteId: let siteId):
            return self.summaryRowArray.count
        case .assetDoorAPI(siteId: let siteId):
            return self.doorRowArray.count
        case .assetPatAPI(siteId: let siteId):
            return self.patRowArray.count
        case .assetPFPAPI(siteId: let siteId):
            return self.pfpRowArray.count
        case .none:
            return 0
        }
    }
    
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        switch self.loadingStatus {
        case .default:
            if !self.assetDetailsResponseList.isEmpty {
                return self.assetDetailsResponseList.count + 1
            }
            return 1 + 1
        case .loading, .failed, .noResponse, .noInternet:
            return 1+1
        }
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        switch loadingStatus {
        case .loading, .failed, .noResponse, .noInternet:
            var stringsArray: [String] = []
            switch self.assetRegisterData {
            case .assetSummaryAPI(siteId: let siteId):
                stringsArray = self.summaryRowArray
            case .assetDoorAPI(siteId: let siteId):
                stringsArray = self.doorRowArray
            case .assetPatAPI(siteId: let siteId):
                stringsArray = self.patRowArray
            case .assetPFPAPI(siteId: let siteId):
                stringsArray = self.pfpRowArray
            case .none:
                stringsArray = [""]
            }
            let maxColumnWidth = getMaxLabelSize(textArray: stringsArray, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 200).width
            return maxColumnWidth
        default:
            switch self.assetRegisterData {
            case .assetSummaryAPI(siteId: let siteId):
                var stringsArray = [String]()
                if column == 0 {
                    return 30
                }else if column == 1 {
                    stringsArray = assetDetailsResponseList.compactMap { $0.assetId.map { String($0) }}
                    stringsArray.append(self.summaryRowArray[1])
                    let maxColumnWidth = getMaxLabelSize(textArray: stringsArray, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 200).width
                    return maxColumnWidth
                }else if column == 2 {
                    stringsArray = assetDetailsResponseList.compactMap({$0.assetName})
                    stringsArray.append(self.summaryRowArray[2])
                    let maxColumnWidth = getMaxLabelSize(textArray: stringsArray, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 200).width
                    return maxColumnWidth
                }else if column == 3 {
                    stringsArray = assetDetailsResponseList.compactMap({$0.manufacturer})
                    stringsArray.append(self.summaryRowArray[3])
                    let maxColumnWidth = getMaxLabelSize(textArray: stringsArray, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 200).width
                    return maxColumnWidth
                }else if column == 4 {
                    var categoryArray: [String] = []
                    for item in self.assetDetailsResponseList {
                        let category = item.category
                        let subCategory = item.subCategory
                        let subCategory2 = item.subCategory2
                        let subCategory3 = item.subCategory3
                        
                        let categories = [category, subCategory, subCategory2, subCategory3]
                        
                        let categoriesResult = categories
                            .compactMap { $0?.isEmpty == false ? $0 : nil }
                            .joined(separator: " > ")
                        
                        categoryArray.append(categoriesResult)
                    }
                    categoryArray.append(self.summaryRowArray[4])
                    let maxColumnWidth = getMaxLabelSize(textArray: categoryArray, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 200).width
                    return maxColumnWidth
                }else if column == 5 {
                    var locationArray: [String] = []
                    for item in self.assetDetailsResponseList {
                        let position = item.position
                        let floor = item.floor
                        let room = item.room
                        
                        let location = [position, floor, room]
                        
                        let locationResult = location
                            .compactMap { $0?.isEmpty == false ? $0 : nil }
                            .joined(separator: " > ")
                        locationArray.append(locationResult.isEmpty ? "NA > NA > NA" : locationResult)
                    }
                    locationArray.append(self.summaryRowArray[5])
                    let maxColumnWidth = getMaxLabelSize(textArray: locationArray, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 200).width
                    return maxColumnWidth
                }else if column == 6 {
                    return 40+40+40+20+10+10+5+5
                }
            case .assetDoorAPI(siteId: let siteId):
                var stringsArray = [String]()
                if column == 0 {
                    return 30
                }else if column == 1 {
                    stringsArray = assetDetailsResponseList.compactMap { $0.assetId.map { String($0) }}
                    stringsArray.append(self.doorRowArray[1])
                    let maxColumnWidth = getMaxLabelSize(textArray: stringsArray, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 200).width
                    return maxColumnWidth
                }else if column == 2 {
                    stringsArray = assetDetailsResponseList.compactMap({$0.assetName})
                    stringsArray.append(self.doorRowArray[2])
                    let maxColumnWidth = getMaxLabelSize(textArray: stringsArray, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 200).width
                    return maxColumnWidth
                }else if column == 3 {
                    var doorSize: [String] = []
                    for item in self.assetDetailsResponseList {
                        let width = item.assetDoorSpecifications?.width
                        let height = item.assetDoorSpecifications?.height
                        
                        doorSize.append("\(String(describing: width)) * \(String(describing: height))")
                    }
                    doorSize.append(self.doorRowArray[3])
                    let maxColumnWidth = getMaxLabelSize(textArray: doorSize, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 200).width
                    return maxColumnWidth
                }else if column == 4 {
                    var fireRating: [String] = []
                    fireRating = assetDetailsResponseList.compactMap { $0.assetDoorSpecifications?.fireRating.map { String($0) }}
                    fireRating.append(self.doorRowArray[4])
                    let maxColumnWidth = getMaxLabelSize(textArray: fireRating, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 200).width
                    return maxColumnWidth
                }else if column == 5 {
                    var locationArray: [String] = []
                    for item in self.assetDetailsResponseList {
                        let position = item.position
                        let floor = item.floor
                        let room = item.room
                        
                        var location = [position, floor, room]
                        
                        let locationResult = location
                            .compactMap { $0?.isEmpty == false ? $0 : nil }
                            .joined(separator: " > ")
                        
                        locationArray.append(locationResult.isEmpty ? "NA > NA > NA" : locationResult)
                    }
                    locationArray.append(self.doorRowArray[5])
                    let maxColumnWidth = getMaxLabelSize(textArray: locationArray, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 200).width
                    return maxColumnWidth
                }else if column == 6 {
                    stringsArray = assetDetailsResponseList.compactMap({$0.assetDoorSpecifications?.frameFinish})
                    stringsArray.append(self.doorRowArray[6])
                    let maxColumnWidth = getMaxLabelSize(textArray: stringsArray, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 200).width
                    return maxColumnWidth
                }else if column == 7 {
                    stringsArray = assetDetailsResponseList.compactMap({$0.assetDoorSpecifications?.visionPanel})
                    stringsArray.append(self.doorRowArray[7])
                    let maxColumnWidth = getMaxLabelSize(textArray: stringsArray, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 200).width
                    return maxColumnWidth
                }else if column == 8 {
                    stringsArray = assetDetailsResponseList.compactMap({$0.assetDoorSpecifications?.frameMaterial})
                    stringsArray.append(self.doorRowArray[8])
                    let maxColumnWidth = getMaxLabelSize(textArray: stringsArray, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 200).width
                    return maxColumnWidth
                }else if column == 9 {
                    return 40+40+40+20+10+10+5+5
                }
            case .assetPatAPI(siteId: let siteId):
                var stringsArray = [String]()
                if column == 0 {
                    return 30
                }else if column == 1 {
                    stringsArray = assetDetailsResponseList.compactMap { $0.assetId.map { String($0) }}
                    stringsArray.append(self.patRowArray[1])
                    let maxColumnWidth = getMaxLabelSize(textArray: stringsArray, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 200).width
                    return maxColumnWidth
                }else if column == 2 {
                    stringsArray = assetDetailsResponseList.compactMap({$0.assetName})
                    stringsArray.append(self.patRowArray[2])
                    let maxColumnWidth = getMaxLabelSize(textArray: stringsArray, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 200).width
                    return maxColumnWidth
                }else if column == 3 {
                    stringsArray = assetDetailsResponseList.compactMap({$0.manufacturer})
                    stringsArray.append(self.patRowArray[3])
                    let maxColumnWidth = getMaxLabelSize(textArray: stringsArray, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 200).width
                    return maxColumnWidth
                }else if column == 4 {
                    var categoryArray: [String] = []
                    
                    for item in assetDetailsResponseList {
                        let category = item.category
                        let subCategory = item.subCategory
                        let subCategory2 = item.subCategory2
                        let subCategory3 = item.subCategory3
                        
                        let categories = [category, subCategory, subCategory2, subCategory3]
                        
                        let categoriesResult = categories
                            .compactMap { $0?.isEmpty == false ? $0 : nil }
                            .joined(separator: " > ")
                        
                        categoryArray.append(categoriesResult)
                    }
                    categoryArray.append(self.patRowArray[4])
                    let maxColumnWidth = getMaxLabelSize(textArray: categoryArray, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 200).width
                    return maxColumnWidth
                }else if column == 5 {
                    var locationArray: [String] = []
                    
                    for item in assetDetailsResponseList {
                        let position = item.position
                        let floor = item.floor
                        let room  = item.room
                        
                        let location = [position, floor, room]
                        
                        let locationResult = location
                            .compactMap { $0?.isEmpty == false ? $0 : nil }
                            .joined(separator: " > ")
                        
                        locationArray.append(locationResult.isEmpty ? "NA > NA > NA" : locationResult)
                    }
                    locationArray.append(self.patRowArray[5])
                    let maxColumnWidth = getMaxLabelSize(textArray: locationArray, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 200).width
                    return maxColumnWidth
                }else if column == 6 {
                    stringsArray = assetDetailsResponseList.compactMap({$0.assetPATItems?.first?.patDate})
                    
                    stringsArray.append(self.patRowArray[6])
                    let maxColumnWidth = getMaxLabelSize(textArray: stringsArray, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 200).width
                    return maxColumnWidth
                }else if column == 7 {
                    stringsArray = assetDetailsResponseList.compactMap({$0.assetPATItems?.first?.patNextDate})
                    
                    stringsArray.append(self.patRowArray[7])
                    let maxColumnWidth = getMaxLabelSize(textArray: stringsArray, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 200).width
                    return maxColumnWidth
                }else if column == 8 {
                    stringsArray = assetDetailsResponseList.compactMap({$0.assetPATItems?.first?.patStatus})
                    stringsArray.append(self.patRowArray[8])
                    let maxColumnWidth = getMaxLabelSize(textArray: stringsArray, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 200).width
                    return maxColumnWidth
                }else if column == 9 {
                    return 40+40+40+20+10+10+5+5
                }
            case .assetPFPAPI(siteId: let siteId):
                var stringsArray = [String]()
                if column == 0 {
                    return 30
                }else if column == 1 {
                    stringsArray = assetDetailsResponseList.compactMap { $0.assetId.map { String($0) }}
                    stringsArray.append(self.pfpRowArray[1])
                    let maxColumnWidth = getMaxLabelSize(textArray: stringsArray, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 200).width
                    return maxColumnWidth
                }else if column == 2 {
                    stringsArray = assetDetailsResponseList.compactMap { $0.assetName.map { String($0) }}
                    stringsArray.append(self.pfpRowArray[2])
                    let maxColumnWidth = getMaxLabelSize(textArray: stringsArray, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 200).width
                    return maxColumnWidth
                }else if column == 3 {
                    stringsArray = assetDetailsResponseList.compactMap { $0.assetPFPItem?.material.map { String($0) }}
                    stringsArray.append(self.pfpRowArray[3])
                    let maxColumnWidth = getMaxLabelSize(textArray: stringsArray, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 200).width
                    return maxColumnWidth
                }else if column == 4 {
                    stringsArray = assetDetailsResponseList.compactMap { $0.assetPFPItem?.product.map { String($0) }}
                    stringsArray.append(self.pfpRowArray[4])
                    let maxColumnWidth = getMaxLabelSize(textArray: stringsArray, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 200).width
                    return maxColumnWidth
                }else if column == 5 {
                    var locationArray: [String] = []
                    
                    for item in assetDetailsResponseList {
                        let position = item.position
                        let floor = item.floor
                        let room  = item.room
                        
                        let location = [position, floor, room]
                        
                        let locationResult = location
                            .compactMap { $0?.isEmpty == false ? $0 : nil }
                            .joined(separator: " > ")
                        
                        locationArray.append(locationResult.isEmpty ? "NA > NA > NA" : locationResult)
                    }
                    locationArray.append(self.patRowArray[5])
                    let maxColumnWidth = getMaxLabelSize(textArray: locationArray, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 200).width
                    return maxColumnWidth
                }else if column == 6 {
                    stringsArray = assetDetailsResponseList.compactMap { $0.assetPFPItem?.service.map { String($0) }}
                    stringsArray.append(self.pfpRowArray[6])
                    let maxColumnWidth = getMaxLabelSize(textArray: stringsArray, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 200).width
                    return maxColumnWidth
                }else if column == 7 {
                    stringsArray = assetDetailsResponseList.compactMap { $0.assetPFPItem?.dimension.map { String($0) }}
                    stringsArray.append(self.pfpRowArray[7])
                    let maxColumnWidth = getMaxLabelSize(textArray: stringsArray, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 200).width
                    return maxColumnWidth
                }else if column == 8 {
                    stringsArray = assetDetailsResponseList.compactMap { $0.assetPFPItem?.quantity.map { String($0) }}
                    stringsArray.append(self.pfpRowArray[8])
                    let maxColumnWidth = getMaxLabelSize(textArray: stringsArray, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 200).width
                    return maxColumnWidth
                }else if column == 9 {
                    stringsArray = assetDetailsResponseList.compactMap { $0.assetPFPItem?.area.map { String($0) }}
                    stringsArray.append(self.pfpRowArray[9])
                    let maxColumnWidth = getMaxLabelSize(textArray: stringsArray, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 200).width
                    return maxColumnWidth
                }else if column == 10 {
                    return 40+40+40+20+10+10+5+5
                }
            case .none:
                return 0
            }
            return 40+40+40+20+10+10+5+5
        }
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        var textArray: [String] = []
        switch self.assetRegisterData {
        case .assetSummaryAPI(siteId: let siteId):
            textArray = self.summaryRowArray
        case .assetDoorAPI(siteId: let siteId):
            textArray = self.doorRowArray
        case .assetPatAPI(siteId: let siteId):
            textArray = self.patRowArray
        case .assetPFPAPI(siteId: let siteId):
            textArray = self.pfpRowArray
        case .none:
            textArray = []
        }
        switch loadingStatus {
        case .loading, .failed, .noResponse, .noInternet:
            let refSize = CGSize(width: 100, height: 40)
            let heightAddition: CGFloat = 10+10
            let minHeight = refSize.height-heightAddition
            let font = UIFont(name: .MontserratSemiBold, size: textFontSize)
            let headerHeight = getMaxLabelSize(textArray: textArray, font: font, maxWidth: 200, minHeight: minHeight, heightAddition: heightAddition).height
            return headerHeight
        default:
            if row == 0 {
                let refSize = CGSize(width: 100, height: 40)
                let heightAddition: CGFloat = 10+10
                let minHeight = refSize.height-heightAddition
                let font = UIFont(name: .MontserratSemiBold, size: textFontSize)
                let headerHeight = getMaxLabelSize(textArray: textArray, font: font, maxWidth: 200, minHeight: minHeight, heightAddition: heightAddition).height
                return headerHeight
            }else {
                let refSize = CGSize(width: 100, height: 50)
                let heightAddition: CGFloat = 10+10
                let minHeight = refSize.height-heightAddition
                var optionArray = [String?]()
                switch self.assetRegisterData {
                case .assetSummaryAPI:
                    
                    let category: String? = (assetDetailsResponseList[row-1].category)
                    let subCategory: String? = (assetDetailsResponseList[row-1].subCategory)
                    let subCategory2: String? = (assetDetailsResponseList[row-1].subCategory2)
                    let subCategory3: String? = (assetDetailsResponseList[row-1].subCategory3)
                    
                    let categories = [category, subCategory, subCategory2, subCategory3]
                    
                    let categoriesResult = categories
                        .compactMap { $0?.isEmpty == false ? $0 : nil }
                        .joined(separator: " > ")
                    
                    
                    let position: String? = (assetDetailsResponseList[row-1].position)
                    let floor: String? = (assetDetailsResponseList[row-1].floor)
                    let room: String? = (assetDetailsResponseList[row-1].room)
                    
                    let location = [position, floor, room]
                    
                    let locationResult = location
                        .compactMap { $0?.isEmpty == false ? $0 : nil }
                        .joined(separator: " > ")
                    
                    if let assetId = assetDetailsResponseList[row-1].assetId, let assetName = assetDetailsResponseList[row-1].assetName, let manufacturer = assetDetailsResponseList[row-1].manufacturer {
                        
                        optionArray.append(contentsOf: ["\(assetId)", assetName, manufacturer, categoriesResult, locationResult])
                    }
                case .assetDoorAPI:
                    let position: String? = (assetDetailsResponseList[row-1].position)
                    let floor: String? = (assetDetailsResponseList[row-1].floor)
                    let room: String? = (assetDetailsResponseList[row-1].room)
                    
                    let location = [position, floor, room]
                    
                    let locationResult = location
                        .compactMap { $0?.isEmpty == false ? $0 : nil }
                        .joined(separator: " > ")
                    
                    if let assetId = assetDetailsResponseList[row-1].assetId, let assetName = assetDetailsResponseList[row-1].assetName, let fireRating = assetDetailsResponseList[row-1].assetDoorSpecifications?.fireRating, let doorFinish = assetDetailsResponseList[row-1].assetDoorSpecifications?.frameFinish, let visionPanel = assetDetailsResponseList[row-1].assetDoorSpecifications?.visionPanel, let frame = assetDetailsResponseList[row-1].assetDoorSpecifications?.frameMaterial {
                        optionArray.append(contentsOf: ["\(assetId)", assetName, "\(assetDetailsResponseList[row-1].assetDoorSpecifications?.width ?? "") * \(assetDetailsResponseList[row-1].assetDoorSpecifications?.height ?? "")", fireRating, locationResult, doorFinish, visionPanel, frame])
                    }
                    break
                case .assetPatAPI:
                    let category: String? = (assetDetailsResponseList[row-1].category)
                    
                    let position: String? = (assetDetailsResponseList[row-1].position)
                    let floor: String? = (assetDetailsResponseList[row-1].floor)
                    let room: String? = (assetDetailsResponseList[row-1].room)
                    
                    let location = [position, floor, room]
                    
                    let locationResult = location
                        .compactMap { $0?.isEmpty == false ? $0 : nil }
                        .joined(separator: " > ")
                    
                    if let assetId = assetDetailsResponseList[row-1].assetId, let assetName = assetDetailsResponseList[row-1].assetName, let manuFactor = assetDetailsResponseList[row-1].manufacturer, let dateTested = assetDetailsResponseList[row-1].assetPATItems?.first?.patDate, let nextTest = assetDetailsResponseList[row-1].assetPATItems?.first?.patNextDate {
                        optionArray.append(contentsOf: ["\(assetId)", assetName, manuFactor, category, locationResult, dateTested, nextTest])
                    }
                    
                    break
                case .assetPFPAPI:
                    let position: String? = (assetDetailsResponseList[row-1].position)
                    let floor: String? = (assetDetailsResponseList[row-1].floor)
                    let room: String? = (assetDetailsResponseList[row-1].room)
                    
                    let location = [position, floor, room]
                    
                    let locationResult = location
                        .compactMap { $0?.isEmpty == false ? $0 : nil }
                        .joined(separator: " > ")
                    
                    if let assetId = assetDetailsResponseList[row-1].assetId, let assetName = assetDetailsResponseList[row-1].assetName, let material = assetDetailsResponseList[row-1].assetPFPItem?.material, let product = assetDetailsResponseList[row-1].assetPFPItem?.product, let service = assetDetailsResponseList[row-1].serialNumber, let dimention = assetDetailsResponseList[row-1].assetPFPItem?.dimension, let quality = assetDetailsResponseList[row-1].assetPFPItem?.quantity, let area = assetDetailsResponseList[row-1].assetPFPItem?.area {
                        optionArray.append(contentsOf: ["\(assetId)", assetName, material, product, locationResult, service, dimention, quality, area])
                    }
                    break
                case .none:
                    return 0
                }
                let textArray = optionArray.compactMap{$0}
                let font = UIFont(name: .MontserratRegular, size: textFontSize)
                let headerHeight = getMaxLabelSize(textArray: textArray, font: font, maxWidth: 200, minHeight: minHeight, heightAddition: heightAddition).height
                return headerHeight
            }
        }
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        switch self.assetRegisterData {
        case .assetSummaryAPI(siteId: let siteId):
            if indexPath.row == 0 {
                if indexPath.column == 0 && isDataNotReceive {
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextXib", for: indexPath) as! CellTextXib
                    cell.backgroundColor = UIColor(appColor: .AppTint)
                    cell.lblText.text = ""
                    return cell
                }else if indexPath.column == 0 {
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CheckBoxXIB", for: indexPath) as! CheckBoxXIB
                    cell.backgroundColor = UIColor(appColor: .AppTint)
                    cell.checkImageView.addCorner(value: 2)
                    cell.checkImageView.backgroundColor = .white
                    cell.checkImageHeight.constant = 20.0
                    
                    if selectedIndexes.contains(indexPath.row) {
                        cell.checkImageView.image = UIImage(named: "check_image")
                    }else {
                        cell.checkImageView.image = UIImage(named: "un_check_image")
                    }
                    return cell
                }else {
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextXib", for: indexPath) as! CellTextXib
                    cell.backgroundColor = .white
                    cell.lblText.textColor = .black
                    cell.gridlines.top = .solid(width: 1, color: UIColor(appColor: .AppTint))
                    cell.gridlines.bottom = .solid(width: 1, color: UIColor(appColor: .AppTint))
                    cell.gridlines.left = .solid(width: 1, color: UIColor(appColor: .AppTint))
                    cell.gridlines.right = .solid(width: 1, color: UIColor(appColor: .AppTint))
                    cell.backgroundColor = UIColor(appColor: .AppTint)
                    cell.lblText.font = UIFont(name: .MontserratSemiBold, size: textFontSize)
                    cell.lblText.textColor = UIColor.white
                    cell.lblText.backgroundColor = UIColor.clear
                    cell.lblText.text = summaryRowArray[indexPath.section]
                    return cell
                }
            }else if indexPath.row == 1 && isDataNotReceive {
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextXib", for: indexPath) as! CellTextXib
                cell.gridlines.top = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                cell.gridlines.bottom = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                cell.gridlines.left = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                cell.gridlines.right = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                cell.backgroundColor = UIColor.white
                cell.lblText.addCorner(value: 0)
                cell.lblText.font = UIFont(name: .MontserratRegular, size: textFontSize)
                cell.lblText.textColor = UIColor.black
                cell.lblText.backgroundColor = UIColor.clear
                cell.lblText.text = loadingStatus.rawValue
                if loadingStatus == .noResponse && !assetDetailsResponseList.isEmpty {
                    cell.lblText.text = "No Result Found !!"
                }
                return cell
            }else if indexPath.section == 0 || indexPath.section == 1 || indexPath.section == 2 || indexPath.section == 3 || indexPath.section == 4 || indexPath.section == 5 {
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextXib", for: indexPath) as! CellTextXib
                cell.backgroundColor = .white
                cell.lblText.textColor = .black
                cell.gridlines.top = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                cell.gridlines.bottom = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                cell.gridlines.left = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                cell.gridlines.right = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                cell.lblText.addCorner(value: 0)
                cell.lblText.font = UIFont(name: .MontserratRegular, size: textFontSize)
                cell.lblText.backgroundColor = UIColor.clear
                
                if indexPath.section == 0 {
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CheckBoxXIB", for: indexPath) as! CheckBoxXIB
                    cell.checkImageHeight.constant = 20.0
                    
                    if selectedIndexes.contains(indexPath.row) {
                        cell.checkImageView.image = UIImage(named: "check_image")
                    }else {
                        cell.checkImageView.image = UIImage(named: "un_check_image")
                    }
                    return cell
                }else if indexPath.section == 1 {
                    if let assetId = assetDetailsResponseList[indexPath.row-1].assetId {
                        cell.lblText.text = "\(assetId)"
                    }
                }else if indexPath.section == 2 {
                    cell.lblText.text = assetDetailsResponseList[indexPath.row-1].assetName
                }else if indexPath.section == 3 {
                    cell.lblText.text = assetDetailsResponseList[indexPath.row-1].manufacturer
                }else if indexPath.section == 4 {
                    let category: String? = (assetDetailsResponseList[indexPath.row-1].category)
                    let subCategory: String? = (assetDetailsResponseList[indexPath.row-1].subCategory)
                    let subCategory2: String? = (assetDetailsResponseList[indexPath.row-1].subCategory2)
                    let subCategory3: String? = (assetDetailsResponseList[indexPath.row-1].subCategory3)
                    
                    let categories = [category, subCategory, subCategory2, subCategory3]
                    
                    let categoriesResult = categories
                        .compactMap { $0?.isEmpty == false ? $0 : nil }
                        .joined(separator: " > ")
                    
                    cell.lblText.text = categoriesResult.isEmpty ? "NA > NA > NA" : categoriesResult
                }else if indexPath.section == 5 {
                    let position: String? = (assetDetailsResponseList[indexPath.row-1].position)
                    let floor: String? = (assetDetailsResponseList[indexPath.row-1].floor)
                    let room: String? = (assetDetailsResponseList[indexPath.row-1].room)
                    
                    let location = [position, floor, room]
                    
                    let locationResult = location
                        .compactMap { $0?.isEmpty == false ? $0 : nil }
                        .joined(separator: " > ")
                    
                    cell.lblText.text = locationResult.isEmpty ? "NA > NA > NA" : locationResult
                }
                return cell
            }else if indexPath.section == 6 {
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "SiteAssetsActionXIB", for: indexPath) as! SiteAssetsActionXIB
                cell.gridlines.top = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                cell.gridlines.bottom = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                cell.gridlines.left = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                cell.gridlines.right = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                
                if self.isFromReports {
                    cell.qrView.alpha = 0.0
                    cell.deleteView.alpha = 0.0
                    cell.editView.alpha = 0.0
                }
                
                if let assetId = assetDetailsResponseList[indexPath.row-1].assetId {
                    
                    let fullURL = qrBaseURL + String(assetId)
                    
                    DispatchQueue.global(qos: .userInitiated).async {
                        if let qrImage = generateQRCode(from: fullURL) {
                            // Update the UI on the main thread
                            DispatchQueue.main.async {
                                cell.qrImage.image = qrImage
                            }
                        }
                    }
                }
                
                cell.qrButton.addAction { [weak self] in
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        if let assetId = assetDetailsResponseList[indexPath.row-1].assetId, let assetName = assetDetailsResponseList[indexPath.row-1].assetName {
                            let imageView = cell.qrImage
                            let sourceRect = imageView?.frame
                            if let imageView = imageView, let sourceRect = sourceRect {
                                self.showQRImage(assetName: assetName, assetId: assetId, sourceRect: sourceRect, sourceView: imageView)
                            }
                        }
                    }
                }
                
                cell.viewButton.addAction { [weak self] in
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        self.goFurtherToAssetDetailVC(for: indexPath.row-1, isViewModeEdit: false)
                    }
                }
                cell.editButton.addAction { [weak self] in
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        self.goFurtherToAssetDetailVC(for: indexPath.row-1, isViewModeEdit: true)
                    }
                }
                cell.deleteButton.addAction { [weak self] in
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        showDeleteAlert(userName: assetDetailsResponseList[indexPath.row-1].assetName ?? "", id:assetDetailsResponseList[indexPath.row-1].assetId ?? 0, selectedRow: indexPath.row - 1)
                    }
                }
                return cell
            }
        case .assetDoorAPI(siteId: let siteId):
            if indexPath.row == 0 {
                if indexPath.column == 0 && isDataNotReceive {
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextXib", for: indexPath) as! CellTextXib
                    cell.backgroundColor = UIColor(appColor: .AppTint)
                    cell.lblText.text = ""
                    return cell
                }else if indexPath.column == 0 {
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CheckBoxXIB", for: indexPath) as! CheckBoxXIB
                    cell.backgroundColor = UIColor(appColor: .AppTint)
                    cell.checkImageView.addCorner(value: 2)
                    cell.checkImageView.backgroundColor = .white
                    cell.checkImageHeight.constant = 20.0

                    if selectedIndexes.contains(indexPath.row) {
                        cell.checkImageView.image = UIImage(named: "check_image")
                    }else {
                        cell.checkImageView.image = UIImage(named: "un_check_image")
                    }
                    return cell
                }else {
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextXib", for: indexPath) as! CellTextXib
                    cell.backgroundColor = .white
                    cell.lblText.textColor = .black
                    cell.gridlines.top = .solid(width: 1, color: UIColor(appColor: .AppTint))
                    cell.gridlines.bottom = .solid(width: 1, color: UIColor(appColor: .AppTint))
                    cell.gridlines.left = .solid(width: 1, color: UIColor(appColor: .AppTint))
                    cell.gridlines.right = .solid(width: 1, color: UIColor(appColor: .AppTint))
                    cell.backgroundColor = UIColor(appColor: .AppTint)
                    cell.lblText.font = UIFont(name: .MontserratSemiBold, size: textFontSize)
                    cell.lblText.textColor = UIColor.white
                    cell.lblText.backgroundColor = UIColor.clear
                    cell.lblText.text = doorRowArray[indexPath.section]
                    return cell
                }
            }else if indexPath.row == 1 && isDataNotReceive {
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextXib", for: indexPath) as! CellTextXib
                cell.gridlines.top = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                cell.gridlines.bottom = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                cell.gridlines.left = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                cell.gridlines.right = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                cell.backgroundColor = UIColor.white
                cell.lblText.addCorner(value: 0)
                cell.lblText.font = UIFont(name: .MontserratRegular, size: textFontSize)
                cell.lblText.textColor = UIColor.black
                cell.lblText.backgroundColor = UIColor.clear
                cell.lblText.text = loadingStatus.rawValue
                if loadingStatus == .noResponse && !assetDetailsResponseList.isEmpty {
                    cell.lblText.text = "No Result Found !!"
                }
                return cell
            }else if indexPath.section == 0 ||  indexPath.section == 1 ||  indexPath.section == 2 || indexPath.section == 3 || indexPath.section == 4 || indexPath.section == 5  || indexPath.section == 6 || indexPath.section == 7 || indexPath.section == 8 {
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextXib", for: indexPath) as! CellTextXib
                cell.backgroundColor = .white
                cell.lblText.textColor = .black
                cell.gridlines.top = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                cell.gridlines.bottom = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                cell.gridlines.left = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                cell.gridlines.right = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                cell.lblText.addCorner(value: 0)
                cell.lblText.font = UIFont(name: .MontserratRegular, size: textFontSize)
                cell.lblText.backgroundColor = UIColor.clear
                
                if indexPath.section == 0 {
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CheckBoxXIB", for: indexPath) as! CheckBoxXIB
                    cell.checkImageHeight.constant = 20.0
                    if selectedIndexes.contains(indexPath.row) {
                        cell.checkImageView.image = UIImage(named: "check_image")
                    }else {
                        cell.checkImageView.image = UIImage(named: "un_check_image")
                    }
                    return cell
                }else if indexPath.section == 1 {
                    if let assetId = assetDetailsResponseList[indexPath.row-1].assetId {
                        cell.lblText.text = "\(assetId)"
                    }else {
                        cell.backgroundColor = .white
                        cell.lblText.text = "--"
                    }
                }else if indexPath.section == 2 {
                    cell.lblText.text = assetDetailsResponseList[indexPath.row-1].assetName
                }else if indexPath.section == 3 {
                    if let width = assetDetailsResponseList[indexPath.row-1].assetDoorSpecifications?.width, let height = assetDetailsResponseList[indexPath.row-1].assetDoorSpecifications?.height {
                        cell.lblText.text = "\(width) * \(height)"
                    }else {
                        cell.backgroundColor = .white
                        cell.lblText.text = "--"
                    }
                }else if indexPath.section == 4 {
                    cell.lblText.text = assetDetailsResponseList[indexPath.row-1].assetDoorSpecifications?.fireRating
                }else if indexPath.section == 5 {
                    let position: String? = (assetDetailsResponseList[indexPath.row-1].position)
                    let floor: String? = (assetDetailsResponseList[indexPath.row-1].floor)
                    let room: String? = (assetDetailsResponseList[indexPath.row-1].room)
                    
                    let location = [position, floor, room]
                    
                    let locationResult = location
                        .compactMap { $0?.isEmpty == false ? $0 : nil }
                        .joined(separator: " > ")
                    
                    cell.lblText.text = locationResult
                }else if indexPath.section == 6 {
                    cell.lblText.text = assetDetailsResponseList[indexPath.row-1].assetDoorSpecifications?.frameFinish
                }else if indexPath.section == 7 {
                    cell.lblText.text = assetDetailsResponseList[indexPath.row-1].assetDoorSpecifications?.visionPanel
                }else if indexPath.section == 8 {
                    cell.lblText.text = assetDetailsResponseList[indexPath.row-1].assetDoorSpecifications?.frameMaterial
                }
                return cell
            }else if indexPath.section == 9 {
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "SiteAssetsActionXIB", for: indexPath) as! SiteAssetsActionXIB
                cell.gridlines.top = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                cell.gridlines.bottom = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                cell.gridlines.left = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                cell.gridlines.right = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                
                if self.isFromReports {
                    cell.qrView.alpha = 0.0
                    cell.deleteView.alpha = 0.0
                    cell.editView.alpha = 0.0
                }
                
                if let assetId = assetDetailsResponseList[indexPath.row-1].assetId {
                    
                    let fullURL = qrBaseURL + String(assetId)
                    
                    DispatchQueue.global(qos: .userInitiated).async {
                        if let qrImage = generateQRCode(from: fullURL) {
                            // Update the UI on the main thread
                            DispatchQueue.main.async {
                                cell.qrImage.image = qrImage
                            }
                        }
                    }
                }
                
                cell.qrButton.addAction { [weak self] in
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        if let assetId = assetDetailsResponseList[indexPath.row-1].assetId, let assetName = assetDetailsResponseList[indexPath.row-1].assetName {
                            let imageView = cell.qrImage
                            let sourceRect = imageView?.frame
                            if let imageView = imageView, let sourceRect = sourceRect {
                                self.showQRImage(assetName: assetName, assetId: assetId, sourceRect: sourceRect, sourceView: imageView)
                            }
                        }
                    }
                }

                cell.viewButton.addAction { [weak self] in
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        self.goFurtherToAssetDetailVC(for: indexPath.row-1, isViewModeEdit: false)
                    }
                }
                cell.editButton.addAction { [weak self] in
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        self.goFurtherToAssetDetailVC(for: indexPath.row-1, isViewModeEdit: true)
                    }
                }
                cell.deleteButton.addAction { [weak self] in
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        showDeleteAlert(userName: assetDetailsResponseList[indexPath.row-1].assetName ?? "", id:assetDetailsResponseList[indexPath.row-1].assetId ?? 0, selectedRow: indexPath.row - 1)
                    }
                }
                return cell
            }
        case .assetPatAPI(siteId: let siteId):
            if indexPath.row == 0 {
                if indexPath.column == 0 && isDataNotReceive {
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextXib", for: indexPath) as! CellTextXib
                    cell.backgroundColor = UIColor(appColor: .AppTint)
                    cell.lblText.text = ""
                    return cell
                }else if indexPath.column == 0 {
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CheckBoxXIB", for: indexPath) as! CheckBoxXIB
                    cell.backgroundColor = UIColor(appColor: .AppTint)
                    cell.checkImageView.addCorner(value: 2)
                    cell.checkImageView.backgroundColor = .white
                    cell.checkImageHeight.constant = 20.0

                    if selectedIndexes.contains(indexPath.row) {
                        cell.checkImageView.image = UIImage(named: "check_image")
                    }else {
                        cell.checkImageView.image = UIImage(named: "un_check_image")
                    }
                    return cell
                }else {
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextXib", for: indexPath) as! CellTextXib
                    cell.backgroundColor = .white
                    cell.lblText.textColor = .black
                    cell.gridlines.top = .solid(width: 1, color: UIColor(appColor: .AppTint))
                    cell.gridlines.bottom = .solid(width: 1, color: UIColor(appColor: .AppTint))
                    cell.gridlines.left = .solid(width: 1, color: UIColor(appColor: .AppTint))
                    cell.gridlines.right = .solid(width: 1, color: UIColor(appColor: .AppTint))
                    cell.backgroundColor = UIColor(appColor: .AppTint)
                    cell.lblText.font = UIFont(name: .MontserratSemiBold, size: textFontSize)
                    cell.lblText.textColor = UIColor.white
                    cell.lblText.backgroundColor = UIColor.clear
                    cell.lblText.text = patRowArray[indexPath.section]
                    return cell
                }
            }else if indexPath.row == 1 && isDataNotReceive {
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextXib", for: indexPath) as! CellTextXib
                cell.gridlines.top = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                cell.gridlines.bottom = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                cell.gridlines.left = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                cell.gridlines.right = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                cell.backgroundColor = UIColor.white
                cell.lblText.addCorner(value: 0)
                cell.lblText.font = UIFont(name: .MontserratRegular, size: textFontSize)
                cell.lblText.textColor = UIColor.black
                cell.lblText.backgroundColor = UIColor.clear
                cell.lblText.text = loadingStatus.rawValue
                if loadingStatus == .noResponse && !assetDetailsResponseList.isEmpty {
                    cell.lblText.text = "No Result Found !!"
                }
                return cell
            }else if indexPath.section == 0 ||  indexPath.section == 1 ||  indexPath.section == 2 || indexPath.section == 3 || indexPath.section == 4 || indexPath.section == 5 || indexPath.section == 6 || indexPath.section == 7 {
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextXib", for: indexPath) as! CellTextXib
                cell.backgroundColor = .white
                cell.lblText.textColor = .black
                cell.gridlines.top = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                cell.gridlines.bottom = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                cell.gridlines.left = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                cell.gridlines.right = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                cell.lblText.addCorner(value: 0)
                cell.lblText.font = UIFont(name: .MontserratRegular, size: textFontSize)
                cell.lblText.backgroundColor = UIColor.clear
                
                if indexPath.section == 0 {
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CheckBoxXIB", for: indexPath) as! CheckBoxXIB
                    cell.checkImageHeight.constant = 20.0
                    if selectedIndexes.contains(indexPath.row) {
                        cell.checkImageView.image = UIImage(named: "check_image")
                    }else {
                        cell.checkImageView.image = UIImage(named: "un_check_image")
                    }
                    return cell
                }else if indexPath.section == 1 {
                    if let assetId = assetDetailsResponseList[indexPath.row-1].assetId {
                        cell.lblText.text = "\(assetId)"
                    }else {
                        cell.backgroundColor = .white
                        cell.lblText.text = "--"
                    }
                }else if indexPath.section == 2 {
                    cell.lblText.text = assetDetailsResponseList[indexPath.row-1].assetName
                }else if indexPath.section == 3 {
                    cell.lblText.text = assetDetailsResponseList[indexPath.row-1].manufacturer
                }else if indexPath.section == 4 {
                    let category: String? = (assetDetailsResponseList[indexPath.row-1].category)
                    let subCategory: String? = (assetDetailsResponseList[indexPath.row-1].subCategory)
                    let subCategory2: String? = (assetDetailsResponseList[indexPath.row-1].subCategory2)
                    let subCategory3: String? = (assetDetailsResponseList[indexPath.row-1].subCategory3)
                    
                    let categories = [category, subCategory, subCategory2, subCategory3]
                    
                    let categoriesResult = categories
                        .compactMap { $0?.isEmpty == false ? $0 : nil }
                        .joined(separator: " > ")
                    
                    cell.lblText.text = categoriesResult.isEmpty ? "NA > NA > NA" : categoriesResult
                }else if indexPath.section == 5 {
                    let position: String? = (assetDetailsResponseList[indexPath.row-1].position)
                    let floor: String? = (assetDetailsResponseList[indexPath.row-1].floor)
                    let room: String? = (assetDetailsResponseList[indexPath.row-1].room)
                    
                    let location = [position, floor, room]
                    
                    let locationResult = location
                        .compactMap { $0?.isEmpty == false ? $0 : nil }
                        .joined(separator: " > ")
                    
                    cell.lblText.text = locationResult.isEmpty ? "NA > NA > NA" : locationResult
                }else if indexPath.section == 6 {
                    cell.lblText.text = assetDetailsResponseList[indexPath.row-1].assetPATItems?.first?.patDate?.replacingOccurrences(of: "T10:00:00", with: "")
                }else if indexPath.section == 7 {
                    cell.lblText.text = assetDetailsResponseList[indexPath.row-1].assetPATItems?.first?.patNextDate?.replacingOccurrences(of: "T10:00:00", with: "")
                }
                return cell
            }else if indexPath.section == 8 {
                if let patStatus = assetDetailsResponseList[indexPath.row-1].assetPATItems?.first?.patStatus, patStatus != "" {
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "StatusXIb", for: indexPath) as! StatusXIb
                    cell.setUp(string: patStatus)
                    cell.gridlines.top = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                    cell.gridlines.bottom = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                    cell.gridlines.left = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                    cell.gridlines.right = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                    return cell
                }else {
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextXib", for: indexPath) as! CellTextXib
                    cell.backgroundColor = .white
                    cell.lblText.text = "--"
                    return cell
                }
            }else if indexPath.section == 9 {
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "SiteAssetsActionXIB", for: indexPath) as! SiteAssetsActionXIB
                cell.gridlines.top = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                cell.gridlines.bottom = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                cell.gridlines.left = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                cell.gridlines.right = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                
                if self.isFromReports {
                    cell.qrView.alpha = 0.0
                    cell.deleteView.alpha = 0.0
                    cell.editView.alpha = 0.0
                }
                
                if let assetId = assetDetailsResponseList[indexPath.row-1].assetId {
                    
                    let fullURL = qrBaseURL + String(assetId)
                    
                    DispatchQueue.global(qos: .userInitiated).async {
                        if let qrImage = generateQRCode(from: fullURL) {
                            // Update the UI on the main thread
                            DispatchQueue.main.async {
                                cell.qrImage.image = qrImage
                            }
                        }
                    }
                }
                
                cell.qrButton.addAction { [weak self] in
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        if let assetId = assetDetailsResponseList[indexPath.row-1].assetId, let assetName = assetDetailsResponseList[indexPath.row-1].assetName {
                            let imageView = cell.qrImage
                            let sourceRect = imageView?.frame
                            if let imageView = imageView, let sourceRect = sourceRect {
                                self.showQRImage(assetName: assetName, assetId: assetId, sourceRect: sourceRect, sourceView: imageView)
                            }
                        }
                    }
                }

                cell.viewButton.addAction { [weak self] in
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        self.goFurtherToAssetDetailVC(for: indexPath.row-1, isViewModeEdit: false)
                    }
                }
                cell.editButton.addAction { [weak self] in
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        self.goFurtherToAssetDetailVC(for: indexPath.row-1, isViewModeEdit: true)
                    }
                }
                cell.deleteButton.addAction { [weak self] in
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        showDeleteAlert(userName: assetDetailsResponseList[indexPath.row-1].assetName ?? "", id:assetDetailsResponseList[indexPath.row-1].assetId ?? 0, selectedRow: indexPath.row - 1)
                    }
                }
                return cell
            }
        case .assetPFPAPI(siteId: let siteId):
            if indexPath.row == 0 {
                if indexPath.column == 0 && isDataNotReceive {
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextXib", for: indexPath) as! CellTextXib
                    cell.backgroundColor = UIColor(appColor: .AppTint)
                    cell.lblText.text = ""
                    return cell
                }else if indexPath.column == 0 {
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CheckBoxXIB", for: indexPath) as! CheckBoxXIB
                    cell.backgroundColor = UIColor(appColor: .AppTint)
                    cell.checkImageView.addCorner(value: 2)
                    cell.checkImageView.backgroundColor = .white
                    cell.checkImageHeight.constant = 20.0

                    if selectedIndexes.contains(indexPath.row) {
                        cell.checkImageView.image = UIImage(named: "check_image")
                    }else {
                        cell.checkImageView.image = UIImage(named: "un_check_image")
                    }
                    return cell
                }else {
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextXib", for: indexPath) as! CellTextXib
                    cell.backgroundColor = .white
                    cell.lblText.textColor = .black
                    cell.gridlines.top = .solid(width: 1, color: UIColor(appColor: .AppTint))
                    cell.gridlines.bottom = .solid(width: 1, color: UIColor(appColor: .AppTint))
                    cell.gridlines.left = .solid(width: 1, color: UIColor(appColor: .AppTint))
                    cell.gridlines.right = .solid(width: 1, color: UIColor(appColor: .AppTint))
                    cell.backgroundColor = UIColor(appColor: .AppTint)
                    cell.lblText.font = UIFont(name: .MontserratSemiBold, size: textFontSize)
                    cell.lblText.textColor = UIColor.white
                    cell.lblText.backgroundColor = UIColor.clear
                    cell.lblText.text = pfpRowArray[indexPath.section]
                    return cell
                }
            }else if indexPath.row == 1 && isDataNotReceive {
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextXib", for: indexPath) as! CellTextXib
                cell.gridlines.top = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                cell.gridlines.bottom = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                cell.gridlines.left = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                cell.gridlines.right = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                cell.backgroundColor = UIColor.white
                cell.lblText.addCorner(value: 0)
                cell.lblText.font = UIFont(name: .MontserratRegular, size: textFontSize)
                cell.lblText.textColor = UIColor.black
                cell.lblText.backgroundColor = UIColor.clear
                cell.lblText.text = loadingStatus.rawValue
                if loadingStatus == .noResponse && !assetDetailsResponseList.isEmpty {
                    cell.lblText.text = "No Result Found !!"
                }
                return cell
            }else if indexPath.section == 0 ||  indexPath.section == 1 ||  indexPath.section == 2 || indexPath.section == 3 || indexPath.section == 4 || indexPath.section == 5 || indexPath.section == 6 || indexPath.section == 7 || indexPath.section == 8 || indexPath.section == 9 {
                
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextXib", for: indexPath) as! CellTextXib
                cell.backgroundColor = .white
                cell.lblText.textColor = .black
                cell.gridlines.top = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                cell.gridlines.bottom = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                cell.gridlines.left = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                cell.gridlines.right = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                cell.lblText.addCorner(value: 0)
                cell.lblText.font = UIFont(name: .MontserratRegular, size: textFontSize)
                cell.lblText.backgroundColor = UIColor.clear
                
                if indexPath.section == 0 {
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CheckBoxXIB", for: indexPath) as! CheckBoxXIB
                    cell.checkImageView.backgroundColor = .white
                    cell.checkImageHeight.constant = 20.0

                    if selectedIndexes.contains(indexPath.row) {
                        cell.checkImageView.image = UIImage(named: "check_image")
                    }else {
                        cell.checkImageView.image = UIImage(named: "un_check_image")
                    }
                    return cell
                }else if indexPath.section == 1 {
                    if let assetId = assetDetailsResponseList[indexPath.row-1].assetId {
                        cell.lblText.text = "\(assetId)"
                    }else {
                        cell.backgroundColor = .white
                        cell.lblText.text = "--"
                    }
                }else if indexPath.section == 2 {
                    cell.lblText.text = assetDetailsResponseList[indexPath.row-1].assetName
                }else if indexPath.section == 3 {
                    cell.lblText.text = assetDetailsResponseList[indexPath.row-1].assetPFPItem?.material
                }else if indexPath.section == 4 {
                    cell.lblText.text = assetDetailsResponseList[indexPath.row-1].assetPFPItem?.product
                }else if indexPath.section == 5 {
                    let position: String? = (assetDetailsResponseList[indexPath.row-1].position)
                    let floor: String? = (assetDetailsResponseList[indexPath.row-1].floor)
                    let room: String? = (assetDetailsResponseList[indexPath.row-1].room)
                    
                    let location = [position, floor, room]
                    
                    let locationResult = location
                        .compactMap { $0?.isEmpty == false ? $0 : nil }
                        .joined(separator: " > ")
                    
                    cell.lblText.text = locationResult.isEmpty ? "NA > NA > NA" : locationResult
                }else if indexPath.section == 6 {
                    cell.lblText.text = assetDetailsResponseList[indexPath.row-1].assetPFPItem?.service
                }else if indexPath.section == 7 {
                    cell.lblText.text = assetDetailsResponseList[indexPath.row-1].assetPFPItem?.dimension
                }else if indexPath.section == 8 {
                    cell.lblText.text = assetDetailsResponseList[indexPath.row-1].assetPFPItem?.quantity
                }else if indexPath.section == 9 {
                    cell.lblText.text = assetDetailsResponseList[indexPath.row-1].assetPFPItem?.area
                }
                return cell
            }else if indexPath.section == 10 {
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "SiteAssetsActionXIB", for: indexPath) as! SiteAssetsActionXIB
                cell.gridlines.top = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                cell.gridlines.bottom = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                cell.gridlines.left = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                cell.gridlines.right = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
                
                if self.isFromReports {
                    cell.qrView.alpha = 0.0
                    cell.deleteView.alpha = 0.0
                    cell.editView.alpha = 0.0
                }
                
                if let assetId = assetDetailsResponseList[indexPath.row-1].assetId {
                    
                    let fullURL = qrBaseURL + String(assetId)
                    
                    DispatchQueue.global(qos: .userInitiated).async {
                        if let qrImage = generateQRCode(from: fullURL) {
                            // Update the UI on the main thread
                            DispatchQueue.main.async {
                                cell.qrImage.image = qrImage
                            }
                        }
                    }
                }
                
                cell.qrButton.addAction { [weak self] in
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        if let assetId = assetDetailsResponseList[indexPath.row-1].assetId, let assetName = assetDetailsResponseList[indexPath.row-1].assetName {
                            let imageView = cell.qrImage
                            let sourceRect = imageView?.frame
                            if let imageView = imageView, let sourceRect = sourceRect {
                                self.showQRImage(assetName: assetName, assetId: assetId, sourceRect: sourceRect, sourceView: imageView)
                            }
                        }
                    }
                }

                cell.viewButton.addAction { [weak self] in
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        self.goFurtherToAssetDetailVC(for: indexPath.row-1, isViewModeEdit: false)
                    }
                }
                cell.editButton.addAction { [weak self] in
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        self.goFurtherToAssetDetailVC(for: indexPath.row-1, isViewModeEdit: true)
                    }
                }
                cell.deleteButton.addAction { [weak self] in
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        showDeleteAlert(userName: assetDetailsResponseList[indexPath.row-1].assetName ?? "", id:assetDetailsResponseList[indexPath.row-1].assetId ?? 0, selectedRow: indexPath.row - 1)
                    }
                }
                return cell
            }
        case .none:
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextXib", for: indexPath) as! CellTextXib
            return cell
        }
        let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextXib", for: indexPath) as! CellTextXib
        return cell
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.row == 0, indexPath.column == 0 {
            toggleSelectAll()
        }else if indexPath.column == 0 {
            self.toggleCheckbox(at: indexPath.row)
        }
        
     }
    
    func mergedCells(in spreadsheetView: SpreadsheetView) -> [CellRange] {
        switch self.loadingStatus {
        case .default:
            return []
        case .loading, .failed, .noResponse, .noInternet:
            var totalColumn: Int = 1
            switch self.assetRegisterData {
            case .assetSummaryAPI(siteId: let siteId):
                totalColumn = self.summaryRowArray.count
            case .assetDoorAPI(siteId: let siteId):
                totalColumn = self.doorRowArray.count
            case .assetPatAPI(siteId: let siteId):
                totalColumn = self.patRowArray.count
            case .assetPFPAPI(siteId: let siteId):
                totalColumn = self.pfpRowArray.count
            case .none:
                totalColumn = 0
            }
            return [CellRange(from: IndexPath(row: 1, column: 0), to: IndexPath(row: 1, column: totalColumn-1))]
        }
    }
    
    func frozenRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 1
    }
    
}

extension AssetRegisterVC {
    
    //setup sclAlertView
    func selectAssetToInfo(message: String) {
        SCLAlertView().showInfo("", subTitle: message)
    }
    
}

enum AssetRegisterData {
    
    case assetSummaryAPI(siteId: Int)
    case assetDoorAPI(siteId: Int)
    case assetPatAPI(siteId: Int)
    case assetPFPAPI(siteId: Int)
    case none
    
    func url() -> String {
        switch self {
        case .assetSummaryAPI(let siteId):
            return "http://cpc-beta.ukwest.cloudapp.azure.com/api/site/\(siteId)/assets"
        case .assetDoorAPI(let siteId):
            return "http://cpc-beta.ukwest.cloudapp.azure.com/api/site/\(siteId)/assets?doorItem=true"
        case .assetPatAPI(let siteId):
            return "http://cpc-beta.ukwest.cloudapp.azure.com/api/site/\(siteId)/assets?patItem=true"
        case .assetPFPAPI(let siteId):
            return "http://cpc-beta.ukwest.cloudapp.azure.com/api/site/\(siteId)/assets?pfpItem=true"
        case .none:
            return ""
        }
    }
    
}

extension AssetRegisterVC: UIPopoverPresentationControllerDelegate {

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {

    }

    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return true
    }
}

extension AssetRegisterVC {
    
    func showDeleteAlert(userName: String, id: Int, selectedRow: Int) {
        let alert = UIAlertController(title: nil, message: "Do you want to delete \(userName)?", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            print("\(userName) deleted.")
            DispatchQueue.main.async { [weak self] in
                let appearance = SCLAlertView.SCLAppearance(
                    showCloseButton: false
                )
                let scl = SCLAlertView(appearance: appearance)
                scl.showWait("", subTitle: "please wait...", closeButtonTitle: "")
                guard let self else {return}
                let api = ApiService.deleteSiteAssets(id: id)
                APIClient.requestDelete(api) { [weak self] isSucess in
                    DispatchQueue.main.async { [weak self] in
                        guard let self else {return}
                        scl.hideView()
                        if isSucess {
                            let sclAlertView = SCLAlertView()
                            sclAlertView.showSuccess("", subTitle: "\(userName) site has been deleted successully")
                            self.loadAssetRegisterData(apiService: assetRegisterData)
                            self.spreedSheetView.reloadData()
                        }else {
                            SCLAlertView().showError("Error", subTitle: "Oops! please try again")
                        }
                    }
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func showQRImage(assetName: String, assetId: Int, sourceRect: CGRect, sourceView: UIView) {
        
        let fullURL = qrBaseURL + String(assetId)
        
        if let qrImage = generateQRCode(from: fullURL) {
            let vc = siteAssetsSB.instantiateViewController(withIdentifier: "CloneAssetVC") as! CloneAssetVC
            
            vc.qrImage = qrImage
            vc.assetName = assetName
            
            let nav = UINavigationController(rootViewController: vc)
            nav.setNavigationBarHidden(true, animated: false)
            self.present(nav, animated: true, completion: nil)
        }
        
    }
    
    func goFurtherToAssetDetailVC(for index: Int, isViewModeEdit: Bool) {
        guard assetDetailsResponseList.count > index else { return }
        let item = assetDetailsResponseList[index]
        let vc = siteAssetsSB.instantiateViewController(withIdentifier: "CreateNewAssetVC") as! CreateNewAssetVC
        vc.isViewModeEdit = isViewModeEdit
        vc.selectedAssetId = item.assetId
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
