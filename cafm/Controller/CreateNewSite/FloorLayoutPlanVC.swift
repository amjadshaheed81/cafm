//
//  FloorLayoutPlanVC.swift
//  cafm
//
//  Created by NS on 28/08/24.
//
//

import UIKit
import Highcharts
import SpreadsheetView
import UniformTypeIdentifiers
import PhotosUI
import SkeletonView
import SDWebImage
import SCLAlertView

class FloorLayoutPlanVC: UIViewController {
    
    @IBOutlet weak var emptyView: EmptyView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var chartScrollView: UIScrollView!
    @IBOutlet weak var chartMainView: UIView!
    @IBOutlet weak var chartScrollViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var addNodeMainView: UIView!
    @IBOutlet weak var addNodeMainViewHeight: NSLayoutConstraint!
    @IBOutlet weak var nodeNameView: CustomTextField!
    @IBOutlet weak var nodeTypeView: OptionBtnXib!
    @IBOutlet weak var parentNodeView: OptionBtnXib!
    @IBOutlet weak var addNodeBtn: PrimaryButton!
    
    @IBOutlet weak var updateFloorPlanView: UIView!
    @IBOutlet weak var updateFloorPlanViewHeight: NSLayoutConstraint!
    @IBOutlet weak var updateFloorPlanSpreadsheetView: SpreadsheetView!
    @IBOutlet weak var uploadAllBtn: PrimaryButton!
    
    @IBOutlet weak var floorMapMainView: UIView!
    @IBOutlet weak var floorMapMainViewHeight: NSLayoutConstraint!
    @IBOutlet weak var floorMapCollectionView: UICollectionView!
    @IBOutlet weak var floorMapCollectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var floorMapEmptyView: EmptyView!
    @IBOutlet weak var floorMapImageView: UIImageView!
    
    lazy var nodeNameTextField: UITextField = {
        return self.nodeNameView.textField
    }()
    let loadingSCLAlertView = SCLAlertView(appearance: loadingSCLAppearance)
    
    var loadingStatus: LoadingStatus = .default {
        didSet {
            if self.loadingStatus.hasData {
                self.scrollView.isHidden = false
                self.emptyView.isHidden = true
            }else {
                self.emptyView.mainLbl.text = self.loadingStatus.rawValue
                self.emptyView.isHidden = false
                self.scrollView.isHidden = true
            }
        }
    }
    
    weak var homeVC: CreateNewSiteVC?
    var selectedSiteID: Int?
    var isViewModeEdit: Bool = false
    
    var siteLayoutDataArray: [SiteLayoutModel] = [] {
        didSet {
            self.floorSiteLayoutDataArray = self.getFloorList(from: self.siteLayoutDataArray)
        }
    }
    
    var selectedNodeType: SiteLayoutModel.NodeType = .default {
        didSet {
            if oldValue != self.selectedNodeType {
                self.selectedParentNode = nil
            }
            self.nodeTypeView.lblText.text = self.selectedNodeType.title
            self.setEnableAddNodeBtn()
        }
    }
    var selectedParentNode: SiteLayoutModel? {
        didSet {
            if let parentNode = self.selectedParentNode {
                self.parentNodeView.lblText.text = parentNode.nodeName
            }else {
                self.parentNodeView.lblText.text = "Select Parent Node"
            }
            self.setEnableAddNodeBtn()
        }
    }
    
    let updateFloorPlanHeaderColumnNames = ["Floor Name", "Floor Image", ""]
    var floorSiteLayoutDataArray: [SiteLayoutModel] = []
    
    var selectedFloorMapSiteIndex: Int?
    
    private var myContext = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emptyView.delegate = self
        
        self.setAddNodeMainView()
        self.setupUpdateFloorPlanView()
        self.setupFloorMapView()
        
