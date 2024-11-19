//
//  ContractReportVC.swift
//  cafm
//
//  Created by NS on 04/11/24.
//
//

import UIKit
import SCLAlertView
import Highcharts

class ContractReportVC: UIViewController {
    
    @IBOutlet weak var emptyView: EmptyView!
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var viewCategoryXIB: OptionBtnXib!
    @IBOutlet weak var viewSubCategoryXIB: OptionBtnXib!
    @IBOutlet weak var siteSwitch: DefaultSwitch!
    @IBOutlet weak var areaXIB: OptionBtnXib!
    
    @IBOutlet weak var chartScrollView: UIScrollView!
    @IBOutlet weak var chartScrollViewHeight: NSLayoutConstraint!
    @IBOutlet weak var chartContainerView: DesignableView!
    @IBOutlet weak var chartContainerViewWidth: NSLayoutConstraint!
    
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
    
    weak var homeVC: ReportsVC?
    var isViewModeEdit: Bool = false
    
    var siteContractsCategoryResponseArray: [SiteContractsCategotyResponse] = []
    var siteContractsSubCategoryResponseArray: [SiteContractsCategotyResponse] = []
    var siteContractsDetailArray: [ProjectContract] = []
    var filteredSiteContractsDetailArray: [ProjectContract] = []
    
    private var searchCategotyInd = 0 {
        didSet {
            self.searchSubCategotyInd = 0
            self.viewSubCategoryXIB.lblText.text = "Sub Category"
            self.setSubContractsCategoryXib()
        }
    }
    private var searchSubCategotyInd = 0
    private var allSites: Bool = true
    private var selectedArea: String?
    
    private let kResponseDateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    private let kRequestDateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'" //"yyyy-MM-dd HH:mm:ss"
    private let yyyyMMddStr = "yyyy-MM-dd"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emptyView.delegate = self
        self.setupViews()
        self.loadData()
    }
    
    @IBAction func energyReportBtnClicked(_ sender: UIButton) {
        
    }
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        switch sender {
        case self.siteSwitch:
            self.allSites = !self.siteSwitch.isOn
            self.getProjectContracts()
            break
        default:
            break
        }
    }
    
}

//MARK: - EmptyViewDelegate
extension ContractReportVC: EmptyViewDelegate {
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
extension ContractReportVC {
    
    func loadData() {
        self.loadCategoryDetail()
    }
    
    func loadCategoryDetail() {
        self.loadingStatus = .loading
        
        let apiService = ApiService.getProjectContractsCategory
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<SiteContractsCategotyResponse>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let responseResult):
                if case .array(let siteContractsCategotyArray) = responseResult {
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        self.viewCategoryXIB.lblText.text = "Category"
                        self.siteContractsCategoryResponseArray = siteContractsCategotyArray
                        self.setContractsCategoryXib()
                        self.loadSubCategoryDetail()
                    }
                }else {
                    self.loadingStatus = .failed
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                self.loadingStatus = .failed
            }
        }
    }
    
    func loadSubCategoryDetail() {
        let apiService = ApiService.getProjectContractSubCategory
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<SiteContractsCategotyResponse>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let responseResult):
                if case .array(let siteContractsCategotyArray) = responseResult {
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        self.viewSubCategoryXIB.lblText.text = "Sub Category"
                        self.siteContractsSubCategoryResponseArray = siteContractsCategotyArray
                        self.setSubContractsCategoryXib()
                        self.getProjectContracts()
                    }
                }else {
                    self.loadingStatus = .failed
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                self.loadingStatus = .failed
            }
        }
    }
    
    func getProjectContracts() {
        var area: String?
        var siteId: Int?
        if !self.allSites {
            siteId = UserConstants.shared.selectedSiteID
        }
        if self.allSites, let selectedArea {
            area = try? selectedArea.asURL().absoluteString
        }
        self.loadingStatus = .loading
        let apiService = ApiService.getSelectedSiteContractDetails(siteId: siteId, contractId: nil, area: area)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<ProjectContractsResponse>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .array:
                    self.loadingStatus = .failed
                    break
                case .single(let single):
                    let array = single.projectContracts ?? []
                    self.siteContractsDetailArray = array
                    self.loadingStatus = .default
                    self.reloadViews()
                    break
                }
            case .failure(let error):
                self.loadingStatus = .failed
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
}

