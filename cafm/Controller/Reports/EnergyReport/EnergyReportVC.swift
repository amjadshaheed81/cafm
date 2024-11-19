//
//  EnergyReportVC.swift
//  cafm
//
//  Created by NS on 04/11/24.
//
//

import UIKit
import SCLAlertView
import Highcharts

class EnergyReportVC: UIViewController {
    
    @IBOutlet weak var emptyView: EmptyView!
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var budgetCategoryXIB: OptionBtnXib!
    @IBOutlet weak var areaXIB: OptionBtnXib!
    @IBOutlet weak var siteSwitch: DefaultSwitch!
    @IBOutlet weak var siteSwitchLbl: DefaultFontLabel!
    @IBOutlet weak var SelectYearXIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var SelectPreviousYearXIB: OptionBtnWithTitleXIB!
    
    @IBOutlet weak var EnergyCostTitleXIB: TitleBadgeView!
    @IBOutlet weak var EnergyCostChartScrollView: UIScrollView!
    @IBOutlet weak var EnergyCostChartScrollViewHeight: NSLayoutConstraint!
    @IBOutlet weak var EnergyCostChartContainerView: DesignableView!
    @IBOutlet weak var EnergyCostChartContainerViewWidth: NSLayoutConstraint!
    
    @IBOutlet weak var EnergyReadingTitleXIB: TitleBadgeView!
    @IBOutlet weak var EnergyReadingChartScrollView: UIScrollView!
    @IBOutlet weak var EnergyReadingChartScrollViewHeight: NSLayoutConstraint!
    @IBOutlet weak var EnergyReadingChartContainerView: DesignableView!
    @IBOutlet weak var EnergyReadingChartContainerViewWidth: NSLayoutConstraint!
    
    @IBOutlet weak var Site1XIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var Site2XIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var SelectYear2XIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var budgetCategory2XIB: OptionBtnWithTitleXIB!
    
    @IBOutlet weak var EnergyCost2TitleXIB: TitleBadgeView!
    @IBOutlet weak var EnergyCost2ChartScrollView: UIScrollView!
    @IBOutlet weak var EnergyCost2ChartScrollViewHeight: NSLayoutConstraint!
    @IBOutlet weak var EnergyCost2ChartContainerView: DesignableView!
    @IBOutlet weak var EnergyCost2ChartContainerViewWidth: NSLayoutConstraint!
    
    @IBOutlet weak var EnergyReading2TitleXIB: TitleBadgeView!
    @IBOutlet weak var EnergyReading2ChartScrollView: UIScrollView!
    @IBOutlet weak var EnergyReading2ChartScrollViewHeight: NSLayoutConstraint!
    @IBOutlet weak var EnergyReading2ChartContainerView: DesignableView!
    @IBOutlet weak var EnergyReading2ChartContainerViewWidth: NSLayoutConstraint!
    
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
    
    private var filteredEnergySiteSurveyItemArray: [Energy] = []
    private var energySiteSurveyItemArray: [Energy] = []
    private var energySiteSurveyBySiteIdItemArray: [Energy] = []
    private var energySiteSurveyBySite1ItemArray: [Energy] = []
    private var energySiteSurveyBySite2ItemArray: [Energy] = []
    private var ENERGY_COST_BUDGET_CATEGORY_ItemArray: [LOV_Model] = []
    
    private let currentYear: Int = cafmCalendar().component(.year, from: Date())
    private lazy var yearItemArray: [Int] = {
        [Int](0..<16).compactMap { currentYear - $0 }
    }()
    private var selectedBudgetCategory: LOV_Model?
    private var allSites: Bool = false
    private var selectedArea: String?
    private lazy var selectedYear: Int = {
        self.currentYear
    }()
    private lazy var selectedPreviousYear: Int = {
        self.currentYear - 1
    }()
    private var selectedSite1: CreateSiteRequestModel?
    private var selectedSite2: CreateSiteRequestModel?
    private lazy var selectedYear2: Int = {
        self.currentYear
    }()
    private var selectedBudgetCategory2: LOV_Model?
    
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
            self.getEnergySiteSurveyBySiteId()
            break
        default:
            break
        }
    }
    
}

//MARK: - Fields enum
extension EnergyReportVC {
    enum Fields: String, CaseIterable {
        case EnergyCost = "Energy Cost"
        case EnergyReading = "Energy Reading"
    }
}

//MARK: - EmptyViewDelegate
extension EnergyReportVC: EmptyViewDelegate {
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
extension EnergyReportVC {
    
    func loadData() {
        self.getLOVBy(.ENERGY_COST_BUDGET_CATEGORY)
    }
    