        self.loadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.floorMapImageView.layoutSkeletonIfNeeded()
    }
    
    func loadData(fromAddNode: Bool = false, fromUploadFloorPlan: Bool = false) {
        self.fetchSiteLayoutData(fromAddNode: fromAddNode, fromUploadFloorPlan: fromUploadFloorPlan)
    }
    
    func fetchSiteLayoutData(fromAddNode: Bool = false, fromUploadFloorPlan: Bool = false) {
        guard let siteID = self.selectedSiteID else {
            self.loadingStatus = .failed
            return
        }
        let apiService = ApiService.siteLayoutAPI(siteId: siteID)
        
        if !fromAddNode && !fromUploadFloorPlan {
            self.loadingStatus = .loading
        }
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<SiteLayoutModel>, Error>) in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single:
                    strongSelf.loadingStatus = .failed
                    if fromAddNode || fromUploadFloorPlan {
                        strongSelf.hideLoadingAndShowError(fromAddNode: true)
                    }
                    break
                case .array(let array):
                    if array.isEmpty {
                        strongSelf.loadingStatus = .noResponse
                        if fromAddNode || fromUploadFloorPlan {
                            strongSelf.hideLoadingAndShowError(fromAddNode: true)
                        }
                    }else {
                        strongSelf.siteLayoutDataArray = array
                        strongSelf.setBuildingLayoutChart()
                        strongSelf.resetAddNodeMainView()
                        if !(fromAddNode || fromUploadFloorPlan) {
                            strongSelf.loadingStatus = .default
                            strongSelf.setAddNodeMainView()
                        }else {
                            strongSelf.resetUpdateFloorPlanView()
                            strongSelf.loadingSCLAlertView.hideView()
                        }
                        strongSelf.reloadUpdateFloorPlanSpreadsheetView()
                        strongSelf.reloadFloorMapCollectionView()
                    }
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                strongSelf.loadingStatus = .failed
                if fromAddNode || fromUploadFloorPlan {
                    strongSelf.hideLoadingAndShowError(fromAddNode: true)
                }
            }
        }
    }
    
    func setAddNodeMainView() {
        if self.isViewModeEdit {
            self.setupNodeNameView()
            self.setupNodeTypeView()
            self.setupParentNodeView()
            self.setEnableAddNodeBtn()
        }else {
            let height = CGFloat.zero
            self.addNodeMainViewHeight.constant = height
            self.addNodeMainView.frame.size.height = height
            self.addNodeMainView.isHidden = true
        }
    }
    
    func resetAddNodeMainView() {
        self.nodeNameTextField.text = nil
        self.selectedNodeType = .default
        self.selectedParentNode = nil
        self.setNodeTypeMenu()
        self.setParentNodeMenu()
        self.setEnableAddNodeBtn()
    }
    
    func setupNodeNameView() {
        self.nodeNameView.delegate = self
        self.nodeNameTextField.font = UIFont(name: .MontserratMedium, size: 17)
        self.nodeNameTextField.delegate = self
        self.nodeNameTextField.placeholder = "Enter Node Name"
    }
    
    func setupNodeTypeView() {
        self.nodeTypeView.lblText.text = "Select Node Type"
        self.nodeTypeView.lblText.font = UIFont(name: .MontserratMedium, size: 17)
        self.setNodeTypeMenu()
    }
    
    func setNodeTypeMenu() {
        var actions: [UIMenuElement] = []
        
        let actionHandler: ((SiteLayoutModel.NodeType) -> Void) = { [weak self] nodeType in
            guard let strongSelf = self else { return }
            strongSelf.selectedNodeType = nodeType
            strongSelf.setNodeTypeMenu()
            strongSelf.setParentNodeMenu()
        }
        
        let floorNodeType = SiteLayoutModel.NodeType.floor
        let floorAction = UIAction(title: floorNodeType.title, state: self.selectedNodeType == floorNodeType ? .on : .off) { [weak self] _ in
            guard self != nil else { return }
            actionHandler(floorNodeType)
        }
        actions.append(floorAction)
        
        if self.siteLayoutDataArray.contains(where: { $0.nodeType == .floor }) {
            let roomNodeType = SiteLayoutModel.NodeType.room
            let roomAction = UIAction(title: roomNodeType.title, state: self.selectedNodeType == roomNodeType ? .on : .off) { [weak self] _ in
                guard self != nil else { return }
                actionHandler(roomNodeType)
            }
            actions.append(roomAction)
        }
        
        self.nodeTypeView.btnDownClick.menu = UIMenu(title: "Select Node Type", children: actions)
        self.nodeTypeView.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func setupParentNodeView() {
        self.parentNodeView.lblText.text = "Select Parent Node"
        self.parentNodeView.lblText.font = UIFont(name: .MontserratMedium, size: 17)
        self.setParentNodeMenu()
    }
    
    func setParentNodeMenu() {
        var actions: [UIMenuElement] = []
        
        let actionHandler: ((SiteLayoutModel) -> Void) = { [weak self] siteLayoutModel in
            guard let strongSelf = self else { return }
            strongSelf.selectedParentNode = siteLayoutModel
            strongSelf.setNodeTypeMenu()
            strongSelf.setParentNodeMenu()
        }
        
        var nodes: [SiteLayoutModel] = []
        if self.selectedNodeType == .floor {
            nodes = self.siteLayoutDataArray.filter { $0.nodeType == .position }
        }else if self.selectedNodeType == .room {
            nodes = self.siteLayoutDataArray.filter { $0.nodeType == .floor }
        }
        
        for node in nodes {
            if let name = node.nodeName, let id = node.id {
                let action = UIAction(title: name, state: self.selectedParentNode?.id == id ? .on : .off) { [weak self] _ in
                    guard self != nil else { return }
                    actionHandler(node)
                }
                actions.append(action)
            }
        }
        
        self.parentNodeView.btnDownClick.menu = UIMenu(title: "Select Parent Node", children: actions)
        self.parentNodeView.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func setEnableAddNodeBtn() {
        //let nodeName = (self.nodeNameTextField.text ?? "").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        //self.addNodeBtn.isEnabled = !nodeName.isEmpty && self.selectedNodeType != .default && self.selectedParentNode != nil
    }
    
    @IBAction func addNodeBtnClicked(_ sender: PrimaryButton) {
        self.nodeNameTextField.endEditing(true)
        let nodeName = (self.nodeNameTextField.text ?? "").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if nodeName.isEmpty {
            SCLAlertView.showErrorAlert(title: "Error", message: "Please enter node name", cancelButtonTitle: "OK")
        }else if self.selectedNodeType == .default {
            SCLAlertView.showErrorAlert(title: "Error", message: "Please select node type", cancelButtonTitle: "OK")
        }else if self.selectedParentNode == nil {
            SCLAlertView.showErrorAlert(title: "Error", message: "Please select parent node", cancelButtonTitle: "OK")
        }else {
            let nodeModel = SiteLayoutModel()
            nodeModel.siteId = self.selectedSiteID
            nodeModel.nodeName = nodeName
            nodeModel.nodeType = self.selectedNodeType
            nodeModel.parentNode = self.selectedParentNode?.id
            self.createNode(nodeModel: nodeModel)
        }
    }
    
    func createNode(nodeModel: SiteLayoutModel) {
        let apiService = ApiService.siteCreateNode(node: nodeModel)
        
        self.loadingSCLAlertView.showLoading()
        APIClient.requestString(apiService) { [weak self] (result: Result<String, Error>) in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let success):
                strongSelf.loadData(fromAddNode: true)
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                strongSelf.hideLoadingAndShowError(fromAddNode: true)
            }
        }
    }
    
    func hideLoadingAndShowError(fromAddNode: Bool = false, fromUploadFloorPlan: Bool = false, message: String? = nil) {
        self.loadingSCLAlertView.hideView()
        let subTitle: String
        if fromAddNode {
            subTitle = "Failed to Add Node!"
        }else if fromUploadFloorPlan {
            subTitle = "Failed to upload Floor Plan!"
        }else {
            subTitle = message ?? "Something went wrong, Please try again!"
        }
        SCLAlertView.showErrorAlert(title: "Error", message: subTitle, cancelButtonTitle: "OK")
    }
    
    func getFloorList(from siteLayout: [SiteLayoutModel]) -> [SiteLayoutModel] {
        let orderMap: [String: Int] = [
            "Basement": 1,
            "Ground Floor": 2,
            "1st Floor": 3,
            "2nd Floor": 4,
            "3rd Floor": 5,
            "4th Floor": 6,
            "5th Floor": 7,
            "6th Floor": 8,
            "7th Floor": 9,
            "Vertical": 10
        ]
        
        // Filter floors with required conditions
        let filteredList = siteLayout.filter {
            $0.nodeType == .floor && !($0.floorPlanUrl?.isEmpty ?? true)
        }
        
        // Sort floors based on the predefined order map
        let sortedList = filteredList.sorted {
            let aOrder = orderMap[$0.nodeName ?? ""] ?? Int.max // Default to high value if not found
            let bOrder = orderMap[$1.nodeName ?? ""] ?? Int.max
            return aOrder < bOrder
        }
        
        return sortedList
    }
    
}

