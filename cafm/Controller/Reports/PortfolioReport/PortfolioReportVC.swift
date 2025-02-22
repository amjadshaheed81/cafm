//
//  PortfolioReportVC.swift
//  cafm
//
//  Created by NS on 26/10/24.
//
//

import UIKit
import SCLAlertView
import SkeletonView
import Highcharts

class PortfolioReportVC: UIViewController {
    
    @IBOutlet weak var emptyView: EmptyView!
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var SitesByStatusTitleXIB: TitleBadgeView!
    @IBOutlet weak var SitesByStatusChartContainerView: DesignableView!
    
    @IBOutlet weak var areaXIB: OptionBtnXib!
    @IBOutlet weak var siteSwitch: DefaultSwitch!
    @IBOutlet weak var siteSwitchLbl: DefaultFontLabel!
    @IBOutlet weak var StaffPerActiveSiteTitleXIB: TitleBadgeView!
    @IBOutlet weak var StaffPerActiveSiteChartScrollView: UIScrollView!
    @IBOutlet weak var StaffPerActiveSiteChartScrollViewHeight: NSLayoutConstraint!
    @IBOutlet weak var StaffPerActiveSiteChartContainerView: DesignableView!
    @IBOutlet weak var StaffPerActiveSiteChartContainerViewWidth: NSLayoutConstraint!
    
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
    
    private var siteItemArray: [CreateSiteRequestModel] = []
    private var userItemArray: [User] = []
    private var riskScoresItemDict: [String: RiskScore] = [:]
    
    private var selectedArea: String?
    private var allSites: Bool = true
    private var viewShouldLayoutSubviews: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emptyView.delegate = self
        self.setupViews()
        self.loadData()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.viewShouldLayoutSubviews = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if self.viewShouldLayoutSubviews {
            self.setupSitesByStatusChart()
            self.setupStaffPerActiveSiteChart()
            self.viewShouldLayoutSubviews.toggle()
        }
    }
    
    @IBAction func portfolioBtnClicked(_ sender: UIButton) {
        let vc = reportsSB.instantiateViewController(identifier: "PortfolioReportTableVC") as! PortfolioReportTableVC
        vc.siteItemArray = self.siteItemArray
        let nav = UINavigationController(rootViewController: vc)
        self.present(nav, animated: true)
    }
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        switch sender {
        case self.siteSwitch:
            self.reloadStaffPerActiveSiteChart()
            break
        default:
            break
        }
    }
    
}

//MARK: - Fields enum
extension PortfolioReportVC {
    enum Fields: String, CaseIterable {
        case SitesByStatus = "Sites By Status"
        case StaffPerActiveSite = "Users Per Active Site"
        
        func badgeTitle(with value: Int) -> String {
            switch self {
            case .SitesByStatus: return "Total Sites: \(value)"
            case .StaffPerActiveSite: return "Total Users: \(value)"
            }
        }
    }
}

//MARK: - EmptyViewDelegate
extension PortfolioReportVC: EmptyViewDelegate {
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
extension PortfolioReportVC {
    
    func loadData() {
        self.getAllSites()
    }
    
    func getAllSites() {
        let view: UIView! = self.SitesByStatusChartContainerView
        view.isSkeletonable = true
        let animation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .topLeftBottomRight)
        view.showAnimatedGradientSkeleton(usingGradient: SkeletonGradient(baseColor: UIColor.clouds, secondaryColor: UIColor.silver), animation: animation)
        
        self.loadingStatus = .loading
        let apiService = ApiService.siteAllDetails(sort: "asc", sortName: "siteName")
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<CreateSiteRequestModel>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single:
                    self.loadingStatus = .failed
                    break
                case .array(let array):
                    self.siteItemArray = array
                    self.setupSitesByStatusChart()
                    self.getAllUsers()
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                self.loadingStatus = .failed
            }
        }
    }
    
    func getAllUsers() {
        let view: UIView! = self.StaffPerActiveSiteChartContainerView
        view.isSkeletonable = true
        let animation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .topLeftBottomRight)
        view.showAnimatedGradientSkeleton(usingGradient: SkeletonGradient(baseColor: UIColor.clouds, secondaryColor: UIColor.silver), animation: animation)
        
        self.loadingStatus = .loading
        let apiService = ApiService.getAllUserData
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<UsersList>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single(let single):
                    self.userItemArray = (single.users ?? [])//.sorted(by: { $0.name ?? "" < $1.name ?? "" })
                    self.reloadStaffPerActiveSiteChart()
                    self.getSiteCheckRisks()
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
    
    func getSiteCheckRisks() {
        self.loadingStatus = .loading
        let apiService = ApiService.siteDetailsRiskData
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<RiskScoreResponse>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single(let single):
                    self.riskScoresItemDict = single.riskScores ?? [:]
                    self.mergeSitesAndRiskScores()
                    self.loadingStatus = .default
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
    
}

//MARK: - setup views
extension PortfolioReportVC {
    
    func setupViews() {
        let view1: TitleBadgeView! = self.SitesByStatusTitleXIB
        let field1 = Fields.SitesByStatus
        view1.titleLbl.text = field1.rawValue
        view1.setBadgeData(text: nil)
        
        let view2: TitleBadgeView! = self.StaffPerActiveSiteTitleXIB
        let field2 = Fields.StaffPerActiveSite
        view2.titleLbl.text = field2.rawValue
        view2.setBadgeData(text: nil)
        
        self.areaXIB.lblText.text = "All Sites"
        self.setupAreaMenu()
        self.siteSwitch.isOn = self.allSites
        self.siteSwitchLbl.text = self.allSites ? "All Sites" : "Individual"
    }
    