    func getLOVBy(_ lovType: LOVTypeEnum) {
        let view1: UIView! = self.EnergyCostChartContainerView
        view1.startSkeleton()
        
        let view2: UIView! = self.EnergyReadingChartContainerView
        view2.startSkeleton()
        
        self.loadingStatus = .loading
        
        let apiService = ApiService.lovAPI(lovType: lovType)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<LOV_Model>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single:
                    self.loadingStatus = .failed
                    break
                case .array(let array):
                    self.ENERGY_COST_BUDGET_CATEGORY_ItemArray = array
                    self.getEnergySiteSurveyBySiteId()
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                self.loadingStatus = .failed
            }
        }
    }
    
    func getEnergySiteSurveyBySiteId() {
        guard let siteID = UserConstants.shared.selectedSiteID else {
            self.loadingStatus = .failed
            return
        }
        let isAll = self.allSites
        let apiService = isAll ? ApiService.energySurveyAll : ApiService.siteEnergyCostDetails(siteId: siteID)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<Energy>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single:
                    self.loadingStatus = .failed
                    break
                case .array(let array):
                    if isAll {
                        self.energySiteSurveyItemArray = array
                    }else {
                        self.energySiteSurveyBySiteIdItemArray = array
                    }
                    self.loadingStatus = .default
                    self.reloadViews()
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                self.loadingStatus = .failed
            }
        }
    }
    
    func getEnergySiteSurveyBySite(isForSite1: Bool) {
        let apiService = isForSite1 ? ApiService.siteEnergyCostDetails(siteId: self.selectedSite1?.siteId ?? 0) : ApiService.siteEnergyCostDetails(siteId: self.selectedSite1?.siteId ?? 1)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<Energy>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single:
                    self.loadingStatus = .failed
                    break
                case .array(let array):
                    if isForSite1 {
                        self.energySiteSurveyBySite1ItemArray = array
                    }else {
                        self.energySiteSurveyBySite2ItemArray = array
                    }
                    self.loadingStatus = .default
                    self.reloadViews2()
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                self.loadingStatus = .failed
            }
        }
    }
    
}

extension EnergyReportVC {
    
    func setupViews() {
        let view1: TitleBadgeView! = self.EnergyCostTitleXIB
        let view1_2: TitleBadgeView! = self.EnergyCost2TitleXIB
        let field1 = Fields.EnergyCost
        view1.titleLbl.text = field1.rawValue
        view1.setBadgeData(text: nil)
        view1_2.titleLbl.text = field1.rawValue
        view1_2.setBadgeData(text: nil)
        
        let view2: TitleBadgeView! = self.EnergyReadingTitleXIB
        let view2_2: TitleBadgeView! = self.EnergyReading2TitleXIB
        let field2 = Fields.EnergyReading
        view2.titleLbl.text = field2.rawValue
        view2.setBadgeData(text: nil)
        view2_2.titleLbl.text = field2.rawValue
        view2_2.setBadgeData(text: nil)
        
        self.budgetCategoryXIB.lblText.text = "Budget Category"
        self.setupBudgetCategoryMenu()
        
        self.areaXIB.lblText.text = "All Sites"
        self.setupAreaMenu()
        self.siteSwitch.isOn = !self.allSites
        self.siteSwitchLbl.text = "Individual Site"
        
        self.SelectYearXIB.title = "Select Year:"
        self.SelectPreviousYearXIB.title = "Select Previous Year:"
        self.Site1XIB.title = "Site 1"
        self.Site2XIB.title = "Site 2"
        self.SelectYear2XIB.title = "Select Year:"
        self.budgetCategory2XIB.title = "Select Budget Category"
        
        self.SelectYearXIB.text = selectedYear.stringValue
        self.SelectPreviousYearXIB.text = selectedPreviousYear.stringValue
        self.Site1XIB.text = "Select Site 1"
        self.Site2XIB.text = "Select Site 2"
        self.SelectYear2XIB.text = selectedYear2.stringValue
        self.budgetCategory2XIB.text = "Budget Category"
        
        self.setupSelectYearMenu()
        self.setupSelectPreviousYearMenu()
        self.setupSite1Menu()
        self.setupSite2Menu()
        self.setupSelectYear2Menu()
        self.setupBudgetCategory2Menu()
    }
    
    func reloadViews() {
        let itemArray = self.allSites ? self.energySiteSurveyItemArray : self.energySiteSurveyBySiteIdItemArray
        if let selectedBudgetCategory {
            self.filteredEnergySiteSurveyItemArray = itemArray.filter({ $0.budgetCategory == selectedBudgetCategory.lovValue })
        }else {
            self.filteredEnergySiteSurveyItemArray = itemArray
        }
        
        self.areaXIB.isUserInteractionEnabled = self.allSites
        self.areaXIB.dummyTF.backgroundColor = self.areaXIB.isUserInteractionEnabled ? UIColor.white : UIColor(appColor: .GrayStatusBG)
        
        self.setupBudgetCategoryMenu()
        self.setupBudgetCategory2Menu()
        
        self.setupEnergyCostChart()
        self.setupEnergyReadingChart()
    }
    