extension FloorLayoutPlanVC: EmptyViewDelegate {
    func emptyViewDidTapView(_ view: EmptyView) {
        if self.loadingStatus.shouldReload {
            self.loadData()
        }
    }
}

extension FloorLayoutPlanVC: HIChartViewDelegate {
    
    func setBuildingLayoutChart() {
        let view: UIView! = self.chartMainView
        view.subviews.filter { $0 is HIChartView }.forEach { $0.removeFromSuperview() }
        
        var organizationData: [[String]] = []
        var nodesArray: [HINodes] = []
        
        guard let mainNode = self.siteLayoutDataArray.first(where: { $0.nodeType == .MasterNode || $0.nodeType == .building }) else {
            return
        }
        
        let positionNodes = self.siteLayoutDataArray.filter({ ($0.nodeType == .position || $0.nodeType == .type) && ($0.nodeName == "Exterior" || $0.nodeName == "Interior") }).sorted(by: { $0.id ?? 0 < $1.id ?? 0 })
        //guard !positionNodes.isEmpty else { return }
        
        var floorNodes: [SiteLayoutModel] = []
        for positionNode in positionNodes {
            let positionFloors = self.siteLayoutDataArray.filter({ $0.parentNode == positionNode.id }).sorted(by: { $0.id ?? 0 < $1.id ?? 0 })
            floorNodes.append(contentsOf: positionFloors)
        }
        
        var roomNodes: [SiteLayoutModel] = []
        for floorNode in floorNodes {
            let floorRooms = self.siteLayoutDataArray.filter({ $0.parentNode == floorNode.id }).sorted(by: { $0.id ?? 0 < $1.id ?? 0 })
            roomNodes.append(contentsOf: floorRooms)
        }
        
        let siteLayoutDataArray = [mainNode]+positionNodes+floorNodes+roomNodes
        
        let nodeHeight: CGFloat = 30
        let padding: CGFloat = 15
        let totalHeight: CGFloat = (CGFloat(siteLayoutDataArray.count)*nodeHeight)+(CGFloat(siteLayoutDataArray.count+1)*padding)
        self.chartScrollViewHeight.constant = totalHeight
        self.chartScrollView.frame.size.height = totalHeight
        
        for siteLayoutModel in siteLayoutDataArray {
            if let id = siteLayoutModel.id {
                
                if let parentNodeID = siteLayoutModel.parentNode {
                    var parentNode: SiteLayoutModel?
                    if parentNodeID == -1 {
                        
                    }else if parentNodeID == 0 {
                        parentNode = siteLayoutDataArray.first(where: { $0.parentNode == -1 })
                    }else {
                        parentNode = siteLayoutDataArray.first(where: { $0.id == parentNodeID })
                    }
                    if let parentNodeID = parentNode?.id {
                        organizationData.append(["\(parentNodeID)", "\(id)"])
                    }
                }
                
                if let nodeName = siteLayoutModel.nodeName {
                    let node = HINodes()
                    node.id = "\(id)"
                    node.name = nodeName
                    node.layout = "hanging"
                    nodesArray.append(node)
                }
            }
        }
        
        let options = HIOptions()
        
        let credit = HICredits()
        credit.enabled = false
        options.credits = credit
        
        let export = HIExporting()
        export.enabled = false
        options.exporting = export
        
        let title = HITitle()
        title.text = ""
        options.title = title
        
        let levelsData: [(color: UIColor, borderColor: UIColor)] = [
            (color: UIColor(appColor: .BLC_Lv1_Green), borderColor: UIColor(appColor: .BLC_Lv1_Green_Border)),
            (color: UIColor(appColor: .BLC_Lv2_Yellow), borderColor: UIColor(appColor: .BLC_Lv2_Yellow_Border)),
            (color: UIColor(appColor: .BLC_Lv3_Red), borderColor: UIColor(appColor: .BLC_Lv3_Red_Border)),
            (color: UIColor(appColor: .BLC_Lv4_Blue), borderColor: UIColor(appColor: .BLC_Lv4_Blue_Border))
        ]
        
        var levels: [HILevels] = []
        for (index, levelData) in levelsData.enumerated() {
            let level = HILevels()
            level.level = NSNumber(integerLiteral: index)
            level.color = HIColor(uiColor: levelData.color)
            level.borderColor = HIColor(uiColor: levelData.borderColor)
            level.borderWidth = 1
            let dataLabels = HIDataLabels()
            dataLabels.color = "black"
            level.dataLabels = dataLabels
            levels.append(level)
        }
        
        let organization = HIOrganization()
        organization.name = "Building Layout"
        organization.keys = ["from", "to"]
        organization.colorByPoint = false
        organization.hangingIndentTranslation = "cumulative"
        organization.hangingIndent = 15
        
        let animation = HIAnimationOptionsObject()
        animation.duration = 0
        organization.animation = animation
        
        organization.data = organizationData
        organization.levels = levels
        organization.nodes = nodesArray
        
        organization.borderRadius = 8
        organization.nodeWidth = 30
        organization.nodePadding = 15
        
        options.series = [organization]
        
        let chart = HIChart()
        chart.backgroundColor = HIColor(uiColor: UIColor.clear)
        chart.inverted = true
        chart.type = "organization"
        
        let chartView = HIChartView(frame: view.bounds)
        chartView.plugins = ["sankey", "organization"]
        chartView.isUserInteractionEnabled = false
        
        options.chart = chart
        chartView.options = options
        
        view.addSubview(chartView)
        chartView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            chartView.topAnchor.constraint(equalTo: view.topAnchor),
            chartView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chartView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chartView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func chartViewDidLoad(_ chart: HIChartView!) {
        
    }
}

extension FloorLayoutPlanVC: CustomTextFieldDelegate {
    func customTextFieldTextDidChange(view: CustomTextField, textField: UITextField) {
        if view == self.nodeNameView {
            self.setEnableAddNodeBtn()
        }
    }
}

extension FloorLayoutPlanVC: UITextFieldDelegate {
    
}

extension FloorLayoutPlanVC: SpreadsheetViewDataSource, SpreadsheetViewDelegate {
    
