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
    @IBOutlet weak var siteImageViewWidth: NSLayoutConstraint!
    @IBOutlet weak var siteImageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var siteNameLbl: UILabel!
    
    @IBOutlet weak var riskScorecardTitleLbl: DefaultFontLabel!
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
    
    var selectedSite: CreateSiteRequestModel? {
        didSet {
            UserConstants.shared.selectedSiteID = self.selectedSite?.siteId
            self.siteNameLbl.text = selectedSite?.siteName
            if let siteImageUrl = selectedSite?.siteImageUrl {
                self.siteImageView.sd_setImage(with: URL(string: siteImageUrl), placeholderImage: UIImage(systemName: "person.circle.fill")) { [weak self] image, error, cache, url in
                    guard let self else { return }
                    if let image {
                        let size = image.size
                        let maxHeight: CGFloat = 52
                        let maxWidth: CGFloat = 52
                        
                        var imageHeight: CGFloat = maxHeight
                        var imageWidth: CGFloat = maxWidth
                        if size.height > size.width {
                            imageHeight = maxHeight
                            imageWidth = size.width*(imageHeight/size.height)
                            self.siteImageView.addCorner(value: imageWidth/2)
                        }else {
                            imageHeight = maxHeight
                            imageWidth = size.width*(imageHeight/size.height)
                            if imageWidth > maxWidth {
                                imageWidth = maxWidth
                                imageHeight = size.height*(imageWidth/size.width)
                            }
                            self.siteImageView.addCorner(value: imageHeight/2)
                        }
                        self.siteImageViewWidth.constant = imageWidth
                        self.siteImageViewHeight.constant = imageHeight
                        self.siteImageView.frame.size = CGSize(width: self.siteImageViewWidth.constant, height: self.siteImageViewHeight.constant)
                    }else {
                        self.siteImageViewWidth.constant = 32
                        self.siteImageViewHeight.constant = 32
                        self.siteImageView.frame.size = CGSize(width: self.siteImageViewWidth.constant, height: self.siteImageViewHeight.constant)
                    }
                }
            }else {
                self.siteImageView.image = UIImage(systemName: "person.circle.fill")
                self.siteImageViewWidth.constant = 32
                self.siteImageViewHeight.constant = 32
                self.siteImageView.frame.size = CGSize(width: self.siteImageViewWidth.constant, height: self.siteImageViewHeight.constant)
            }
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
    
    let userConstants = UserConstants.shared
    
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
        let apiService = ApiService.siteAllDetails(sort: "asc", sortName: "siteName")
        
        self.loadingStatus = .loading
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<CreateSiteRequestModel>, Error>) in
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
    
    func getUserDetails(sites: [CreateSiteRequestModel]) {
        guard let userID = UserConstants.shared.currentUserID else {
            self.loadingStatus = .failed
            return
        }
        let apiService = ApiService.userDetailsAPI(userId: userID)
        
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<User>, Error>) in
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
        var titleStr = "Risk Scorecard"
        if let siteName = userConstants.selectedSiteName {
            titleStr += " - \(siteName)"
        }
        self.riskScorecardTitleLbl.text = titleStr
        
        let view: UIView! = self.riskScorecardChartContainerView
        guard let siteID = UserConstants.shared.selectedSiteID else {
            return
        }
        let apiService = ApiService.siteActionsAPI(siteId: siteID)
        
        view.isSkeletonable = true
        let animation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .topLeftBottomRight)
        view.showAnimatedGradientSkeleton(usingGradient: SkeletonGradient(baseColor: UIColor.clouds, secondaryColor: UIColor.silver), animation: animation)
        
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<ActionModel>, Error>) in
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
    
    func setupRiskScorecardChart(_ array: [ActionModel]) {
        let view: UIView! = self.riskScorecardChartContainerView
        view.subviews.filter { $0 is HIChartView }.forEach { $0.removeFromSuperview() }
        
        let siteChecks = array.filter { $0.status != .completed }
        
        let itemArray = siteChecks.compactMap { $0.riskScore ?? 0 }
        let greenScore = itemArray.filter { $0 <= 4 }.count
        let yellowScore = itemArray.filter { $0 > 4 && $0 < 10 }.count
        let amberScore = itemArray.filter { $0 > 9 && $0 < 17 }.count
        let redScore = itemArray.filter { $0 > 16 }.count
        
        let chartView = HIChartView(frame: view.bounds)
        chartView.addCorner(value: 12)
        chartView.addBorder(width: 1, color: UIColor(appColor: .Separator2))
        chartView.backgroundColor = UIColor.clear
        
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
        title.text = "\(greenScore+yellowScore+amberScore+redScore) Action"
        options.title = title
        
        let tooltip = HITooltip()
        tooltip.headerFormat = ""
        tooltip.pointFormat = "{point.name}: <b>{point.y}</b>"
        options.tooltip = tooltip
        
        let legends = HILegend()
        legends.itemStyle = HICSSObject()
        legends.itemStyle.fontSize = isiPadDevice ? "17" : "15"
        options.legend = legends
        
        let plotOptions = HIPlotOptions()
        plotOptions.pie = HIPie()
        plotOptions.pie.allowPointSelect = true
        plotOptions.pie.cursor = "pointer"
        
        let dataLabels = HIDataLabels()
        dataLabels.enabled = false
        plotOptions.pie.dataLabels = [dataLabels]
        plotOptions.pie.showInLegend = true
        options.plotOptions = plotOptions
        
        let pie = HIPie()
        pie.borderWidth = 0
        pie.innerSize = "40%"
        
        let borderRadius = HIBorderRadiusOptionsObject()
        borderRadius.radius = 0
        pie.borderRadius = borderRadius
        
        let red = HIData()
        red.name = "Very High"
        red.y = NSNumber(integerLiteral: redScore)
        red.color = HIColor(uiColor: UIColor(appColor: .RedRiskScore))
        
        let amber = HIData()
        amber.name = "High"
        amber.y = NSNumber(integerLiteral: amberScore)
        amber.color = HIColor(uiColor: UIColor(appColor: .AmberStatus))
        
        let yellow = HIData()
        yellow.name = "Medium"
        yellow.y = NSNumber(integerLiteral: yellowScore)
        yellow.color = HIColor(uiColor: UIColor(appColor: .YellowRiskScore))
        
        let green = HIData()
        green.name = "Low"
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
        var titleStr = "Active Projects"
        if let siteName = userConstants.selectedSiteName {
            titleStr += " - \(siteName)"
        }
        view.title = titleStr
        
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
                        let projectContracts = [ProjectContract](projectContracts.prefix(5))
                        view.tableData = [
                            DashboardTableData(columnHeaderText: "Project".uppercased(), columnData: projectContracts.compactMap({ $0.summary }).compactMap({ DashboardTableData.ColumnData(text: $0) })),
                            DashboardTableData(columnHeaderText: "Start Date".uppercased(), columnData: projectContracts.compactMap({ $0.startDate?.transformToNewDateString(dateFormat: "yyyy-MM-dd'T'HH:mm:ss", newDateFormat: "dd/MM/yyyy") }).compactMap({ DashboardTableData.ColumnData(text: $0) })),
                            DashboardTableData(columnHeaderText: "End Date".uppercased(), columnData: projectContracts.compactMap({ $0.endDate?.transformToNewDateString(dateFormat: "yyyy-MM-dd'T'HH:mm:ss", newDateFormat: "dd/MM/yyyy") }).compactMap({ DashboardTableData.ColumnData(text: $0) })),
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
        var titleStr = "Actions"
        if let siteName = userConstants.selectedSiteName {
            titleStr += " - \(siteName)"
        }
        view.title = titleStr
        
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
                    let array = [ActionModel](array.prefix(5))
                    view.tableData = [
                        DashboardTableData(columnHeaderText: "Type".uppercased(), columnData: array.compactMap({ $0.type }).compactMap({ DashboardTableData.ColumnData(text: $0) })),
                        DashboardTableData(columnHeaderText: "Action".uppercased(), columnData: array.compactMap({ $0.desc }).compactMap({ DashboardTableData.ColumnData(text: $0) })),
                        DashboardTableData(columnHeaderText: "Status".uppercased(), isStatusData: true, columnData: array.compactMap({ $0.status }).compactMap({ DashboardTableData.ColumnData(text: "\($0.rawValue)  ", textColor: $0.textColor(), textBGColor: $0.textBGColor()) })),
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
        var titleStr = "Notifications"
        if let siteName = userConstants.selectedSiteName {
            titleStr += " - \(siteName)"
        }
        view.title = titleStr
        
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
        
        let apiService = ApiService.actionSummaryAPI(siteId: siteID)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<PreActionsResponse>, Error>) in
            guard self != nil else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single(let single):
                    if let array = single.preActions?.filter({ $0.status == "Pending Action" || $0.status == "Closed" }) {
                        let array = [PreAction](array.prefix(5))
                        view.tableData = [
                            DashboardTableData(columnHeaderText: "Notification".uppercased(), columnData: array.compactMap({ $0.description }).compactMap({ DashboardTableData.ColumnData(text: $0) })),
                            DashboardTableData(columnHeaderText: "Date".uppercased(), columnData: array.compactMap({ $0.raisedDate?.transformToNewDateString(dateFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSSSS", newDateFormat: "dd/MM/yyyy") }).compactMap({ DashboardTableData.ColumnData(text: $0) })),
                        ]
                        if !view.tableData.isEmpty, view.tableData.max(by: { $0.columnData.count < $1.columnData.count })?.columnData.isEmpty ?? true {
                            view.loadingStatus = .noResponse
                        }else {
                            view.loadingStatus = .default
                        }
                    }else {
                        view.loadingStatus = .failed
                    }
                    break
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
    
    func setupTendersAndQuotesView() {
        self.tendersAndQuotesViewHeight.constant = 0
        self.tendersAndQuotesView.frame.size.height = self.tendersAndQuotesViewHeight.constant
        self.tendersAndQuotesView.isHidden = true
        
        return
        
        let view: DashboardTableView! = self.tendersAndQuotesView
        view.delegate = self
        var titleStr = "Tenders & Quotes"
        if let siteName = userConstants.selectedSiteName {
            titleStr += " - \(siteName)"
        }
        view.title = titleStr

        guard let siteID = UserConstants.shared.selectedSiteID else {
            view.loadingStatus = .failed
            return
        }
        
        // loading with empty data
        view.tableData = [
            DashboardTableData(columnHeaderText: "Tender ID".uppercased(), columnData: []),
            DashboardTableData(columnHeaderText: "End Date".uppercased(), columnData: []),
            DashboardTableData(columnHeaderText: "Status".uppercased(), columnData: []),
        ]
        view.loadingStatus = .loading
        view.reloadSpreadsheetView()
        
        let apiService = ApiService.projectContractsAPI(siteId: siteID)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<ProjectContractsResponse>, Error>) in
            guard self != nil else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single(let response):
                    if let projectContracts = response.projectContracts {
                        let projectContracts = [ProjectContract](projectContracts.prefix(5))
                        view.tableData = [
                            DashboardTableData(columnHeaderText: "Tender ID".uppercased(), columnData: projectContracts.compactMap({ $0.projectContractId?.stringValue }).compactMap({ DashboardTableData.ColumnData(text: $0) })),
                            DashboardTableData(columnHeaderText: "End Date".uppercased(), columnData: projectContracts.compactMap({ $0.endDate?.transformToNewDateString(dateFormat: "yyyy-MM-dd'T'HH:mm:ss", newDateFormat: "dd/MM/yyyy") }).compactMap({ DashboardTableData.ColumnData(text: $0) })),
                            DashboardTableData(columnHeaderText: "Status".uppercased(), columnData: projectContracts.compactMap({ $0.status }).compactMap({ DashboardTableData.ColumnData(text: $0) })),
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
            //self.tendersAndQuotesViewHeight.constant = height
            //self.tendersAndQuotesView.frame.size.height = height
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
            let vc = siteContractsSB.instantiateViewController(withIdentifier: "SiteContractsVC") as! SiteContractsVC
            self.homeVC?.navigationController?.pushViewController(vc, animated: true)
            break
        case self.actionsView:
            let vc = generalSB.instantiateViewController(withIdentifier: "ActionsVC") as! ActionsVC
            self.homeVC?.navigationController?.pushViewController(vc, animated: true)
            break
        case self.notificationsView:
            //TODO: RK - Open Notification Screen
            let vc = notificationSB.instantiateViewController(withIdentifier: "NotificationListVC") as! NotificationListVC
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case self.tendersAndQuotesView:
            break
        default:
            break
        }
    }
    
}

extension DashboardVC: SiteSearchDelegate {
    
    func siteSearchDidSelectSite(_ site: CreateSiteRequestModel) {
        self.selectedSite = site
    }
}
