//
//  AssetReportVC.swift
//  cafm
//
//  Created by NS on 27/10/24.
//
//

import UIKit
import SCLAlertView
import Highcharts

class AssetReportVC: UIViewController {
    
    @IBOutlet weak var emptyView: EmptyView!
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var areaXIB: OptionBtnXib!
    @IBOutlet weak var siteSwitch: DefaultSwitch!
    @IBOutlet weak var startDateRangeXIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var endDateRangeXIB: OptionBtnWithTitleXIB!
    
    @IBOutlet weak var AssetTypeChartContainerView: DesignableView!
    
    @IBOutlet weak var PATResultChartScrollView: UIScrollView!
    @IBOutlet weak var PATResultChartScrollViewHeight: NSLayoutConstraint!
    @IBOutlet weak var PATResultChartContainerView: DesignableView!
    @IBOutlet weak var PATResultChartContainerViewWidth: NSLayoutConstraint!
    @IBOutlet weak var PATResultChart2ScrollView: UIScrollView!
    @IBOutlet weak var PATResultChart2ScrollViewHeight: NSLayoutConstraint!
    @IBOutlet weak var PATResultChart2ContainerView: DesignableView!
    @IBOutlet weak var PATResultChart2ContainerViewWidth: NSLayoutConstraint!
    @IBOutlet weak var PATResultChart3ScrollView: UIScrollView!
    @IBOutlet weak var PATResultChart3ScrollViewHeight: NSLayoutConstraint!
    @IBOutlet weak var PATResultChart3ContainerView: DesignableView!
    @IBOutlet weak var PATResultChart3ContainerViewWidth: NSLayoutConstraint!
    
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
    
    private var chartData: AssetChartModel?
    
    private var selectedArea: String?
    private var allSites: Bool = true
    private var selectedStartDate: Date?
    private var selectedEndDate: Date?
    
    private let kResponseDateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    private let kRequestDateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'" //"yyyy-MM-dd HH:mm:ss"
    private let ddMMyyyyStr = "dd/MM/yyyy"
    private let yyyyMMddStr = "yyyy-MM-dd"
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
            self.setupAssetTypeChart()
            self.setupPATResultChart()
            self.viewShouldLayoutSubviews.toggle()
        }
    }
    
    @IBAction func assetBtnClicked(_ sender: UIButton) {
        let vc = siteAssetsSB.instantiateViewController(withIdentifier: "AssetRegisterVC") as! AssetRegisterVC
        vc.isFromReports = true
        let nav = UINavigationController(rootViewController: vc)
        self.present(nav, animated: true)
    }
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        switch sender {
        case self.siteSwitch:
            self.allSites = !sender.isOn
            self.getSiteAssetsAllV2Data()
            break
        default:
            break
        }
    }
    
}

//MARK: - Fields enum
extension AssetReportVC {
}

//MARK: - EmptyViewDelegate
extension AssetReportVC: EmptyViewDelegate {
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
extension AssetReportVC {
    
    func loadData() {
        self.getSiteAssetsAllV2Data()
    }
    