    func setupUpdateFloorPlanView() {
        if self.isViewModeEdit {
            self.updateFloorPlanSpreadsheetView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            self.updateFloorPlanSpreadsheetView.showsVerticalScrollIndicator = false
            self.updateFloorPlanSpreadsheetView.showsHorizontalScrollIndicator = false
            self.updateFloorPlanSpreadsheetView.bounces = false
            
            self.updateFloorPlanSpreadsheetView.register(UINib(nibName: DashboardTableCell.className(), bundle: nil), forCellWithReuseIdentifier: DashboardTableCell.className())
            self.updateFloorPlanSpreadsheetView.register(UINib(nibName: BadgeLabelCell.className(), bundle: nil), forCellWithReuseIdentifier: BadgeLabelCell.className())
            self.updateFloorPlanSpreadsheetView.register(UINib(nibName: ChooseImageCell.className(), bundle: nil), forCellWithReuseIdentifier: ChooseImageCell.className())
            self.updateFloorPlanSpreadsheetView.dataSource = self
            self.updateFloorPlanSpreadsheetView.delegate = self
            
            self.reloadUpdateFloorPlanSpreadsheetView()
            self.setEnableUploadAllBtn()
        }else {
            let height = CGFloat.zero
            self.updateFloorPlanViewHeight.constant = height
            self.updateFloorPlanView.frame.size.height = height
            self.updateFloorPlanView.isHidden = true
        }
    }
    