extension ContractReportVC {
    
    func setupViews() {
        self.viewCategoryXIB.lblText.text = "Category"
        self.viewSubCategoryXIB.lblText.text = "Sub Category"
        
        self.areaXIB.lblText.text = "All Sites"
        self.setupAreaMenu()
        self.siteSwitch.isOn = !self.allSites
    }
    
    func reloadViews() {
        self.areaXIB.isUserInteractionEnabled = self.allSites
        self.areaXIB.dummyTF.backgroundColor = self.areaXIB.isUserInteractionEnabled ? UIColor.white : UIColor(appColor: .GrayStatusBG)
        
        var itemArray = self.siteContractsDetailArray
        if self.viewCategoryXIB.lblText.text != "Category" {
            itemArray = itemArray.filter({ user in
                (user.category?.lowercased() ?? "") == self.viewCategoryXIB.lblText.text?.lowercased()
            })
        }
        if self.viewSubCategoryXIB.lblText.text != "Sub Category" {
            itemArray = itemArray.filter({ user in
                (user.subCategory?.lowercased() ?? "") == self.viewSubCategoryXIB.lblText.text?.lowercased()
            })
        }
        self.filteredSiteContractsDetailArray = itemArray
        self.setContractsCategoryXib()
        self.setSubContractsCategoryXib()
        
        self.setupChart()
    }
    
    func setupAreaMenu() {
        let view: OptionBtnXib = self.areaXIB
        let defaultStr = "All Sites"
        
        let allCases: [String] = UserConstants.shared.SiteArea
        
        let performAction: ((String?) -> Void) = { [weak self] item in
            guard let self else { return }
            self.selectedArea = item
            view.lblText.text = item ?? defaultStr
            self.getProjectContracts()
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
    
    func setContractsCategoryXib() {
        var actions = [UIAction]()
        actions.append(UIAction(title: "Category", state: searchCategotyInd == 0 ? .on : .off, handler: { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.viewCategoryXIB.lblText.text = "Category"
                self.searchCategotyInd = 0
                self.reloadViews()
            }
        }))
        var seenAreas = Set<String?>()
        
        for (key,item) in self.siteContractsCategoryResponseArray.enumerated() {
            let area = item.lovValue ?? "No Category"
            
            if seenAreas.contains(area) {
                continue
            }
            
            seenAreas.insert(area) // Add the area to the set
            
            actions.append(UIAction(title: area, state: searchCategotyInd == key+1 ? .on : .off, handler: { [weak self] _ in
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.viewCategoryXIB.lblText.text = item.lovValue
                    self.searchCategotyInd = key + 1
                    self.reloadViews()
                }
            }))
        }
        self.viewCategoryXIB.btnDownClick.menu = UIMenu(title: "", children: actions)
        self.viewCategoryXIB.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func setSubContractsCategoryXib() {
        var actions = [UIAction]()
        actions.append(UIAction(title: "Sub Category", state: searchSubCategotyInd == 0 ? .on : .off, handler: { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.viewSubCategoryXIB.lblText.text = "Sub Category"
                self.searchSubCategotyInd = 0
                self.reloadViews()
            }
        }))
        var seensubCategory = Set<String?>()
        
        for (key,item) in self.siteContractsSubCategoryResponseArray.enumerated() {
            if self.viewCategoryXIB.lblText.text?.lowercased() == item.lovDesc?.lowercased() {
                let subCategory = item.lovValue ?? "No Sub Category"
                
                if seensubCategory.contains(subCategory) {
                    continue
                }
                
                seensubCategory.insert(subCategory)
                
                actions.append(UIAction(title: subCategory, state: searchSubCategotyInd == key+1 ? .on : .off, handler: { [weak self] _ in
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        self.searchSubCategotyInd = key + 1
                        self.viewSubCategoryXIB.lblText.text = item.lovValue
                        self.reloadViews()
                    }
                }))
            }
        }
        self.viewSubCategoryXIB.btnDownClick.menu = UIMenu(title: "", children: actions)
        self.viewSubCategoryXIB.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func processMonthlyBudget(data: [ProjectContract]) -> [(label: String, dataValue: Double)] {
        var monthlyBudget: [(label: String, dataValue: Double)] = []
        data.forEach { item in
            if item.status == "Active", let budget = Double(item.budget ?? "") {
                let category = item.category ?? ""
                if let index = monthlyBudget.firstIndex(where: { $0.label == category }) {
                    monthlyBudget[index].dataValue += budget
                }else {
                    monthlyBudget.append((label: category, dataValue: budget))
                }
                
            }
        }
        return monthlyBudget
    }
    