    func getSiteAssetsAllV2Data() {
        let view1: UIView! = self.AssetTypeChartContainerView
        view1.startSkeleton()
        
        let view2: UIView! = self.PATResultChartContainerView
        view2.startSkeleton()
        
        let view3: UIView! = self.PATResultChart2ContainerView
        view3.startSkeleton()
        
        let view4: UIView! = self.PATResultChart3ContainerView
        view4.startSkeleton()
        
        self.loadingStatus = .loading
        
        var area: String?
        var fromDate: String?
        var toDate: String?
        var siteId: Int?
        if !self.allSites {
            siteId = UserConstants.shared.selectedSiteID
        }
        if self.allSites, let selectedArea {
            area = try? selectedArea.asURL().absoluteString
        }
        if let selectedStartDate, let selectedEndDate {
            fromDate = selectedStartDate.transformToString(dateFormat: yyyyMMddStr)
            toDate = selectedEndDate.transformToString(dateFormat: yyyyMMddStr)
        }
        let apiService = ApiService.getSiteAssetsAllV2(area: area, fromDate: fromDate, toDate: toDate, siteId: siteId)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<AssetChartModel>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single(let single):
                    self.loadingStatus = .default
                    self.chartData = single
                    self.reloadViews()
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
extension AssetReportVC {
    
    func setupViews() {
        self.areaXIB.lblText.text = "All Sites"
        self.setupAreaMenu()
        self.siteSwitch.isOn = !self.allSites
        
        self.startDateRangeXIB.title = "Start Date Range"
        self.startDateRangeXIB.text = ddMMyyyyStr
        self.startDateRangeXIB.image = UIImage(systemName: "calendar")
        self.startDateRangeXIB.optionXIB.btnDownClick.tag = 1
        self.startDateRangeXIB.optionXIB.btnDownClick.addAction { [weak self] in
            guard let self else { return }
            let sender: UIButton! = self.startDateRangeXIB.optionXIB.btnDownClick
            let date = self.selectedStartDate
            CAFMDatePicker(delegate: nil).openDatePicker(presentVC: self, sender: sender, tag: sender.tag, selectedDate: date, minDate: nil, maxDate: nil, hideButton: false) { [weak self] date in
                guard let self else { return }
                self.selectedStartDate = date
                self.startDateRangeXIB.text = date?.transformToString(dateFormat: ddMMyyyyStr) ?? ddMMyyyyStr
                self.getSiteAssetsAllV2Data()
            }
        }
        
        self.endDateRangeXIB.title = "End Date Range"
        self.endDateRangeXIB.text = ddMMyyyyStr
        self.endDateRangeXIB.image = UIImage(systemName: "calendar")
        self.endDateRangeXIB.optionXIB.btnDownClick.tag = 1
        self.endDateRangeXIB.optionXIB.btnDownClick.addAction { [weak self] in
            guard let self else { return }
            let sender: UIButton! = self.endDateRangeXIB.optionXIB.btnDownClick
            let date = self.selectedEndDate
            CAFMDatePicker(delegate: nil).openDatePicker(presentVC: self, sender: sender, tag: sender.tag, selectedDate: date, minDate: nil, maxDate: nil, hideButton: false) { [weak self] date in
                guard let self else { return }
                self.selectedEndDate = date
                self.endDateRangeXIB.text = date?.transformToString(dateFormat: ddMMyyyyStr) ?? ddMMyyyyStr
                self.getSiteAssetsAllV2Data()
            }
        }
    }
    
    func reloadViews() {
        self.areaXIB.isUserInteractionEnabled = self.allSites
        self.areaXIB.dummyTF.backgroundColor = self.areaXIB.isUserInteractionEnabled ? UIColor.white : UIColor(appColor: .GrayStatusBG)
        self.setupAssetTypeChart()
        self.setupPATResultChart()
    }
    
    func setupAreaMenu() {
        let view: OptionBtnXib = self.areaXIB
        let defaultStr = "All Sites"
        
        let allCases: [String] = UserConstants.shared.SiteArea
        
        let performAction: ((String?) -> Void) = { [weak self] item in
            guard let self else { return }
            self.selectedArea = item
            view.lblText.text = item ?? defaultStr
            self.loadData()
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
    
    func setupPATResultChart() {
        let data = self.chartData?.cost ?? []
        
        self.PATResultChartContainerViewWidth.constant = max(self.view.frame.width-10-10, (CGFloat(data.count)*20)+50)
        self.PATResultChartContainerView.frame.size.width = PATResultChartContainerViewWidth.constant
        
        let view: UIView! = self.PATResultChartContainerView
        view.stopSkeleton()
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
        title.text = "Fixed Assets Purchased in Selected Range"
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
        xAxis.title = HITitle()
        xAxis.title.text = "Month"
        options.xAxis = [xAxis]
        
        let yAxis = HIYAxis()
        yAxis.min = 0
        yAxis.title = HITitle()
        yAxis.title.text = "Total Cost (£)"
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
        column.name = "Total Cost of Purchases (£)"
        column.color = HIColor(uiColor: UIColor(hexString: "#3c50e0"))
        column.data = data.compactMap({ [$0.x ?? "", $0.y ?? 0] }) as [Any]
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
        
        self.setupPATResultChart2()
        self.setupPATResultChart3()
    }
    
    func setupPATResultChart2() {
        let data = self.chartData?.quantity ?? []
        
        self.PATResultChart2ContainerViewWidth.constant = max(self.view.frame.width-10-10, (CGFloat(data.count)*20)+50)
        self.PATResultChart2ContainerView.frame.size.width = PATResultChart2ContainerViewWidth.constant
        
        let view: UIView! = self.PATResultChart2ContainerView
        view.stopSkeleton()
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
        title.text = "Fixed Assets Purchased in Date Range"
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
        xAxis.title = HITitle()
        xAxis.title.text = "Month"
        options.xAxis = [xAxis]
        
        let yAxis = HIYAxis()
        yAxis.min = 0
        yAxis.title = HITitle()
        yAxis.title.text = "Total Assets"
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
        column.name = "Total Quantity of Purchased Assets"
        column.color = HIColor(uiColor: UIColor(hexString: "#3c50e0"))
        column.data = data.compactMap({ [$0.x ?? "", $0.y ?? 0] }) as [Any]
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
    
    func setupPATResultChart3() {
        let data = self.chartData?.costSite ?? []
        
        self.PATResultChart3ContainerViewWidth.constant = max(self.view.frame.width-10-10, (CGFloat(data.count)*20)+50)
        self.PATResultChart3ContainerView.frame.size.width = PATResultChart3ContainerViewWidth.constant
        
        let view: UIView! = self.PATResultChart3ContainerView
        view.stopSkeleton()
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
        yAxis.title.text = "Total Cost (£)"
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
        column.name = "Fixed Assets Purchased by Building"
        column.color = HIColor(uiColor: UIColor(hexString: "#3c50e0"))
        column.data = data.compactMap({ [$0.x ?? "", $0.y ?? 0] }) as [Any]
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
    
    func setupAssetTypeChart() {
        let general = self.chartData?.general ?? 0
        let door = self.chartData?.door ?? 0
        let pat = self.chartData?.pat ?? 0
        let pfp = self.chartData?.pfp ?? 0
        let total = general+door+pat+pfp
        
        let view: UIView! = self.AssetTypeChartContainerView
        view.stopSkeleton()
        view.subviews.filter { $0 is HIChartView }.forEach { $0.removeFromSuperview() }
        
        var itemArray: [(label: String, data: Int, color: UIColor)] = []
        itemArray.append((label: "General", data: general, color: UIColor(hexString: "#1E3A8A")))
        itemArray.append((label: "Doors", data: door, color: UIColor(hexString: "#2563EB")))
        itemArray.append((label: "PAT", data: pat, color: UIColor(hexString: "#60A5FA")))
        itemArray.append((label: "PFP", data: pfp, color: UIColor(hexString: "#93C5FD")))
        
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
        title.text = "\(total) Total Assets"
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