    func reloadUpdateFloorPlanSpreadsheetView() {
        if self.isViewModeEdit {
            if self.floorSiteLayoutDataArray.isEmpty {
                let height = CGFloat.zero
                self.updateFloorPlanViewHeight.constant = height
                self.updateFloorPlanView.frame.size.height = height
                self.updateFloorPlanView.isHidden = true
            }else {
                self.updateFloorPlanSpreadsheetView.reloadData()
                let spreadsheetSize = self.updateFloorPlanSpreadsheetView.contentSize
                let height = 40+25+20+spreadsheetSize.height+15+40+20
                self.updateFloorPlanViewHeight.constant = height
                self.updateFloorPlanView.frame.size.height = height
                self.updateFloorPlanView.isHidden = false
            }
        }
    }
    
    func resetUpdateFloorPlanView() {
        self.setEnableUploadAllBtn()
    }
    
    func setEnableUploadAllBtn() {
        //self.uploadAllBtn.isEnabled = self.floorSiteLayoutDataArray.contains(where: { $0.selectedFloorPlanImage != nil || $0.selectedFloorPlanFileURL != nil })
    }
    
    @IBAction func uploadAllBtnClicked(_ sender: PrimaryButton) {
        let toBeUploadModels =  self.floorSiteLayoutDataArray.filter({ $0.selectedFloorPlanImage != nil || $0.selectedFloorPlanFileURL != nil })
        if toBeUploadModels.isEmpty {
            SCLAlertView.showErrorAlert(title: "Error", message: "Please select atleast one floor plan file to proceed.", cancelButtonTitle: "OK")
        }else {
            self.uploadSiteFloorPlan(for: toBeUploadModels)
        }
    }
    