    func setupBudgetCategoryMenu() {
        let view: OptionBtnXib = self.budgetCategoryXIB
        let defaultStr = "Budget Category"
        
        let allCases: [LOV_Model] = self.ENERGY_COST_BUDGET_CATEGORY_ItemArray
        
        let performAction: ((LOV_Model?) -> Void) = { [weak self] item in
            guard let self else { return }
            self.selectedBudgetCategory = item
            view.lblText.text = item?.lovValue ?? defaultStr
            self.reloadViews()
            self.setupBudgetCategoryMenu()
        }
        
        var actions: [UIMenuElement] = []
        let titleAction = UIAction(title: defaultStr, state: self.selectedBudgetCategory?.id == nil ? .on : .off) { [weak self] action in
            guard self != nil else { return }
            performAction(nil)
        }
        actions.append(titleAction)
        
        for item in allCases {
            let action = UIAction(title: item.lovValue ?? "", state: self.selectedBudgetCategory?.id == item.id ? .on : .off) { [weak self] action in
                guard self != nil else { return }
                performAction(item)
            }
            actions.append(action)
        }
        view.btnDownClick.menu = UIMenu(children: actions)
        view.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func setupAreaMenu() {
        let view: OptionBtnXib = self.areaXIB
        let defaultStr = "All Sites"
        
        let allCases: [String] = UserConstants.shared.SiteArea
        
        let performAction: ((String?) -> Void) = { [weak self] item in
            guard let self else { return }
            self.selectedArea = item
            view.lblText.text = item ?? defaultStr
            self.getEnergySiteSurveyBySiteId()
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
    
    func setupSelectYearMenu() {
        let view: OptionBtnXib = self.SelectYearXIB.optionXIB
        
        let allCases: [Int] = yearItemArray
        
        let performAction: ((Int) -> Void) = { [weak self] item in
            guard let self else { return }
            self.selectedYear = item
            view.lblText.text = item.stringValue
            self.reloadViews()
            self.setupSelectYearMenu()
        }
        
        var actions: [UIMenuElement] = []
        for item in allCases {
            let action = UIAction(title: item.stringValue, state: self.selectedYear == item ? .on : .off) { [weak self] action in
                guard self != nil else { return }
                performAction(item)
            }
            actions.append(action)
        }
        view.btnDownClick.menu = UIMenu(children: actions)
        view.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func setupSelectPreviousYearMenu() {
        let view: OptionBtnXib = self.SelectPreviousYearXIB.optionXIB
        
        let allCases: [Int] = yearItemArray
        
        let performAction: ((Int) -> Void) = { [weak self] item in
            guard let self else { return }
            self.selectedPreviousYear = item
            view.lblText.text = item.stringValue
            self.reloadViews()
            self.setupSelectPreviousYearMenu()
        }
        
        var actions: [UIMenuElement] = []
        for item in allCases {
            let action = UIAction(title: item.stringValue, state: self.selectedPreviousYear == item ? .on : .off) { [weak self] action in
                guard self != nil else { return }
                performAction(item)
            }
            actions.append(action)
        }
        view.btnDownClick.menu = UIMenu(children: actions)
        view.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func reloadViews2() {
        self.setupSite1Menu()
        self.setupSite2Menu()
        
        self.setupEnergyCostChart2()
        self.setupEnergyReadingChart2()
    }
    
    func setupSite1Menu() {
        let view: OptionBtnXib = self.Site1XIB.optionXIB
        let defaultStr = "Select Site 1"
        
        let allCases: [CreateSiteRequestModel] = UserConstants.shared.allSites
        
        let performAction: ((CreateSiteRequestModel?) -> Void) = { [weak self] item in
            guard let self else { return }
            self.selectedSite1 = item
            view.lblText.text = item?.siteName ?? defaultStr
            self.getEnergySiteSurveyBySite(isForSite1: true)
        }
        
        var actions: [UIMenuElement] = []
        let titleAction = UIAction(title: defaultStr, state: self.selectedSite1 == nil ? .on : .off) { [weak self] action in
            guard self != nil else { return }
            performAction(nil)
        }
        actions.append(titleAction)
        
        for item in allCases {
            let action = UIAction(title: item.siteName ?? "", state: self.selectedSite1?.siteId == item.siteId ? .on : .off) { [weak self] action in
                guard self != nil else { return }
                performAction(item)
            }
            actions.append(action)
        }
        view.btnDownClick.menu = UIMenu(children: actions)
        view.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func setupSite2Menu() {
        let view: OptionBtnXib = self.Site2XIB.optionXIB
        let defaultStr = "Select Site 2"
        
        let allCases: [CreateSiteRequestModel] = UserConstants.shared.allSites
        
        let performAction: ((CreateSiteRequestModel?) -> Void) = { [weak self] item in
            guard let self else { return }
            self.selectedSite2 = item
            view.lblText.text = item?.siteName ?? defaultStr
            self.getEnergySiteSurveyBySite(isForSite1: false)
        }
        
        var actions: [UIMenuElement] = []
        let titleAction = UIAction(title: defaultStr, state: self.selectedSite2 == nil ? .on : .off) { [weak self] action in
            guard self != nil else { return }
            performAction(nil)
        }
        actions.append(titleAction)
        
        for item in allCases {
            let action = UIAction(title: item.siteName ?? "", state: self.selectedSite2?.siteId == item.siteId ? .on : .off) { [weak self] action in
                guard self != nil else { return }
                performAction(item)
            }
            actions.append(action)
        }
        view.btnDownClick.menu = UIMenu(children: actions)
        view.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func setupSelectYear2Menu() {
        let view: OptionBtnXib = self.SelectYear2XIB.optionXIB
        
        let allCases: [Int] = yearItemArray
        
        let performAction: ((Int) -> Void) = { [weak self] item in
            guard let self else { return }
            self.selectedYear2 = item
            view.lblText.text = item.stringValue
            self.reloadViews2()
            self.setupSelectYear2Menu()
        }
        
        var actions: [UIMenuElement] = []
        for item in allCases {
            let action = UIAction(title: item.stringValue, state: self.selectedYear2 == item ? .on : .off) { [weak self] action in
                guard self != nil else { return }
                performAction(item)
            }
            actions.append(action)
        }
        view.btnDownClick.menu = UIMenu(children: actions)
        view.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func setupBudgetCategory2Menu() {
        let view: OptionBtnXib = self.budgetCategory2XIB.optionXIB
        let defaultStr = "Budget Category"
        
        let allCases: [LOV_Model] = self.ENERGY_COST_BUDGET_CATEGORY_ItemArray
        
        let performAction: ((LOV_Model?) -> Void) = { [weak self] item in
            guard let self else { return }
            self.selectedBudgetCategory2 = item
            view.lblText.text = item?.lovValue ?? defaultStr
            self.reloadViews()
            //self.setupBudgetCategoryMenu()
        }
        
        var actions: [UIMenuElement] = []
        let titleAction = UIAction(title: defaultStr, state: self.selectedBudgetCategory2?.id == nil ? .on : .off) { [weak self] action in
            guard self != nil else { return }
            performAction(nil)
        }
        actions.append(titleAction)
        
        for item in allCases {
            let action = UIAction(title: item.lovValue ?? "", state: self.selectedBudgetCategory2?.id == item.id ? .on : .off) { [weak self] action in
                guard self != nil else { return }
                performAction(item)
            }
            actions.append(action)
        }
        view.btnDownClick.menu = UIMenu(children: actions)
        view.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func processMonthlyCosts(data: [Cost]?, for year: Int) -> [Double] {
        var monthlyCosts = Array(repeating: 0.0, count: 12) // Initialize monthly costs with 0 for each month of the year
        
        data?.forEach { item in
            let calendar = cafmCalendar()
            let fromDateYear = calendar.component(.year, from: item.fromDate?.transformToDate(dateFormat: kResponseDateFormat) ?? Date())
            let toDateYear = calendar.component(.year, from: item.toDate?.transformToDate(dateFormat: kResponseDateFormat) ?? Date())
            
            // Check if the cost is relevant for the specified year
            if fromDateYear == year || toDateYear == year {
                let monthIndex = calendar.component(.month, from: item.fromDate?.transformToDate(dateFormat: kResponseDateFormat) ?? Date()) - 1 // Months are 1-based
                monthlyCosts[monthIndex] += item.cost ?? 0.0 // Accumulate cost for the month
            }
        }
        
        return monthlyCosts
    }
    
    func calculateYearlyCosts(energyData: [Energy]) -> (currentYear: Int, currentYearCosts: [Double], lastYear: Int, lastYearCosts: [Double]) {
        
        let currentYear = self.selectedYear
        let lastYear = self.selectedPreviousYear
        
        var currentYearCosts = Array(repeating: 0.0, count: 12)
        var lastYearCosts = Array(repeating: 0.0, count: 12)
        
        energyData.forEach { energyItem in
            let itemCurrentYearCosts = processMonthlyCosts(data: energyItem.costList ?? [], for: currentYear)
            let itemLastYearCosts = processMonthlyCosts(data: energyItem.costList ?? [], for: lastYear)
            
            currentYearCosts = zip(currentYearCosts, itemCurrentYearCosts).map { $0 + $1 }
            lastYearCosts = zip(lastYearCosts, itemLastYearCosts).map { $0 + $1 }
        }
        
        return (currentYear, currentYearCosts, lastYear, lastYearCosts)
    }
    
    func setupEnergyCostChart() {
        let itemArray = calculateYearlyCosts(energyData: self.filteredEnergySiteSurveyItemArray)
        
        let view: UIView! = self.EnergyCostChartContainerView
        view.stopSkeleton()
        view.subviews.filter { $0 is HIChartView }.forEach { $0.removeFromSuperview() }
        
        self.EnergyCostChartContainerViewWidth.constant = max(screenWidth-10-10, (CGFloat(12)*20)+50)
        view.frame.size.width = self.EnergyCostChartContainerViewWidth.constant
        
        let chartView = HIChartView(frame: view.bounds)
        chartView.addCorner(value: 12)
        chartView.addBorder(width: 1, color: UIColor(appColor: .Separator2))
        chartView.backgroundColor = UIColor.clear
        
        //chartView.plugins = ["series-label"]
        
        let chart = HIChart()
        chart.type = "line"
        
        let options = HIOptions()
        
        let credit = HICredits()
        credit.enabled = false
        options.credits = credit
        
        let export = HIExporting()
        export.enabled = false
        options.exporting = export
        
        let title = HITitle()
        title.text = "Cost Comparison: \(itemArray.currentYear) vs \(itemArray.lastYear)"
        options.title = title
        
        let tooltip = HITooltip()
        tooltip.headerFormat = ""
        tooltip.pointFormat = "<b>{point.y}</b>"
        options.tooltip = tooltip
        
        let legends = HILegend()
        legends.itemStyle = HICSSObject()
        legends.itemStyle.fontSize = isiPadDevice ? "17" : "15"
        options.legend = legends
        
        let xAxis = HIXAxis()
        //xAxis.type = "category"
        xAxis.categories = [
            "Jan",
            "Feb",
            "Mar",
            "Apr",
            "May",
            "Jun",
            "Jul",
            "Aug",
            "Sep",
            "Oct",
            "Nov",
            "Dec",
        ]
        xAxis.labels = HILabels()
        xAxis.labels.rotation = -45
        options.xAxis = [xAxis]
        
        let yAxis = HIYAxis()
        yAxis.min = 0
        yAxis.title = HITitle()
        yAxis.title.text = ""
        options.yAxis = [yAxis]
        
        let plotOptions = HIPlotOptions()
        plotOptions.line = HILine()
        //plotOptions.line.stacking = "normal"
        
        let dataLabels = HIDataLabels()
        dataLabels.enabled = false
        plotOptions.line.dataLabels = [dataLabels]
        plotOptions.line.showInLegend = true
        options.plotOptions = plotOptions
        
        let line1 = HILine()
        line1.name = "Current Year Cost (\(itemArray.currentYear))"
        line1.color = HIColor(uiColor: UIColor(hexString: "#1E3A8A"))
        line1.data = itemArray.currentYearCosts as [Any]
        line1.marker = HIMarker()
        line1.marker.symbol = "circle"
        
        let line2 = HILine()
        line2.name = "Last Year Cost (\(itemArray.lastYear))"
        line2.color = HIColor(uiColor: UIColor(hexString: "#2563EB"))
        line2.data = itemArray.lastYearCosts as [Any]
        line2.marker = HIMarker()
        line2.marker.symbol = "circle"
        
        options.series = [line1, line2]
        
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
    
    func processMonthlyReading(data: [Reading]?, for year: Int) -> [Double] {
        var monthlyReadings = Array(repeating: 0.0, count: 12) // Initialize monthly readings with 0 for each month of the year
        
        data?.forEach { item in
            let calendar = cafmCalendar()
            let readingYear = calendar.component(.year, from: item.readingDate?.transformToDate(dateFormat: kResponseDateFormat) ?? Date())
            
            // Check if the reading is relevant for the specified year
            if readingYear == year {
                let monthIndex = calendar.component(.month, from: item.readingDate?.transformToDate(dateFormat: kResponseDateFormat) ?? Date()) - 1 // Months are 1-based
                monthlyReadings[monthIndex] += item.readingValue ?? 0.0 // Accumulate reading for the month
            }
        }
        
        return monthlyReadings
    }
    
    func calculateYearlyReadings(energyData: [Energy]) -> (currentYear: Int, currentYearReadings: [Double], lastYear: Int, lastYearReadings: [Double]) {
        
        let currentYear = self.selectedYear
        let lastYear = self.selectedPreviousYear
        
        var currentYearReadings = Array(repeating: 0.0, count: 12)
        var lastYearReadings = Array(repeating: 0.0, count: 12)
        
        energyData.forEach { energyItem in
            let itemCurrentYearReading = processMonthlyReading(data: energyItem.readingList ?? [], for: currentYear)
            let itemLastYearReading = processMonthlyReading(data: energyItem.readingList ?? [], for: lastYear)
            
            currentYearReadings = zip(currentYearReadings, itemCurrentYearReading).map { $0 + $1 }
            lastYearReadings = zip(lastYearReadings, itemLastYearReading).map { $0 + $1 }
        }
        
        return (currentYear, currentYearReadings, lastYear, lastYearReadings)
    }
    
    func setupEnergyReadingChart() {
        let itemArray = calculateYearlyReadings(energyData: self.filteredEnergySiteSurveyItemArray)
        
        let view: UIView! = self.EnergyReadingChartContainerView
        view.stopSkeleton()
        view.subviews.filter { $0 is HIChartView }.forEach { $0.removeFromSuperview() }
        
        self.EnergyReadingChartContainerViewWidth.constant = max(screenWidth-10-10, (CGFloat(12)*20)+50)
        view.frame.size.width = self.EnergyReadingChartContainerViewWidth.constant
        
        let chartView = HIChartView(frame: view.bounds)
        chartView.addCorner(value: 12)
        chartView.addBorder(width: 1, color: UIColor(appColor: .Separator2))
        chartView.backgroundColor = UIColor.clear
        
        //chartView.plugins = ["series-label"]
        
        let chart = HIChart()
        chart.type = "line"
        
        let options = HIOptions()
        
        let credit = HICredits()
        credit.enabled = false
        options.credits = credit
        
        let export = HIExporting()
        export.enabled = false
        options.exporting = export
        
        let title = HITitle()
        title.text = "Energy Comparison: \(itemArray.currentYear) vs \(itemArray.lastYear)"
        options.title = title
        
        let tooltip = HITooltip()
        tooltip.headerFormat = ""
        tooltip.pointFormat = "<b>{point.y}</b>"
        options.tooltip = tooltip
        
        let legends = HILegend()
        legends.itemStyle = HICSSObject()
        legends.itemStyle.fontSize = isiPadDevice ? "17" : "15"
        options.legend = legends
        
        let xAxis = HIXAxis()
        //xAxis.type = "category"
        xAxis.categories = [
            "Jan",
            "Feb",
            "Mar",
            "Apr",
            "May",
            "Jun",
            "Jul",
            "Aug",
            "Sep",
            "Oct",
            "Nov",
            "Dec",
        ]
        xAxis.labels = HILabels()
        xAxis.labels.rotation = -45
        options.xAxis = [xAxis]
        
        let yAxis = HIYAxis()
        yAxis.min = 0
        yAxis.title = HITitle()
        yAxis.title.text = ""
        options.yAxis = [yAxis]
        
        let plotOptions = HIPlotOptions()
        plotOptions.line = HILine()
        //plotOptions.line.stacking = "normal"
        
        let dataLabels = HIDataLabels()
        dataLabels.enabled = false
        plotOptions.line.dataLabels = [dataLabels]
        plotOptions.line.showInLegend = true
        options.plotOptions = plotOptions
        
        let line1 = HILine()
        line1.name = "Current Year Energy Reading (\(itemArray.currentYear))"
        line1.color = HIColor(uiColor: UIColor(hexString: "#1E3A8A"))
        line1.data = itemArray.currentYearReadings as [Any]
        line1.marker = HIMarker()
        line1.marker.symbol = "circle"
        
        let line2 = HILine()
        line2.name = "Last Year Energy Reading (\(itemArray.lastYear))"
        line2.color = HIColor(uiColor: UIColor(hexString: "#2563EB"))
        line2.data = itemArray.lastYearReadings as [Any]
        line2.marker = HIMarker()
        line2.marker.symbol = "circle"
        
        options.series = [line1, line2]
        
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
    
    func processMonthlyCosts(data: [Energy], year: Int, budgetCategory: String?) -> [Double] {
        var monthlyCosts = Array(repeating: 0.0, count: 12) // Initialize monthly costs with 0 for each month of the year
        let calendar = cafmCalendar()
        
        data.forEach { energyItem in
            // Check if budget category is required and matches
            if budgetCategory == nil || energyItem.budgetCategory == budgetCategory {
                energyItem.costList?.forEach { item in
                    if let toDate = item.toDate, calendar.component(.year, from: item.toDate?.transformToDate(dateFormat: kResponseDateFormat) ?? Date()) == year {
                        let monthIndex = Calendar.current.component(.month, from: item.fromDate?.transformToDate(dateFormat: kResponseDateFormat) ?? Date()) - 1 // Get zero-based month index
                        monthlyCosts[monthIndex] += item.cost ?? 0.0 // Accumulate cost for the month
                    }
                }
            }
        }
        return monthlyCosts
    }
    
    func processMonthlyConsumption(data: [Energy], year: Int, budgetCategory: String?) -> [Double] {
        var monthlyConsumption = Array(repeating: 0.0, count: 12) // Initialize array to store aggregated monthly consumption
        let calendar = cafmCalendar()
        
        data.forEach { meter in
            // Check if budget category is required and matches
            if budgetCategory == nil || meter.budgetCategory == budgetCategory {
                // Filter and sort readings for the current meter
                let filteredReadings = meter.readingList?
                    .filter { calendar.component(.year, from: $0.readingDate?.transformToDate(dateFormat: kResponseDateFormat) ?? Date()) == year }
                    .sorted { ($0.readingDate?.transformToDate(dateFormat: kResponseDateFormat) ?? Date()) < ($1.readingDate?.transformToDate(dateFormat: kResponseDateFormat) ?? Date()) } ?? []

                // Calculate consumption for this meter and add to monthly totals
                for i in 0..<filteredReadings.count {
                    if filteredReadings.count > i, i-1 > 0 {
                        let currentReading = filteredReadings[i]
                        let previousReading = filteredReadings[i - 1]
                        
                        let currentDate = currentReading.readingDate
                        let previousDate = previousReading.readingDate
                        
                        // Ensure readings are in the same year and for consecutive months
                        if calendar.component(.year, from: currentDate?.transformToDate(dateFormat: kResponseDateFormat) ?? Date()) == year {
                            let monthIndex = calendar.component(.month, from: currentDate?.transformToDate(dateFormat: kResponseDateFormat) ?? Date()) - 1 // Zero-based month index
                            if monthIndex >= 0 && monthIndex < 12 {
                                let consumption = (currentReading.readingValue ?? 0) - (previousReading.readingValue ?? 0)
                                monthlyConsumption[monthIndex] += consumption // Aggregate consumption across meters
                            }
                        }
                    }
                }
            }
        }

        return monthlyConsumption
    }

    
    func setupEnergyCostChart2() {
        let site1Costs = processMonthlyCosts(data: energySiteSurveyBySite1ItemArray, year: self.selectedYear2, budgetCategory: self.selectedBudgetCategory2?.lovValue)
        let site2Costs = processMonthlyCosts(data: energySiteSurveyBySite2ItemArray, year: self.selectedYear2, budgetCategory: self.selectedBudgetCategory2?.lovValue)
        
        let itemArray = calculateYearlyCosts(energyData: self.filteredEnergySiteSurveyItemArray)
        
        let view: UIView! = self.EnergyCost2ChartContainerView
        view.stopSkeleton()
        view.subviews.filter { $0 is HIChartView }.forEach { $0.removeFromSuperview() }
        
        self.EnergyCost2ChartContainerViewWidth.constant = max(screenWidth-10-10, (CGFloat(12)*20)+50)
        view.frame.size.width = self.EnergyCost2ChartContainerViewWidth.constant
        
        let chartView = HIChartView(frame: view.bounds)
        chartView.addCorner(value: 12)
        chartView.addBorder(width: 1, color: UIColor(appColor: .Separator2))
        chartView.backgroundColor = UIColor.clear
        
        //chartView.plugins = ["series-label"]
        
        let chart = HIChart()
        chart.type = "line"
        
        let options = HIOptions()
        
        let credit = HICredits()
        credit.enabled = false
        options.credits = credit
        
        let export = HIExporting()
        export.enabled = false
        options.exporting = export
        
        let title = HITitle()
        title.text = "Cost Comparison for \(self.selectedYear2)"
        options.title = title
        
        let tooltip = HITooltip()
        tooltip.headerFormat = ""
        tooltip.pointFormat = "<b>{point.y}</b>"
        options.tooltip = tooltip
        
        let legends = HILegend()
        legends.itemStyle = HICSSObject()
        legends.itemStyle.fontSize = isiPadDevice ? "17" : "15"
        options.legend = legends
        
        let xAxis = HIXAxis()
        //xAxis.type = "category"
        xAxis.categories = [
            "Jan",
            "Feb",
            "Mar",
            "Apr",
            "May",
            "Jun",
            "Jul",
            "Aug",
            "Sep",
            "Oct",
            "Nov",
            "Dec",
        ]
        xAxis.labels = HILabels()
        xAxis.labels.rotation = -45
        options.xAxis = [xAxis]
        
        let yAxis = HIYAxis()
        yAxis.min = 0
        yAxis.title = HITitle()
        yAxis.title.text = ""
        options.yAxis = [yAxis]
        
        let plotOptions = HIPlotOptions()
        plotOptions.line = HILine()
        //plotOptions.line.stacking = "normal"
        
        let dataLabels = HIDataLabels()
        dataLabels.enabled = false
        plotOptions.line.dataLabels = [dataLabels]
        plotOptions.line.showInLegend = true
        options.plotOptions = plotOptions
        
        let line1 = HILine()
        line1.name = "Site 1 Cost (\(self.selectedYear2))"
        line1.color = HIColor(uiColor: UIColor(red: 39/255, green: 60/255, blue: 117/255, alpha: 1))
        line1.data = site1Costs as [Any]
        line1.marker = HIMarker()
        line1.marker.symbol = "circle"
        
        let line2 = HILine()
        line2.name = "Site 2 Cost (\(self.selectedYear2))"
        line2.color = HIColor(uiColor: UIColor(red: 44/255, green: 62/255, blue: 80/255, alpha: 1))
        line2.data = site2Costs as [Any]
        line2.marker = HIMarker()
        line2.marker.symbol = "circle"
        
        options.series = [line1, line2]
        
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

    func setupEnergyReadingChart2() {
        let site1CurrentYearConsumption = processMonthlyConsumption(data: energySiteSurveyBySite1ItemArray, year: self.selectedYear2, budgetCategory: self.selectedBudgetCategory2?.lovValue)
        let site2CurrentYearConsumption = processMonthlyConsumption(data: energySiteSurveyBySite2ItemArray, year: self.selectedYear2, budgetCategory: self.selectedBudgetCategory2?.lovValue)
        
        let itemArray = calculateYearlyCosts(energyData: self.filteredEnergySiteSurveyItemArray)
        
        let view: UIView! = self.EnergyReading2ChartContainerView
        view.stopSkeleton()
        view.subviews.filter { $0 is HIChartView }.forEach { $0.removeFromSuperview() }
        
        self.EnergyReading2ChartContainerViewWidth.constant = max(screenWidth-10-10, (CGFloat(12)*20)+50)
        view.frame.size.width = self.EnergyReading2ChartContainerViewWidth.constant
        
        let chartView = HIChartView(frame: view.bounds)
        chartView.addCorner(value: 12)
        chartView.addBorder(width: 1, color: UIColor(appColor: .Separator2))
        chartView.backgroundColor = UIColor.clear
        
        //chartView.plugins = ["series-label"]
        
        let chart = HIChart()
        chart.type = "line"
        
        let options = HIOptions()
        
        let credit = HICredits()
        credit.enabled = false
        options.credits = credit
        
        let export = HIExporting()
        export.enabled = false
        options.exporting = export
        
        let title = HITitle()
        title.text = "Energy Consumption for \(self.selectedYear2)"
        options.title = title
        
        let tooltip = HITooltip()
        tooltip.headerFormat = ""
        tooltip.pointFormat = "<b>{point.y}</b>"
        options.tooltip = tooltip
        
        let legends = HILegend()
        legends.itemStyle = HICSSObject()
        legends.itemStyle.fontSize = isiPadDevice ? "17" : "15"
        options.legend = legends
        
        let xAxis = HIXAxis()
        //xAxis.type = "category"
        xAxis.categories = [
            "Jan",
            "Feb",
            "Mar",
            "Apr",
            "May",
            "Jun",
            "Jul",
            "Aug",
            "Sep",
            "Oct",
            "Nov",
            "Dec",
        ]
        xAxis.labels = HILabels()
        xAxis.labels.rotation = -45
        options.xAxis = [xAxis]
        
        let yAxis = HIYAxis()
        yAxis.min = 0
        yAxis.title = HITitle()
        yAxis.title.text = ""
        options.yAxis = [yAxis]
        
        let plotOptions = HIPlotOptions()
        plotOptions.line = HILine()
        //plotOptions.line.stacking = "normal"
        
        let dataLabels = HIDataLabels()
        dataLabels.enabled = false
        plotOptions.line.dataLabels = [dataLabels]
        plotOptions.line.showInLegend = true
        options.plotOptions = plotOptions
        
        let line1 = HILine()
        line1.name = "Site 1 (\(self.selectedYear2))"
        line1.color = HIColor(uiColor: UIColor(red: 39/255, green: 60/255, blue: 117/255, alpha: 1))
        line1.data = site1CurrentYearConsumption as [Any]
        line1.marker = HIMarker()
        line1.marker.symbol = "circle"
        
        let line2 = HILine()
        line2.name = "Site 2 (\(self.selectedYear2))"
        line2.color = HIColor(uiColor: UIColor(red: 44/255, green: 62/255, blue: 80/255, alpha: 1))
        line2.data = site2CurrentYearConsumption as [Any]
        line2.marker = HIMarker()
        line2.marker.symbol = "circle"
        
        options.series = [line1, line2]
        
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