    func setupChart() {
        let itemArray = processMonthlyBudget(data: self.filteredSiteContractsDetailArray)
        
        let view: UIView! = self.chartContainerView
        view.stopSkeleton()
        view.subviews.filter { $0 is HIChartView }.forEach { $0.removeFromSuperview() }
        
        self.chartContainerViewWidth.constant = screenWidth-10-10
        view.frame.size.width = self.chartContainerViewWidth.constant
        
        let chartView = HIChartView(frame: view.bounds)
        chartView.addCorner(value: 12)
        chartView.addBorder(width: 1, color: UIColor(appColor: .Separator2))
        chartView.backgroundColor = UIColor.clear
        chartView.plugins = ["variable-pie"]
        
        let chart = HIChart()
        chart.type = "variablepie"
        
        let options = HIOptions()
        
        let credit = HICredits()
        credit.enabled = false
        options.credits = credit
        
        let export = HIExporting()
        export.enabled = false
        options.exporting = export
        
        let title = HITitle()
        title.text = "Active Contract Costs"
        options.title = title
        
        let tooltip = HITooltip()
        tooltip.headerFormat = ""
        tooltip.pointFormat = "{point.name}: <b>{point.y}</b>"
        //tooltip.pointFormat = "Total Budget by Category <br/>{point.name}: £{point.y} ({point.7}%)"
        options.tooltip = tooltip
        
        let legends = HILegend()
        legends.itemStyle = HICSSObject()
        legends.itemStyle.fontSize = isiPadDevice ? "17" : "15"
        options.legend = legends
        
        let plotOptions = HIPlotOptions()
        plotOptions.variablepie = HIVariablepie()
        plotOptions.variablepie.allowPointSelect = true
        plotOptions.variablepie.cursor = "pointer"
        
        //let dataLabels = HIDataLabels()
        //dataLabels.enabled = false
        //plotOptions.variablepie.dataLabels = [dataLabels]
        plotOptions.variablepie.showInLegend = true
        options.plotOptions = plotOptions

        let chartColors = ["#1E3A8A", "#2563EB", "#60A5FA", "#93C5FD", "#0A2540", "#0077B6", "#CAF0F8"]
        var chartData: [HIData] = []
        for (index, item) in itemArray.enumerated() {
            let data = HIData()
            data.name = item.label
            data.y = NSNumber(floatLiteral: item.dataValue)
            data.z = NSNumber(floatLiteral: (item.dataValue/itemArray.reduce(Double.zero, { $0 + $1.dataValue }))*100)
            data.color = HIColor(uiColor: UIColor(hexString: chartColors[index%chartColors.count]))
            chartData.append(data)
        }
        
        let variablepie = HIVariablepie()
        variablepie.innerSize = "40%"
        variablepie.zMin = 0
        variablepie.name = "Total Budget by Category"
        variablepie.data = chartData
        
        variablepie.borderWidth = 1
        variablepie.borderColor = HIColor(uiColor: UIColor.white)
        let borderRadius = HIBorderRadiusOptionsObject()
        borderRadius.radius = 5
        variablepie.borderRadius = borderRadius
        
        options.series = [variablepie]
        
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
    
}