    func uploadSiteFloorPlan(for models: [SiteLayoutModel]) {
        let apiService = ApiService.siteUploadFloorPlan
        
        self.loadingSCLAlertView.showLoading()
        APIClient.requestMultipart(apiService) { multipartFormData in
            for model in models {
                if let fileName = model.selectedFloorPlanFileName {
                    if let planImage = model.selectedFloorPlanImage {
                        if let data = planImage.jpegData(compressionQuality: 0.8) {
                            multipartFormData.append(data, withName: "files", fileName: fileName, mimeType: "image/jpeg")
                        }
                    }else if let fileURL = model.selectedFloorPlanFileURL {
                        do {
                            let data = try Data(contentsOf: fileURL)
                            let pathExtension = fileURL.pathExtension
                            if pathExtension == "pdf" {
                                multipartFormData.append(data, withName: "files", fileName: fileName, mimeType: "application/pdf")
                            }else {
                                multipartFormData.append(data, withName: "files", fileName: fileName, mimeType: "image/\(pathExtension)")
                            }
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
            
            let object: [SiteLayoutModel] = models.compactMap { siteLayoutModel in
                let model = SiteLayoutModel()
                model.nodeId = siteLayoutModel.id
                model.fileName = siteLayoutModel.selectedFloorPlanFileName
                return model
            }
            do {
                let data = try JSONSerialization.data(withJSONObject: object.toJSON(), options: [])
                multipartFormData.append(data, withName: "floorPlans")
            } catch {
                print(error.localizedDescription)
            }
        } completion: { [weak self] (result: Result<APIClient.MappableResult<SiteLayoutModel>, Error>) in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single:
                    strongSelf.hideLoadingAndShowError(fromUploadFloorPlan: true)
                    break
                case .array(let array):
                    strongSelf.loadData(fromUploadFloorPlan: true)
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                strongSelf.hideLoadingAndShowError(fromUploadFloorPlan: true)
            }
        }
    }
    
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return self.updateFloorPlanHeaderColumnNames.count
    }
    
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        return self.floorSiteLayoutDataArray.count+1
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        let column = indexPath.section
        if indexPath.row == 0 {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: DashboardTableCell.className(), for: indexPath) as! DashboardTableCell
            cell.setGridLines(width: 0, color: UIColor.clear)
            cell.gridlines.bottom = .solid(width: 1, color: UIColor(appColor: .PrimaryText).withAlphaComponent(0.8))
            
            if self.updateFloorPlanHeaderColumnNames.count > column {
                let headerText = self.updateFloorPlanHeaderColumnNames[column]
                
                cell.backgroundColor = UIColor.white
                cell.mainLbl.font = UIFont(name: .MontserratSemiBold, size: dashboardPrimaryTextSize)
                cell.mainLbl.textColor = UIColor(appColor: .PrimaryText)
                
                cell.mainLbl.text = headerText
            }
            return cell
        }else {
            let row = indexPath.row-1
            if self.floorSiteLayoutDataArray.count > row {
                let item = self.floorSiteLayoutDataArray[row]
                if column == 0 {
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: DashboardTableCell.className(), for: indexPath) as! DashboardTableCell
                    cell.setGridLines(width: 0, color: UIColor.clear)
                    cell.gridlines.bottom = .solid(width: 1, color: UIColor(appColor: .Separator2))
                    
                    cell.backgroundColor = UIColor.white
                    cell.mainLbl.font = UIFont(name: .MontserratRegular, size: dashboardPrimaryTextSize)
                    cell.mainLbl.textColor = UIColor.primaryText
                    
                    let parentNodeName = self.siteLayoutDataArray.first(where: { $0.id == item.parentNode })?.nodeName ?? ""
                    let nodeName = item.nodeName ?? ""
                    cell.mainLbl.text = "\(parentNodeName): \(nodeName)"
                    
                    return cell
                }else if column == 1 {
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: ChooseImageCell.className(), for: indexPath) as! ChooseImageCell
                    cell.setGridLines(width: 0, color: UIColor.clear)
                    cell.gridlines.bottom = .solid(width: 1, color: UIColor(appColor: .Separator2))
                    
                    CAFMFilePicker(delegate: self).configureFileMenu(on: self, sender: cell.xib.chooseFileBtn, tag: row, allowPhotos: true, supportedTypes: [.image, .pdf])
                    
                    if let fileName = item.selectedFloorPlanFileName {
                        cell.xib.fileNameLbl.text = fileName
                    }else {
                        cell.xib.fileNameLbl.text = "No file chosen"
                    }
                    
                    return cell
                }else if column == 2 {
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: BadgeLabelCell.className(), for: indexPath) as! BadgeLabelCell
                    cell.setGridLines(width: 0, color: UIColor.clear)
                    cell.gridlines.bottom = .solid(width: 1, color: UIColor(appColor: .Separator2))
                    
                    cell.backgroundColor = UIColor.white
                    cell.mainLbl.font = UIFont(name: .MontserratSemiBold, size: dashboardPrimaryTextSize)
                    cell.badgeView.addCorner()
                    cell.badgeView.backgroundColor = UIColor(appColor: .AppTint).withAlphaComponent(0.1)
                    cell.mainLbl.textColor = UIColor(appColor: .AppTint)
                    
                    if let floorPlanURL = item.floorPlanUrl, let url = URL(string: floorPlanURL) {
                        cell.badgeView.isHidden = false
                        cell.mainLbl.text = url.lastPathComponent
                    }else {
                        cell.mainLbl.text = nil
                        cell.badgeView.isHidden = true
                    }
                    return cell
                }
            }
        }
        let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: DashboardTableCell.className(), for: indexPath) as! DashboardTableCell
        return cell
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, didSelectItemAt indexPath: IndexPath) {
        let column = indexPath.section
        if indexPath.row == 0 {
        }else {
            if column == 2 {
                let row = indexPath.row-1
                if self.floorSiteLayoutDataArray.count > row {
                    let item = self.floorSiteLayoutDataArray[row]
                    if let floorPlanURL = item.floorPlanUrl, let url = URL(string: floorPlanURL) {
                        let vc = generalSB.instantiateViewController(withIdentifier: "FileViewVC") as! FileViewVC
                        vc.fileURL = url
                        
                        let nav = UINavigationController(rootViewController: vc)
                        self.present(nav, animated: true)
                    }
                }
            }
        }
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        if self.updateFloorPlanHeaderColumnNames.count > column {
            let headerText = self.updateFloorPlanHeaderColumnNames[column]
            
            let refSize = CGSize(width: 12+30+12, height: 15+20+15)
            let widthAddition: CGFloat = 12+12
            let minWidth = refSize.width-widthAddition
            let maxWidth: CGFloat = isiPadDevice ? 300 : 200
            
            let headerWidth = getLabelSize(text: headerText, font: UIFont(name: .MontserratSemiBold, size: dashboardPrimaryTextSize), minWidth: minWidth, widthAddition: widthAddition, maxWidth: maxWidth).width
            
            if column == 0 {
                let textArray: [String] = self.floorSiteLayoutDataArray.compactMap { item in
                    let parentNodeName = self.siteLayoutDataArray.first(where: { $0.id == item.parentNode })?.nodeName ?? ""
                    let nodeName = item.nodeName ?? ""
                    return "\(parentNodeName): \(nodeName)"
                }
                let maxColumnWidth = getMaxLabelSize(textArray: textArray, font: UIFont(name: .MontserratRegular, size: dashboardPrimaryTextSize), minWidth: minWidth, widthAddition: widthAddition, maxWidth: maxWidth).width
                return max(headerWidth, maxColumnWidth)
            }else if column == 1 {
                return 12+120+15+100+15+12
            }else if column == 2 {
                let refSize = CGSize(width: 12+8+30+8+12, height: 10+4+20+4+10)
                let widthAddition: CGFloat = 12+8+8+12
                let minWidth = refSize.width-widthAddition
                let maxWidth: CGFloat = isiPadDevice ? 400 : 300
                
                let textArray: [String] = self.floorSiteLayoutDataArray.compactMap { item in
                    if let floorPlanURL = item.floorPlanUrl, let url = URL(string: floorPlanURL) {
                        return url.lastPathComponent
                    }
                    return nil
                }
                let maxColumnWidth = getMaxLabelSize(textArray: textArray, font: UIFont(name: .MontserratSemiBold, size: dashboardPrimaryTextSize), minWidth: minWidth, widthAddition: widthAddition, maxWidth: maxWidth).width
                return max(headerWidth, maxColumnWidth)
            }
        }
        return CGFloat.zero
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        let refSize = CGSize(width: 12+30+12, height: 15+20+15)
        let heightAddition: CGFloat = 15+15
        let minHeight = refSize.height-heightAddition
        let maxWidth: CGFloat = isiPadDevice ? 300 : 200
        
        if row == 0 {
            let headerHeight = getMaxLabelSize(textArray: self.updateFloorPlanHeaderColumnNames, font: UIFont(name: .MontserratSemiBold, size: dashboardPrimaryTextSize), maxWidth: maxWidth, minHeight: minHeight, heightAddition: heightAddition).height
            return headerHeight
        }else {
            let index = row-1
            if self.floorSiteLayoutDataArray.count > index {
                let item = self.floorSiteLayoutDataArray[index]
                
                var maxRowHeight: CGFloat = minHeight
                let parentNodeName = self.siteLayoutDataArray.first(where: { $0.id == item.parentNode })?.nodeName ?? ""
                let nodeName = item.nodeName ?? ""
                let text = "\(parentNodeName): \(nodeName)"
                maxRowHeight = max(maxRowHeight, getLabelSize(text: text, font: UIFont(name: .MontserratRegular, size: dashboardPrimaryTextSize), maxWidth: maxWidth, minHeight: minHeight, heightAddition: heightAddition).height)
                
                if let floorPlanURL = item.floorPlanUrl, let url = URL(string: floorPlanURL) {
                    let refSize1 = CGSize(width: 12+8+30+8+12, height: 10+4+20+4+10)
                    let heightAddition1: CGFloat = 10+4+4+10
                    //let minHeight1 = refSize1.height-heightAddition1
                    //let maxWidth1: CGFloat = isiPadDevice ? 400 : 300
                    
                    //let text = url.lastPathComponent
                    //maxRowHeight = max(maxRowHeight, getLabelSize(text: text, font: UIFont(name: .MontserratSemiBold, size: dashboardPrimaryTextSize), maxWidth: maxWidth1, minHeight: minHeight1, heightAddition: heightAddition1).height)
                    maxRowHeight = max(maxRowHeight, refSize1.height)
                }
                
                return max(15+40+15, maxRowHeight)
            }
        }
        return CGFloat.zero
    }
    
}