    func reloadViews() {
        self.reloadStaffPerActiveSiteChart()
    }
    
    func reloadStaffPerActiveSiteChart() {
        self.setupAreaMenu()
        
        self.allSites = self.siteSwitch.isOn
        self.siteSwitchLbl.text = self.allSites ? "All Sites" : "Individual"
        
        self.setupStaffPerActiveSiteChart()
    }
    
    func setupAreaMenu() {
        let view: OptionBtnXib = self.areaXIB
        let defaultStr = "All Sites"
        
        let allCases: [String] = UserConstants.shared.SiteArea //self.siteItemArray.compactMap({ $0.area ?? "" }).reduce([String](), { $0.contains($1) ? $0 : $0 + [$1] })
        
        let performAction: ((String?) -> Void) = { [weak self] item in
            guard let self else { return }
            self.selectedArea = item
            view.lblText.text = item ?? defaultStr
            self.reloadStaffPerActiveSiteChart()
            //self.setupAreaMenu()
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
    
    func mergeSitesAndRiskScores() {
        for site in self.siteItemArray {
            if let siteId = site.siteId, let riskScore = self.riskScoresItemDict["\(siteId)"] {
                site.riskScoreModel = riskScore
            }
        }
    }
    
    func setupStaffPerActiveSiteChart() {
        let data = getUniqueSitesWithUserCount(
            users: self.userItemArray,
            sites: self.siteItemArray,
            area: self.selectedArea,
            allSites: self.allSites
        )
        
        self.StaffPerActiveSiteChartContainerViewWidth.constant = max(self.view.frame.width-10-10, (CGFloat(data.count)*20)+50)
        self.StaffPerActiveSiteChartContainerView.frame.size.width = StaffPerActiveSiteChartContainerViewWidth.constant
        
        let view2: TitleBadgeView! = self.StaffPerActiveSiteTitleXIB
        let field2 = Fields.StaffPerActiveSite
        view2.setBadgeData(
            text: field2.badgeTitle(with: self.allSites ? self.userItemArray.count : data.first?.totalUsers ?? 0),
            font: UIFont(name: .MontserratSemiBold, size: dashboardPrimaryTextSize+1),
            maxWidth: view2.bounds.width/3,
            roundedCorner: false
        )
        
        let view: UIView! = self.StaffPerActiveSiteChartContainerView
        view.hideSkeleton()
        view.isSkeletonable = false
        view.subviews.filter { $0 is HIChartView }.forEach { $0.removeFromSuperview() }
        
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
        tooltip.pointFormat = "<b>{point.name}</b><br/> <span style=\"color:{point.color}\">\u{25CF}</span> Number of Users: {point.y}"
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
        column.name = "Number of Users"
        column.color = HIColor(uiColor: UIColor(hexString: "#3c50e0"))
        column.data = data.compactMap({ [$0.siteName, $0.totalUsers] }) as [Any]
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
    
    func setupSitesByStatusChart() {
        let openSites = self.siteItemArray.filter({ $0.status?.lowercased() == "open" }).count
        let soldSites = self.siteItemArray.filter({ $0.status?.lowercased() == "sold" }).count
        let closedSites = self.siteItemArray.filter({ $0.status?.lowercased() == "closed" }).count
        let totalSites = openSites+soldSites+closedSites
        
        let view: UIView! = self.SitesByStatusChartContainerView
        view.hideSkeleton()
        view.isSkeletonable = false
        view.subviews.filter { $0 is HIChartView }.forEach { $0.removeFromSuperview() }
        
        var itemArray: [(label: String, data: Int, color: UIColor)] = []
        itemArray.append((label: "Open", data: openSites, color: UIColor(hexString: "#1E3A8A")))
        itemArray.append((label: "Closed", data: closedSites, color: UIColor(hexString: "#2563EB")))
        itemArray.append((label: "Sold", data: soldSites, color: UIColor(hexString: "#60A5FA")))
        
        let chartView = HIChartView(frame: view.bounds)
        chartView.addCorner(value: 12)
        chartView.addBorder(width: 1, color: UIColor(appColor: .Separator2))
        chartView.backgroundColor = UIColor.clear
        
        let chart = HIChart()
        chart.type = "pie"
        
        let options = HIOptions()
        
        let credit = HICredits()
        credit.enabled = false
        options.credits = credit
        
        let export = HIExporting()
        export.enabled = false
        options.exporting = export
        
        let title = HITitle()
        title.text = "\(totalSites) Total Sites"
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
        
        //let dataLabels = HIDataLabels()
        //dataLabels.enabled = false
        //plotOptions.pie.dataLabels = [dataLabels]
        plotOptions.pie.showInLegend = true
        options.plotOptions = plotOptions
        
        let pie = HIPie()
        pie.borderWidth = 0
        //pie.innerSize = "0%"
        
        let borderRadius = HIBorderRadiusOptionsObject()
        borderRadius.radius = 0
        pie.borderRadius = borderRadius
        
        var chartData: [HIData] = []
        for item in itemArray {
            let data = HIData()
            data.name = item.label
            data.y = NSNumber(integerLiteral: item.data)
            data.color = HIColor(uiColor: item.color)
            chartData.append(data)
        }
        pie.data = chartData
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
    
}
