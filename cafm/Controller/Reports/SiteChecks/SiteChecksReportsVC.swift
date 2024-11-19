//
//  SiteChecksReportsVC.swift
//  cafm
//
//  Created by NS on 29/10/24.
//
//

import UIKit
import SCLAlertView
import SkeletonView
import Highcharts

class SiteChecksReportsVC: UIViewController {
    
    @IBOutlet weak var emptyView: EmptyView!
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var siteSwitch: DefaultSwitch!
    @IBOutlet weak var typeXIB: OptionBtnXib!
    @IBOutlet weak var subTypeXIB: OptionBtnXib!
    @IBOutlet weak var statusXIB: OptionBtnXib!
    
    @IBOutlet weak var RiskScoreboardTitleXIB: TitleBadgeView!
    @IBOutlet weak var RiskScoreboardChartScrollView: UIScrollView!
    @IBOutlet weak var RiskScoreboardChartScrollViewHeight: NSLayoutConstraint!
    @IBOutlet weak var RiskScoreboardChartContainerView: DesignableView!
    @IBOutlet weak var RiskScoreboardChartContainerViewWidth: NSLayoutConstraint!
    
    @IBOutlet weak var SiteChecksTitleXIB: TitleBadgeView!
    @IBOutlet weak var SiteChecksChartScrollView: UIScrollView!
    @IBOutlet weak var SiteChecksChartScrollViewHeight: NSLayoutConstraint!
    @IBOutlet weak var SiteChecksChartContainerView: DesignableView!
    @IBOutlet weak var SiteChecksChartContainerViewWidth: NSLayoutConstraint!
    
    @IBOutlet weak var ActionLogTitleXIB: TitleBadgeView!
    @IBOutlet weak var ActionLogChartScrollView: UIScrollView!
    @IBOutlet weak var ActionLogChartScrollViewHeight: NSLayoutConstraint!
    @IBOutlet weak var ActionLogChartContainerView: DesignableView!
    @IBOutlet weak var ActionLogChartContainerViewWidth: NSLayoutConstraint!
    
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
    
    private var userBySiteIdItemArray: [User] = []
    private var filteredSiteCheckItemArray: [SiteCheckModel] = []
    private var siteCheckItemArray: [SiteCheckModel] = []
    private var siteCheckBySiteIdItemArray: [SiteCheckModel] = []
    private var SITE_CHECK_TYPE_ItemArray: [LOV_Model] = []
    private var SITE_CHECK_SUB_TYPE_ItemDict: [String: [LOV_Model]] = [:]
    
    private var allSites: Bool = false
    var selectedTypeId: Int?
    var selectedSubTypeId: Int?
    var selectedStatus: SiteCheckModel.Status = .default
    
    private let typeStr = "Type"
    private let subTypeStr = "Sub Type"
    private let statusStr = "Status"
    private let kResponseDateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    private let kRequestDateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'" //"yyyy-MM-dd HH:mm:ss"
    private let yyyyMMddStr = "yyyy-MM-dd"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emptyView.delegate = self
        self.setupViews()
        self.loadData()
    }
    
    @IBAction func siteChecksBtnClicked(_ sender: UIButton) {
        
    }
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        switch sender {
        case self.siteSwitch:
            self.allSites = !self.siteSwitch.isOn
            self.getSiteCheckDataBySiteId(isAll: self.allSites)
            break
        default:
            break
        }
    }
    
}

//MARK: - Fields enum
extension SiteChecksReportsVC {
    enum Fields: String, CaseIterable {
        case RiskScoreboard = "Total Actions"
        case SiteChecks = "Site Checks"
        case ActionLog = "Action Log"
    }
}

//MARK: - EmptyViewDelegate
extension SiteChecksReportsVC: EmptyViewDelegate {
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
extension SiteChecksReportsVC {
    
    func loadData() {
        self.getAllUserBySiteId()
    }
    