//MARK: - CAFMFilePickerDelegate
extension FloorLayoutPlanVC: CAFMFilePickerDelegate {
    
    func filePickerDidSelectFile(_ fileData: FilePickerModel, tag: Int) {
        let index = tag
        if self.floorSiteLayoutDataArray.count > index {
            let item = self.floorSiteLayoutDataArray[index]
            item.selectedFloorPlanFileName = fileData.fileName
            item.selectedFloorPlanImage = fileData.image
            item.selectedFloorPlanFileURL = fileData.fileURL
            self.setEnableUploadAllBtn()
            self.reloadUpdateFloorPlanSpreadsheetView()
        }
    }
    
    func filePickerDidClose(tag: Int) {
        let index = tag
        if self.floorSiteLayoutDataArray.count > index {
            let item = self.floorSiteLayoutDataArray[index]
            item.selectedFloorPlanFileName = nil
            item.selectedFloorPlanImage = nil
            item.selectedFloorPlanFileURL = nil
            self.setEnableUploadAllBtn()
            self.reloadUpdateFloorPlanSpreadsheetView()
        }
    }
    
}

extension FloorLayoutPlanVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func setupFloorMapView() {
        self.floorMapCollectionView.delegate = self
        self.floorMapCollectionView.dataSource = self
        self.floorMapEmptyView.delegate = self
        
        self.floorMapEmptyView.isHidden = true
        self.floorMapEmptyView.mainLbl.text = "Floor plan file is not available."
        
        self.floorMapImageView.isHidden = true
        self.floorMapImageView.isSkeletonable = true
        
