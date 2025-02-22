//
//  ActionsReportVC.swift
//  cafm
//
//  Created by NS on 24/11/24.
//
//

import UIKit
import SCLAlertView
import Highcharts

class ActionsReportVC: UIViewController {
    
    @IBOutlet weak var emptyView: EmptyView!
    @IBOutlet weak var mainView: UIView!

    @IBOutlet weak var areaXIB: OptionBtnXib!
    @IBOutlet weak var siteSwitch: DefaultSwitch!
    @IBOutlet weak var siteSwitchLbl: DefaultFontLabel!
    @IBOutlet weak var startDateRangeXIB: OptionBtnXib!
    @IBOutlet weak var endDateRangeXIB: OptionBtnXib!
    
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
    
    private var itemArray: [ActionModel] = []
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
            self.setupChart()
            self.viewShouldLayoutSubviews.toggle()
        }
    }
    
    @IBAction func actionsReportBtnClicked(_ sender: UIButton) {
        
    }
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        switch sender {
        case self.siteSwitch:
            self.allSites = !sender.isOn
            self.siteSwitchLbl.text = /*self.allSites ? "All Sites" : */"Individual"
            self.getSiteAction()
            break
        default:
            break
        }
    }
    
}

//MARK: - EmptyViewDelegate
extension ActionsReportVC: EmptyViewDelegate {
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
extension ActionsReportVC {
    
    func loadData() {
        self.getSiteAction()
    }
    
    func getSiteAction() {
        let view1: UIView! = self.chartContainerView
        view1.startSkeleton()
                
        self.loadingStatus = .loading
        
        var area: String?
        var siteId: Int?
        if !self.allSites {
            siteId = UserConstants.shared.selectedSiteID
        }
        if self.allSites, let selectedArea {
            area = try? selectedArea.asURL().absoluteString
        }
        let apiService: ApiService
        if let siteId {
            apiService = .siteActionsAPI(siteId: siteId)
        } else {
            apiService = .getAllAction(area: area)
        }
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<ActionModel>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single:
                    self.loadingStatus = .failed
                    break
                case .array(let array):
                    self.itemArray = array
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

//MARK: - setup views
extension ActionsReportVC {
    
    func setupViews() {
        self.areaXIB.lblText.text = "All Sites"
        self.setupAreaMenu()
        self.siteSwitch.isOn = !self.allSites
        self.siteSwitchLbl.text = /*self.allSites ? "All Sites" : */"Individual"

        self.startDateRangeXIB.lblText.text = ddMMyyyyStr
        self.startDateRangeXIB.imageView.image = UIImage(systemName: "calendar")
        self.startDateRangeXIB.btnDownClick.tag = 1
        self.startDateRangeXIB.btnDownClick.addAction { [weak self] in
            guard let self else { return }
            let sender: UIButton! = self.startDateRangeXIB.btnDownClick
            let date = self.selectedStartDate
            CAFMDatePicker(delegate: nil).openDatePicker(presentVC: self, sender: sender, tag: sender.tag, selectedDate: date, minDate: nil, maxDate: nil, hideButton: false) { [weak self] date in
                guard let self else { return }
                self.selectedStartDate = date
                self.startDateRangeXIB.lblText.text = date?.transformToString(dateFormat: ddMMyyyyStr) ?? ddMMyyyyStr
                self.reloadViews()
            }
        }
        
        self.endDateRangeXIB.lblText.text = ddMMyyyyStr
        self.endDateRangeXIB.imageView.image = UIImage(systemName: "calendar")
        self.endDateRangeXIB.btnDownClick.tag = 1
        self.endDateRangeXIB.btnDownClick.addAction { [weak self] in
            guard let self else { return }
            let sender: UIButton! = self.endDateRangeXIB.btnDownClick
            let date = self.selectedEndDate
            CAFMDatePicker(delegate: nil).openDatePicker(presentVC: self, sender: sender, tag: sender.tag, selectedDate: date, minDate: nil, maxDate: nil, hideButton: false) { [weak self] date in
                guard let self else { return }
                self.selectedEndDate = date
                self.endDateRangeXIB.lblText.text = date?.transformToString(dateFormat: ddMMyyyyStr) ?? ddMMyyyyStr
                self.reloadViews()
            }
        }

    }
    
    func reloadViews() {
        self.areaXIB.isUserInteractionEnabled = self.allSites
        self.areaXIB.dummyTF.backgroundColor = self.areaXIB.isUserInteractionEnabled ? UIColor.white : UIColor(appColor: .GrayStatusBG)
        
        if let selectedStartDate, let selectedEndDate {
            self.itemArray = self.itemArray.filter({ action in
                if let createdAtDate = action.createdAt?.transformToDate(dateFormat: yyyyMMddStr) {
                    return createdAtDate >= selectedStartDate && createdAtDate <= selectedEndDate
                }
                return false
            })
        }

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
            self.getSiteAction()
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
    
    func initializeCounters() -> (completedActions: Int, reportedActions: Int, reassessedActions: Int) {
        let completedActions = self.itemArray.filter({ $0.status == .completed }).count
        let reportedActions = self.itemArray.filter({ $0.status == .reported }).count
        let reassessedActions = self.itemArray.filter({ $0.status == .reassessed }).count
        return (completedActions, reportedActions, reassessedActions)
    }
    
    func setupChart() {
        let data = initializeCounters()
        let completedActions = data.completedActions
        let reportedActions = data.reportedActions
        let reassessedActions = data.reassessedActions
        let totalActions = completedActions + reportedActions + reassessedActions
        
        let view: UIView! = self.chartContainerView
        view.stopSkeleton()
        view.subviews.filter { $0 is HIChartView }.forEach { $0.removeFromSuperview() }
        
        self.chartContainerViewWidth.constant = self.view.frame.width-10-10
        view.frame.size.width = self.chartContainerViewWidth.constant
        
        //var itemArray: [(label: String, data: Int, color: UIColor)] = []
        var itemArray: [(label: String, data: Int)] = []
        if completedActions > 0 {
            itemArray.append((label: "Completed", data: completedActions))
        }
        if reportedActions > 0 {
            itemArray.append((label: "Reported", data: reportedActions))
        }
        if reassessedActions > 0 {
            itemArray.append((label: "Reassessed", data: reassessedActions))
        }
        
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
        title.text = "\(totalActions) Total Actions by Status"
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
            //data.color = HIColor(uiColor: item.color)
            chartData.append(data)
        }
        pie.data = chartData
        pie.colors = [
            HIColor(uiColor: UIColor(hexString: "#1E3A8A")),
            HIColor(uiColor: UIColor(hexString: "#2563EB")),
            HIColor(uiColor: UIColor(hexString: "#60A5FA")),
            HIColor(uiColor: UIColor(hexString: "#93C5FD")),
            HIColor(uiColor: UIColor(hexString: "#0A2540")),
            HIColor(uiColor: UIColor(hexString: "#0077B6")),
            HIColor(uiColor: UIColor(hexString: "#CAF0F8")),
        ]
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