    func getAllUserBySiteId() {
        guard let siteID = UserConstants.shared.selectedSiteID else {
            self.loadingStatus = .failed
            return
        }
        
        let view1: UIView! = self.RiskScoreboardChartContainerView
        view1.startSkeleton()
        
        let view2: UIView! = self.SiteChecksChartContainerView
        view2.startSkeleton()
        
        let view3: UIView! = self.ActionLogChartContainerView
        view3.startSkeleton()
        
        self.loadingStatus = .loading
        let apiService = ApiService.getAllUserBy(siteId: siteID)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<UsersList>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single(let single):
                    self.userBySiteIdItemArray = (single.users ?? []).sorted(by: { $0.name ?? "" < $1.name ?? "" })
                    self.get_lovSITE_CHECK_TYPE()
                    break
                case .array:
                    self.loadingStatus = .failed
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                self.loadingStatus = .failed
            }
        }
    }
    
    func get_lovSITE_CHECK_TYPE() {
        let apiService = ApiService.lovAPI(lovType: .SITE_CHECK_TYPE)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<LOV_Model>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single:
                    self.loadingStatus = .failed
                    break
                case .array(let array):
                    self.SITE_CHECK_TYPE_ItemArray = array
                    self.getSiteCheckDataBySiteId(isAll: self.allSites)
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                self.loadingStatus = .failed
            }
        }
    }
    
    func get_lovSITE_CHECK_SUB_TYPE(filter1: String) {
        let apiService = ApiService.lovAPI(lovType: .SITE_CHECK_SUB_TYPE, filter1: filter1)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<LOV_Model>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single:
                    break
                case .array(let array):
                    self.SITE_CHECK_SUB_TYPE_ItemDict[filter1] = array
                    self.reloadViews()
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
            }
        }
    }
    
    func getSiteCheckDataBySiteId(isAll: Bool) {
        guard let siteID = UserConstants.shared.selectedSiteID else {
            self.loadingStatus = .failed
            return
        }
        
        let apiService = isAll ? ApiService.siteCheckAllAPI : ApiService.siteCheckSiteAPI(siteId: siteID)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<SiteCheckModel>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single:
                    self.loadingStatus = .failed
                    break
                case .array(let array):
                    if isAll {
                        self.siteCheckItemArray = array
                    }else {
                        self.siteCheckBySiteIdItemArray = array
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
    
}

extension SiteChecksReportsVC {
    
    func setupViews() {
        let view1: TitleBadgeView! = self.RiskScoreboardTitleXIB
        let field1 = Fields.RiskScoreboard
        view1.titleLbl.text = field1.rawValue
        view1.setBadgeData(text: nil)
        
        let view2: TitleBadgeView! = self.SiteChecksTitleXIB
        let field2 = Fields.SiteChecks
        view2.titleLbl.text = field2.rawValue
        view2.setBadgeData(text: nil)
        
        let view3: TitleBadgeView! = self.ActionLogTitleXIB
        let field3 = Fields.ActionLog
        view3.titleLbl.text = field3.rawValue
        view3.setBadgeData(text: nil)
        
        self.typeXIB.lblText.text = typeStr
        self.subTypeXIB.lblText.text = subTypeStr
        self.statusXIB.lblText.text = statusStr
        self.setupStatusMenu()
    }
    
    func reloadViews() {
        var itemArray = self.allSites ? self.siteCheckItemArray : self.siteCheckBySiteIdItemArray
        if let selectedTypeId, let type = self.SITE_CHECK_TYPE_ItemArray.first(where: { $0.id == selectedTypeId })?.lovValue {
            itemArray = itemArray.filter({ $0.type == type })
            if let selectedSubTypeId, let subTypeItemArray = self.SITE_CHECK_SUB_TYPE_ItemDict[type], let subType = subTypeItemArray.first(where: { $0.id == selectedSubTypeId })?.lovValue {
                itemArray = itemArray.filter({ $0.subType == subType })
            }
        }
        if self.selectedStatus != .default {
            itemArray = itemArray.filter({ $0.status == self.selectedStatus })
        }
        self.filteredSiteCheckItemArray = itemArray
        self.setupTypeMenu()
        self.setupSubTypeMenu()
        
        self.setupRiskScoreboardChart()
        self.setupSiteChecksChart()
        self.setupActionLogChart()
    }
    
    func setupTypeMenu() {
        let view: OptionBtnXib = self.typeXIB
        let defaultStr = typeStr
        var actions: [UIMenuElement] = []
        
        let performAction: ((LOV_Model?) -> Void) = { [weak self] item in
            guard let self else { return }
            self.selectedTypeId = item?.id
            view.lblText.text = item?.lovValue ?? defaultStr
            self.reloadViews()
            //self.setupTypeMenu()
            if let value = item?.lovValue {
                self.get_lovSITE_CHECK_SUB_TYPE(filter1: value)
            }
            self.reloadSubTypeMenu()
        }
        
        let titleAction = UIAction(title: defaultStr, state: self.selectedTypeId == nil ? .on : .off) { [weak self] action in
            guard self != nil else { return }
            performAction(nil)
        }
        actions.append(titleAction)
        
        for item in self.SITE_CHECK_TYPE_ItemArray {
            let action = UIAction(title: item.lovValue ?? "", state: self.selectedTypeId == item.id ? .on : .off) { [weak self] action in
                guard self != nil else { return }
                performAction(item)
            }
            actions.append(action)
        }
        view.btnDownClick.menu = UIMenu(children: actions)
        view.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func reloadSubTypeMenu() {
        self.subTypeXIB.lblText.text = subTypeStr
        self.selectedSubTypeId = nil
        self.setupSubTypeMenu()
    }
    
    func setupSubTypeMenu() {
        let view: OptionBtnXib = self.subTypeXIB
        let defaultStr = subTypeStr
        var actions: [UIMenuElement] = []
        
        if let selectedTypeId, let selectedType = self.SITE_CHECK_TYPE_ItemArray.first(where: { $0.id == selectedTypeId })?.lovValue, let itemArray = self.SITE_CHECK_SUB_TYPE_ItemDict[selectedType] {
            view.dummyTF.backgroundColor = UIColor.white
            
            let performAction: ((LOV_Model?) -> Void) = { [weak self] item in
                guard let self else { return }
                self.selectedSubTypeId = item?.id
                view.lblText.text = item?.lovValue ?? defaultStr
                self.reloadViews()
                //self.setupSubTypeMenu()
            }
            
            let titleAction = UIAction(title: defaultStr, state: self.selectedSubTypeId == nil ? .on : .off) { [weak self] action in
                guard self != nil else { return }
                performAction(nil)
            }
            actions.append(titleAction)
            
            for item in itemArray {
                let action = UIAction(title: item.lovValue ?? "", state: self.selectedSubTypeId == item.id ? .on : .off) { [weak self] action in
                    guard self != nil else { return }
                    performAction(item)
                }
                actions.append(action)
            }
        }else {
            view.dummyTF.backgroundColor = UIColor(appColor: .GrayStatusBG)
        }
        
        view.btnDownClick.menu = UIMenu(children: actions)
        view.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func setupStatusMenu() {
        let view: OptionBtnXib = self.statusXIB
        var actions: [UIMenuElement] = []
        for status in SiteCheckModel.Status.allCases {
            let action = UIAction(title: status.rawValue, state: self.selectedStatus == status ? .on : .off) { [weak self] action in
                guard let self else { return }
                self.selectedStatus = status
                view.lblText.text = status.rawValue
                self.reloadViews()
                //self.setupStatusMenu()
            }
            actions.append(action)
        }
        view.btnDownClick.menu = UIMenu(children: actions)
        view.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func calculateActionMetrics() -> [(label: String, count: Int)] {
        // Initialize counters
        var outstandingActions = 0
        var actionsCompletedPast12Months = 0
        var actionsRaisedPast12Months = 0
        
        let currentDate = Date()
        if let oneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: currentDate) {
            
            // Loop through data to calculate totals
            self.filteredSiteCheckItemArray.forEach { item in
                guard let startDate = item.startDate?.transformToDate(dateFormat: kResponseDateFormat),
                      let dueDate = item.dueDate?.transformToDate(dateFormat: kResponseDateFormat) else { return }
                
                // Calculate outstanding actions
                if item.status == .open {
                    outstandingActions += 1
                }
                
                // Calculate actions completed in the past 12 months
                if item.status == .done, dueDate >= oneYearAgo, dueDate <= currentDate {
                    actionsCompletedPast12Months += 1
                }
                
                // Calculate actions raised in the past 12 months
                if startDate >= oneYearAgo, startDate <= currentDate {
                    actionsRaisedPast12Months += 1
                }
            }
        }
        
        return [
            (label: "Outstanding Actions", count: outstandingActions),
            (label: "Completed in Past 12 Months", count: actionsCompletedPast12Months),
            (label: "Raised in Past 12 Months", count: actionsRaisedPast12Months),
        ]
    }
    
    func setupRiskScoreboardChart() {
        let itemArray = calculateActionMetrics()
        
        let view: UIView! = self.RiskScoreboardChartContainerView
        view.stopSkeleton()
        view.subviews.filter { $0 is HIChartView }.forEach { $0.removeFromSuperview() }
        
        self.RiskScoreboardChartContainerViewWidth.constant = max(screenWidth-10-10, (CGFloat(itemArray.count)*20)+50)
        view.frame.size.width = self.RiskScoreboardChartContainerViewWidth.constant
        
        let chartView = HIChartView(frame: view.bounds)
        chartView.addCorner(value: 12)
        chartView.addBorder(width: 1, color: UIColor(appColor: .Separator2))
        chartView.backgroundColor = UIColor.clear
        
        let chart = HIChart()
        chart.type = "column"
        
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
        
        let tooltip = HITooltip()
        tooltip.headerFormat = ""
        tooltip.pointFormat = "{point.name}: <b>{point.y}</b>"
        options.tooltip = tooltip
        
        let legends = HILegend()
        legends.itemStyle = HICSSObject()
        legends.itemStyle.fontSize = isiPadDevice ? "17" : "15"
        options.legend = legends
        
        let xAxis = HIXAxis()
        xAxis.type = "category"
        xAxis.labels = HILabels()
        xAxis.labels.rotation = -45
        options.xAxis = [xAxis]
        
        let yAxis = HIYAxis()
        yAxis.min = 0
        yAxis.title = HITitle()
        yAxis.title.text = ""
        options.yAxis = [yAxis]
        
        let plotOptions = HIPlotOptions()
        plotOptions.column = HIColumn()
        plotOptions.column.allowPointSelect = true
        plotOptions.column.cursor = "pointer"
        
        let dataLabels = HIDataLabels()
        dataLabels.enabled = false
        plotOptions.column.dataLabels = [dataLabels]
        plotOptions.column.showInLegend = true
        options.plotOptions = plotOptions
        
        let column = HIColumn()
        column.name = "Actions"
        column.color = HIColor(uiColor: UIColor(hexString: "#FF6384CC")) //"#4BC0C0CC" //"#36A2EBCC"
        column.data = itemArray.compactMap({ [$0.label, $0.count] }) as [Any]
        options.series = [column]
        
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
    
    func prepareSiteChecksChartData() -> [(label: String, data: [String: Int])] {
        var monthlyCounts: [(label: String, data: [String: Int])] = []
        let monthYearDateFormat = "yyyy-MM"
        
        self.filteredSiteCheckItemArray.forEach { item in
            let type = item.type ?? ""
            let monthYear = item.startDate?.transformToNewDateString(dateFormat: kResponseDateFormat, newDateFormat: monthYearDateFormat) ?? ""
            if let index = monthlyCounts.firstIndex(where: { $0.label == monthYear }) {
                if monthlyCounts[index].data[type] == nil {
                    monthlyCounts[index].data[type] = 0
                }
                monthlyCounts[index].data[type]! += 1
            }else {
                monthlyCounts.append((label: monthYear, data: [type : 1]))
            }
        }
        
        return monthlyCounts
    }
    
    func setupSiteChecksChart() {
        let itemArray = self.prepareSiteChecksChartData()
        
        let AuditCounts = itemArray.compactMap { $0.data["Audit"] }
        let SurveyCounts = itemArray.compactMap { $0.data["Survey"] }
        let AssessmentCounts = itemArray.compactMap { $0.data["Assessment"] }
        let InspectionCounts = itemArray.compactMap { $0.data["Inspection"] }
        
        let view: UIView! = self.SiteChecksChartContainerView
        view.stopSkeleton()
        view.subviews.filter { $0 is HIChartView }.forEach { $0.removeFromSuperview() }
        
        self.SiteChecksChartContainerViewWidth.constant = max(screenWidth-10-10, (CGFloat(itemArray.count)*20)+50)
        view.frame.size.width = self.SiteChecksChartContainerViewWidth.constant
        
        let chartView = HIChartView(frame: view.bounds)
        chartView.addCorner(value: 12)
        chartView.addBorder(width: 1, color: UIColor(appColor: .Separator2))
        chartView.backgroundColor = UIColor.clear
        
        let chart = HIChart()
        chart.type = "column"
        
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
        xAxis.categories = itemArray.compactMap({ $0.label })
        xAxis.labels = HILabels()
        xAxis.labels.rotation = -45
        options.xAxis = [xAxis]
        
        let yAxis = HIYAxis()
        yAxis.min = 0
        yAxis.title = HITitle()
        yAxis.title.text = ""
        options.yAxis = [yAxis]
        
        let plotOptions = HIPlotOptions()
        plotOptions.series = HISeries()
        plotOptions.series.stacking = "normal"
        
        let dataLabels = HIDataLabels()
        dataLabels.enabled = false
        plotOptions.series.dataLabels = [dataLabels]
        plotOptions.series.showInLegend = true
        options.plotOptions = plotOptions
        
        let column1 = HIColumn()
        column1.name = "Audit"
        column1.color = HIColor(uiColor: UIColor(hexString: "#FF6384CC"))
        column1.data = AuditCounts as [Any]
        
        let column2 = HIColumn()
        column2.name = "Survey"
        column2.color = HIColor(uiColor: UIColor(hexString: "#36A2EBCC"))
        column2.data = SurveyCounts as [Any]
        
        let column3 = HIColumn()
        column3.name = "Assessment"
        column3.color = HIColor(uiColor: UIColor(hexString: "#FFCE56CC"))
        column3.data = AssessmentCounts as [Any]
        
        let column4 = HIColumn()
        column4.name = "Inspection"
        column4.color = HIColor(uiColor: UIColor(hexString: "#4BC0C0CC"))
        column4.data = InspectionCounts as [Any]
        
        options.series = [column1, column2, column3, column4]
        
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
    
    func prepareActionLogChartData() -> [(label: String, data: [SiteCheckModel.Status: Int])] {
        var userStatusCount: [(id: String, data: [SiteCheckModel.Status: Int])] = []
        self.filteredSiteCheckItemArray.forEach { item in
            let leadUserId: String = item.leadUserID ?? ""
            let assistantUserId: String = item.assistantUserID ?? ""
            let status: SiteCheckModel.Status = item.status ?? .default
            
            [leadUserId, assistantUserId].forEach { userId in
                if let index = userStatusCount.firstIndex(where: { $0.id == userId }) {
                    if userStatusCount[index].data[status] == nil {
                        userStatusCount[index].data[status] = 0
                    }
                    userStatusCount[index].data[status]! += 1
                }else {
                    userStatusCount.append((id: userId, data: [status : 1]))
                }
            }
        }
        
        return userStatusCount.compactMap { (id, data) in
            if let user = self.userBySiteIdItemArray.first(where: { $0.id == id.intValue })?.name {
                return (label: user, data: data)
            }
            return nil
        }
    }
    
    func setupActionLogChart() {
        let itemArray = self.prepareActionLogChartData()
        
        let openCounts = itemArray.compactMap { $0.data[.open] }
        let doneCounts = itemArray.compactMap { $0.data[.done] }
        
        let view: UIView! = self.ActionLogChartContainerView
        view.stopSkeleton()
        view.subviews.filter { $0 is HIChartView }.forEach { $0.removeFromSuperview() }
        
        self.ActionLogChartContainerViewWidth.constant = max(screenWidth-10-10, (CGFloat(itemArray.count)*20)+50)
        view.frame.size.width = self.ActionLogChartContainerViewWidth.constant
        
        let chartView = HIChartView(frame: view.bounds)
        chartView.addCorner(value: 12)
        chartView.addBorder(width: 1, color: UIColor(appColor: .Separator2))
        chartView.backgroundColor = UIColor.clear
        
        let chart = HIChart()
        chart.type = "column"
        
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
        xAxis.categories = itemArray.compactMap({ $0.label })
        xAxis.labels = HILabels()
        xAxis.labels.rotation = -45
        options.xAxis = [xAxis]
        
        let yAxis = HIYAxis()
        yAxis.min = 0
        yAxis.title = HITitle()
        yAxis.title.text = ""
        options.yAxis = [yAxis]
        
        let plotOptions = HIPlotOptions()
        plotOptions.series = HISeries()
        plotOptions.series.stacking = "normal"
        
        let dataLabels = HIDataLabels()
        dataLabels.enabled = false
        plotOptions.series.dataLabels = [dataLabels]
        plotOptions.series.showInLegend = true
        options.plotOptions = plotOptions
        
        let column1 = HIColumn()
        column1.name = SiteCheckModel.Status.open.rawValue
        column1.color = HIColor(uiColor: UIColor(hexString: "#FF6384CC"))
        column1.data = openCounts as [Any]
        
        let column2 = HIColumn()
        column2.name = SiteCheckModel.Status.done.rawValue
        column2.color = HIColor(uiColor: UIColor(hexString: "#4BC0C0CC"))
        column2.data = doneCounts as [Any]
        
        options.series = [column1, column2]
        
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
