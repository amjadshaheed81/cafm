//
//  DashboardVC.swift
//  cafm
//
//  Created by NS on 17/08/24.
//
//

import UIKit
import Highcharts
import SpreadsheetView
import SkeletonView
import SCLAlertView

class DashboardVC: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var emptyView: EmptyView!
    
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var allSiteSwitchLbl: UILabel!
    @IBOutlet weak var siteSelectionSwitch: UISwitch!
    @IBOutlet weak var selectedSiteSwitchLbl: UILabel!
    @IBOutlet weak var siteImageView: UIImageView!
    @IBOutlet weak var siteNameLbl: UILabel!
    
    @IBOutlet weak var riskScorecardView: UIView!
    @IBOutlet weak var riskScorecardChartContainerView: UIView!
    
    @IBOutlet weak var activeProjectsView: DashboardTableView!
    @IBOutlet weak var activeProjectsViewHeight: NSLayoutConstraint!
    @IBOutlet weak var actionsView: DashboardTableView!
    @IBOutlet weak var actionsViewHeight: NSLayoutConstraint!
    @IBOutlet weak var notificationsView: DashboardTableView!
    @IBOutlet weak var notificationsViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tendersAndQuotesView: DashboardTableView!
    @IBOutlet weak var tendersAndQuotesViewHeight: NSLayoutConstraint!
    
    weak var homeVC: HomeVC?
    
    let loadingSCLAlertView = SCLAlertView(appearance: loadingSCLAppearance)
    let userRole: UserEnum = UserDefaults.standard.userRole
    
    var selectedSite: SiteModel? {
        didSet {
            UserConstants.shared.selectedSiteID = self.selectedSite?.siteId
            self.siteNameLbl.text = selectedSite?.siteName
            self.setupFromSiteID()
        }
    }
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emptyView.delegate = self
        self.loadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.riskScorecardChartContainerView.layoutSkeletonIfNeeded()
    }
    
    func loadData() {
        self.getAllSites()
    }
    
    func getAllSites() {
        let apiService = ApiService.siteAllDetails
        
        self.loadingStatus = .loading
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<SiteModel>, Error>) in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single:
                    strongSelf.loadingStatus = .failed
                    break
                case .array(let array):
                    strongSelf.getUserDetails(sites: array)
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                strongSelf.loadingStatus = .failed
            }
        }
    }
    
    func getUserDetails(sites: [SiteModel]) {
        guard let userID = UserConstants.shared.currentUserID else {
            self.loadingStatus = .failed
            return
        }
        let apiService = ApiService.userDetailsAPI(userId: userID)
        
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<UserModel>, Error>) in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single(let response):
                    strongSelf.loadingStatus = .default
                    UserConstants.shared.userDetail = response
                    strongSelf.userNameLbl.text = response.name
                    
                    UserConstants.shared.setAllSites(from: sites)
                    if let id = UserConstants.shared.selectedSiteID ?? response.taggedSites?.first?.id {
                        strongSelf.selectedSite = UserConstants.shared.allSites.first(where: { $0.siteId == id })
                    }
                    break
                case .array:
                    strongSelf.loadingStatus = .failed
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                strongSelf.loadingStatus = .failed
            }
        }
    }
    
    func setupFromSiteID() {
        self.setupRiskScorecardView()
        self.setupActiveProjectsView()
        self.setupActionsView()
        self.setupNotificationsView()
        self.setupTendersAndQuotesView()
    }
    
    func setupRiskScorecardView() {
        let view: UIView! = self.riskScorecardChartContainerView
        guard let siteID = UserConstants.shared.selectedSiteID else {
            return
        }
        let apiService = ApiService.siteCheckSiteAPI(siteId: siteID)
        
        view.isSkeletonable = true
        let animation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .topLeftBottomRight)
        view.showAnimatedGradientSkeleton(usingGradient: SkeletonGradient(baseColor: UIColor.clouds, secondaryColor: UIColor.silver), animation: animation)
        
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<SiteCheckModel>, Error>) in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single:
                    break
                case .array(let array):
                    view.hideSkeleton()
                    view.isSkeletonable = false
                    strongSelf.setupRiskScorecardChart(array)
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
            }
        }
    }
    
    func setupRiskScorecardChart(_ array: [SiteCheckModel]) {
        let view: UIView! = self.riskScorecardChartContainerView
        view.subviews.filter { $0 is HIChartView }.forEach { $0.removeFromSuperview() }
        
        let redScore = array.compactMap { $0.riskScoreRed }.reduce(0, +)
        let amberScore = array.compactMap { $0.riskScoreAmber }.reduce(0, +)
        let yellowScore = array.compactMap { $0.riskScoreYellow }.reduce(0, +)
        let greenScore = array.compactMap { $0.riskScoreGreen }.reduce(0, +)
        
        let chartView = HIChartView(frame: view.bounds)
        chartView.addCorner(value: 12)
        chartView.addBorder(width: 1, color: UIColor(appColor: .Separator2))
        chartView.backgroundColor = UIColor.clear
        //chartView.plugins = ["variable-pie"]
        
        let options = HIOptions()
        
        let credit = HICredits()
        credit.enabled = false
        options.credits = credit
        
        let export = HIExporting()
        export.enabled = false
        options.exporting = export
        
        let chart = HIChart()
        chart.type = "pie"
        
        let title = HITitle()
        title.text = ""
        options.title = title
        
        let tooltip = HITooltip()
        tooltip.headerFormat = ""
        tooltip.pointFormat = "{point.name}: <b>{point.y}</b>"
        options.tooltip = tooltip
        
        let plotOptions = HIPlotOptions()
        plotOptions.pie = HIPie()
        plotOptions.pie.allowPointSelect = true
        plotOptions.pie.cursor = "pointer"
        
        let dataLabels = HIDataLabels()
        dataLabels.enabled = false
        plotOptions.pie.dataLabels = [dataLabels]
        plotOptions.pie.showInLegend = false
        options.plotOptions = plotOptions
        
        let pie = HIPie()
        pie.borderWidth = 0
        pie.innerSize = "40%"
        
        let borderRadius = HIBorderRadiusOptionsObject()
        borderRadius.radius = 0
        pie.borderRadius = borderRadius
        
        let red = HIData()
        red.name = "Red"
        red.y = NSNumber(integerLiteral: redScore)
        red.color = HIColor(uiColor: UIColor(appColor: .RedRiskScore))
        
        let amber = HIData()
        amber.name = "Amber"
        amber.y = NSNumber(integerLiteral: amberScore)
        amber.color = HIColor(uiColor: UIColor(appColor: .AmberStatus))
        
        let yellow = HIData()
        yellow.name = "Yellow"
        yellow.y = NSNumber(integerLiteral: yellowScore)
        yellow.color = HIColor(uiColor: UIColor(appColor: .YellowRiskScore))
        
        let green = HIData()
        green.name = "Green"
        green.y = NSNumber(integerLiteral: greenScore)
        green.color = HIColor(uiColor: UIColor(appColor: .GreenRiskScore))
        
        pie.data = [red, amber, yellow, green]
        
        options.series = [pie]
        
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
    
    func setupActiveProjectsView() {
        let view: DashboardTableView! = self.activeProjectsView
        view.delegate = self
        view.title = "Active Projects"
        
        guard let siteID = UserConstants.shared.selectedSiteID else {
            view.loadingStatus = .failed
            return
        }
        
        let apiService = ApiService.projectContractsAPI(siteId: siteID)
        
        // loading with empty data
        view.tableData = [
            DashboardTableData(columnHeaderText: "Project".uppercased(), columnData: []),
            DashboardTableData(columnHeaderText: "Start Date".uppercased(), columnData: []),
            DashboardTableData(columnHeaderText: "End Date".uppercased(), columnData: []),
            DashboardTableData(columnHeaderText: "Budget".uppercased(), columnData: []),
        ]
        view.loadingStatus = .loading
        view.reloadSpreadsheetView()
        
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<ProjectContractsResponse>, Error>) in
            guard self != nil else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single(let response):
                    if let projectContracts = response.projectContracts {
                        view.tableData = [
                            DashboardTableData(columnHeaderText: "Project".uppercased(), columnData: projectContracts.compactMap({ $0.summary }).compactMap({ DashboardTableData.ColumnData(text: $0) })),
                            DashboardTableData(columnHeaderText: "Start Date".uppercased(), columnData: projectContracts.compactMap({ $0.startDate?.transformToNewDateString(dateFormat: "yyyy-MM-dd'T'HH:mm:ss", newDateFormat: "dd MMM yy") }).compactMap({ DashboardTableData.ColumnData(text: $0) })),
                            DashboardTableData(columnHeaderText: "End Date".uppercased(), columnData: projectContracts.compactMap({ $0.endDate?.transformToNewDateString(dateFormat: "yyyy-MM-dd'T'HH:mm:ss", newDateFormat: "dd MMM yy") }).compactMap({ DashboardTableData.ColumnData(text: $0) })),
                            DashboardTableData(columnHeaderText: "Budget".uppercased(), columnData: projectContracts.compactMap({ $0.cost }).compactMap({ "€ \($0)" }).compactMap({ DashboardTableData.ColumnData(text: $0) })),
                        ]
                        if !view.tableData.isEmpty, view.tableData.max(by: { $0.columnData.count < $1.columnData.count })?.columnData.isEmpty ?? true {
                            view.loadingStatus = .noResponse
                        }else {
                            view.loadingStatus = .default
                        }
                    }else {
                        view.loadingStatus = .failed
                    }
                case .array:
                    view.loadingStatus = .failed
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                view.loadingStatus = .failed
            }
            view.reloadSpreadsheetView()
        }
    }
    
    func setupActionsView() {
        let view: DashboardTableView! = self.actionsView
        view.delegate = self
        view.title = "Actions"
        
        guard let siteID = UserConstants.shared.selectedSiteID else {
            view.loadingStatus = .failed
            return
        }
        
        let apiService = ApiService.siteActionsAPI(siteId: siteID)
        
        // loading with empty data
        view.tableData = [
            DashboardTableData(columnHeaderText: "Type".uppercased(), columnData: []),
            DashboardTableData(columnHeaderText: "Action".uppercased(), columnData: []),
            DashboardTableData(columnHeaderText: "Status".uppercased(), columnData: []),
        ]
        view.loadingStatus = .loading
        view.reloadSpreadsheetView()
        
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<ActionModel>, Error>) in
            guard self != nil else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single:
                    view.loadingStatus = .failed
                    break
                case .array(let array):
                    view.tableData = [
                        DashboardTableData(columnHeaderText: "Type".uppercased(), columnData: array.compactMap({ $0.type }).compactMap({ DashboardTableData.ColumnData(text: $0) })),
                        DashboardTableData(columnHeaderText: "Action".uppercased(), columnData: array.compactMap({ $0.desc }).compactMap({ DashboardTableData.ColumnData(text: $0) })),
                        DashboardTableData(columnHeaderText: "Status".uppercased(), isStatusData: true, columnData: array.compactMap({ $0.status }).compactMap({ DashboardTableData.ColumnData(text: "  \($0.rawValue)  ", textColor: $0.textColor(), textBGColor: $0.textBGColor()) })),
                    ]
                    if !view.tableData.isEmpty, view.tableData.max(by: { $0.columnData.count < $1.columnData.count })?.columnData.isEmpty ?? true {
                        view.loadingStatus = .noResponse
                    }else {
                        view.loadingStatus = .default
                    }
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                view.loadingStatus = .failed
            }
            view.reloadSpreadsheetView()
        }
    }
    
    func setupNotificationsView() {
        let view: DashboardTableView! = self.notificationsView
        view.delegate = self
        view.title = "Notifications"
        
        guard let siteID = UserConstants.shared.selectedSiteID else {
            view.loadingStatus = .failed
            return
        }
        
        // loading with empty data
        view.tableData = [
            DashboardTableData(columnHeaderText: "Notification".uppercased(), columnData: []),
            DashboardTableData(columnHeaderText: "Date".uppercased(), columnData: []),
        ]
        view.loadingStatus = .loading
        view.reloadSpreadsheetView()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2.0) { [weak self] in
            guard let strongSelf = self else { return }
            view.tableData = [
                DashboardTableData(columnHeaderText: "Notification".uppercased(), columnData: []),
                DashboardTableData(columnHeaderText: "Date".uppercased(), columnData: []),
            ]
            if !view.tableData.isEmpty, view.tableData.max(by: { $0.columnData.count < $1.columnData.count })?.columnData.isEmpty ?? true {
                view.loadingStatus = .noResponse
            }else {
                view.loadingStatus = .default
            }
            view.reloadSpreadsheetView()
        }
    }
    
    func setupTendersAndQuotesView() {
        let view: DashboardTableView! = self.tendersAndQuotesView
        view.delegate = self
        view.title = "Tenders & Quotes"
        
        guard let siteID = UserConstants.shared.selectedSiteID else {
            view.loadingStatus = .failed
            return
        }
        
        // loading with empty data
        view.tableData = [
            DashboardTableData(columnHeaderText: "Tender ID".uppercased(), columnData: []),
            DashboardTableData(columnHeaderText: "# of Quotes".uppercased(), columnData: []),
            DashboardTableData(columnHeaderText: "End Date".uppercased(), columnData: []),
            DashboardTableData(columnHeaderText: "Status".uppercased(), columnData: []),
        ]
        view.loadingStatus = .loading
        view.reloadSpreadsheetView()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2.0) { [weak self] in
            guard let strongSelf = self else { return }
            view.tableData = [
                DashboardTableData(columnHeaderText: "Tender ID".uppercased(), columnData: []),
                DashboardTableData(columnHeaderText: "# of Quotes".uppercased(), columnData: []),
                DashboardTableData(columnHeaderText: "End Date".uppercased(), columnData: []),
                DashboardTableData(columnHeaderText: "Status".uppercased(), columnData: []),
            ]
            if !view.tableData.isEmpty, view.tableData.max(by: { $0.columnData.count < $1.columnData.count })?.columnData.isEmpty ?? true {
                view.loadingStatus = .noResponse
            }else {
                view.loadingStatus = .default
            }
            view.reloadSpreadsheetView()
        }
    }
    
    @IBAction func siteViewClicked(_ sender: UIView) {
        let vc = generalSB.instantiateViewController(withIdentifier: "SiteSearchVC") as! SiteSearchVC
        vc.delegate = self
        self.homeVC?.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func siteSelectionSwitchValueChanged(_ sender: UISwitch) {
        
    }
    
}