        self.reloadFloorMapCollectionView()
    }
    
    func reloadFloorMapCollectionView() {
        if self.floorSiteLayoutDataArray.isEmpty {
            let height = CGFloat.zero
            self.floorMapMainViewHeight.constant = height
            self.floorMapMainView.frame.size.height = height
            self.floorMapMainView.isHidden = true
            self.view.layoutIfNeeded()
        }else {
            if self.selectedFloorMapSiteIndex == nil {
                //self.selectedFloorMapSiteIndex = 0
                //self.showFloorMapForSite(at: 0)
            }
            self.floorMapMainView.isHidden = false
            self.floorMapCollectionView.reloadData()
            
            let refSize = CGSize(width: 12+50+12, height: 20+20+20)
            let maxWidth: CGFloat = isiPadDevice ? 200 : 150
            let heightAddition: CGFloat = 20+20
            let minHeight = refSize.height-heightAddition
            
            let textArray: [String] = self.floorSiteLayoutDataArray.compactMap { item in
                let parentNodeName = self.siteLayoutDataArray.first(where: { $0.id == item.parentNode })?.nodeName ?? ""
                let nodeName = item.nodeName ?? ""
                return "\(parentNodeName): \(nodeName)"
            }
            
            let collectionViewHeight = getMaxLabelSize(textArray: textArray, font: UIFont(name: .MontserratMedium, size: dashboardPrimaryTextSize), maxWidth: maxWidth, minHeight: minHeight, heightAddition: heightAddition).height
            
            let height: CGFloat = 40+25+10+collectionViewHeight+min(screenWidth, screenHeight)+10
            self.floorMapMainViewHeight.constant = height
            self.floorMapMainView.frame.size.height = height
            
            self.floorMapCollectionViewHeight.constant = collectionViewHeight
            self.floorMapCollectionView.frame.size.height = collectionViewHeight
            
            self.scrollView.contentInset.bottom = -(min(screenWidth, screenHeight)+10)
            
            self.view.layoutIfNeeded()
        }
    }
    
    func showFloorMapForSite(at index: Int) {
        if self.floorSiteLayoutDataArray.count > index {
            let item = self.floorSiteLayoutDataArray[index]
            let vc = generalSB.instantiateViewController(withIdentifier: "SaveMarkersVC") as! SaveMarkersVC
            vc.siteLayoutModel = item
            vc.siteLayoutDataArray = self.siteLayoutDataArray
            //let nav = UINavigationController(rootViewController: vc)
            //self.present(nav, animated: true)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.floorSiteLayoutDataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LabelSelectionCell", for: indexPath) as! LabelSelectionCell
        cell.mainLbl.font = UIFont(name: .MontserratMedium, size: dashboardPrimaryTextSize)
        
        if self.floorSiteLayoutDataArray.count > indexPath.row {
            let item = self.floorSiteLayoutDataArray[indexPath.row]
            let parentNodeName = self.siteLayoutDataArray.first(where: { $0.id == item.parentNode })?.nodeName ?? ""
            let nodeName = item.nodeName ?? ""
            let text = "\(parentNodeName): \(nodeName)"
            cell.mainLbl.text = text
        }
        
        //if self.selectedFloorMapSiteIndex == indexPath.row {
        //    cell.selectionView.isHidden = false
        //    cell.mainLbl.textColor = UIColor(appColor: .AppTint)
        //}else {
        cell.selectionView.isHidden = true
        cell.mainLbl.textColor = UIColor(appColor: .GrayText)
        //}
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //self.selectedFloorMapSiteIndex = indexPath.row
        self.floorMapCollectionView.reloadData()
        self.floorMapCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        self.showFloorMapForSite(at: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if self.floorSiteLayoutDataArray.count > indexPath.row {
            let refSize = CGSize(width: 12+50+12, height: 20+20+20)
            let widthAddition: CGFloat = 12+12
            let minWidth = refSize.width-widthAddition
            let maxWidth: CGFloat = isiPadDevice ? 200 : 150
            let heightAddition: CGFloat = 20+20
            let minHeight = refSize.height-heightAddition
            
            let item = self.floorSiteLayoutDataArray[indexPath.row]
            let parentNodeName = self.siteLayoutDataArray.first(where: { $0.id == item.parentNode })?.nodeName ?? ""
            let nodeName = item.nodeName ?? ""
            let text = "\(parentNodeName): \(nodeName)"
            
            let width = getLabelSize(text: text, font: UIFont(name: .MontserratMedium, size: dashboardPrimaryTextSize), minWidth: minWidth, widthAddition: widthAddition, maxWidth: maxWidth).width
            
            let textArray: [String] = self.floorSiteLayoutDataArray.compactMap { item in
                let parentNodeName = self.siteLayoutDataArray.first(where: { $0.id == item.parentNode })?.nodeName ?? ""
                let nodeName = item.nodeName ?? ""
                return "\(parentNodeName): \(nodeName)"
            }
            let height = getMaxLabelSize(textArray: textArray, font: UIFont(name: .MontserratMedium, size: dashboardPrimaryTextSize), maxWidth: maxWidth, minHeight: minHeight, heightAddition: heightAddition).height
            return CGSize(width: width, height: height)
        }
        return CGSize.zero
    }
    
}