extension DashboardVC: EmptyViewDelegate {
    func emptyViewDidTapView(_ view: EmptyView) {
        if self.loadingStatus.shouldReload {
            self.loadData()
        }
    }
}

extension DashboardVC: DashboardTableViewDelegate {
    
    func dashboardTableViewHeightDidChange(_ view: DashboardTableView, height: CGFloat) {
        switch view {
        case self.activeProjectsView:
            self.activeProjectsViewHeight.constant = height
            self.activeProjectsView.frame.size.height = height
            break
        case self.actionsView:
            self.actionsViewHeight.constant = height
            self.actionsView.frame.size.height = height
            break
        case self.notificationsView:
            self.notificationsViewHeight.constant = height
            self.notificationsView.frame.size.height = height
            break
        case self.tendersAndQuotesView:
            self.tendersAndQuotesViewHeight.constant = height
            self.tendersAndQuotesView.frame.size.height = height
            break
        default:
            break
        }
    }
    
    func dashboardTableViewDidTapForRetry(_ view: DashboardTableView, status: LoadingStatus) {
        switch status {
        case .default, .loading, .noResponse:
            break
        case .failed, .noInternet:
            switch view {
            case self.activeProjectsView:
                self.setupActiveProjectsView()
                break
            case self.actionsView:
                self.setupActionsView()
                break
            case self.notificationsView:
                self.setupNotificationsView()
                break
            case self.tendersAndQuotesView:
                self.setupTendersAndQuotesView()
                break
            default:
                break
            }
            break
        }
    }
    
    func dashboardTableViewViewAllBtnClicked(_ view: DashboardTableView, sender: SecondaryButton) {
        switch view {
        case self.activeProjectsView:
            view.isViewAll = true
            view.reloadSpreadsheetView()
            break
        case self.actionsView:
            let vc = generalSB.instantiateViewController(withIdentifier: "ActionsVC") as! ActionsVC
            self.homeVC?.navigationController?.pushViewController(vc, animated: true)
            break
        case self.notificationsView:
            view.isViewAll = true
            view.reloadSpreadsheetView()
            break
        case self.tendersAndQuotesView:
            view.isViewAll = true
            view.reloadSpreadsheetView()
            break
        default:
            break
        }
    }
    
}

extension DashboardVC: SiteSearchDelegate {
    
    func siteSearchDidSelectSite(_ site: SiteModel) {
        self.selectedSite = site
    }
}
