//
//  StatutoryRegisterReportVC.swift
//  cafm
//
//  Created by NS on 24/11/24.
//
//

import UIKit
import SCLAlertView
import Highcharts

class StatutoryRegisterReportVC: UIViewController {
    
    @IBOutlet weak var emptyView: EmptyView!
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var requirementXIB: OptionBtnWithTitleXIB!
    
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
    
    private var selectedRequirement: String?
    private var statutoryRegisterBySiteIdItemArray: [StatutoryModel] = []
    private var statutoryRegisterAllItemArray: [StatutoryRegistersModel] = []
    
    private let kResponseDateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    private let kRequestDateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'" //"yyyy-MM-dd HH:mm:ss"
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
    
    @IBAction func statutoryRegisterReportBtnClicked(_ sender: UIButton) {
        
    }
    
}

//MARK: - EmptyViewDelegate
extension StatutoryRegisterReportVC: EmptyViewDelegate {
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
extension StatutoryRegisterReportVC {
    
    func loadData() {
        self.getDocumentStatutoryRegisterBySite()
    }
    
    func getDocumentStatutoryRegisterBySite() {
        let view1: UIView! = self.chartContainerView
        view1.startSkeleton()
        
        guard let siteID = UserConstants.shared.selectedSiteID else {
            self.loadingStatus = .failed
            return
        }
        
        self.loadingStatus = .loading
        
        let apiService = ApiService.statutoryRegister(siteId: siteID)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<StatutoryModel>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single:
                    self.loadingStatus = .failed
                    break
                case .array(let array):
                    self.statutoryRegisterBySiteIdItemArray = array.sorted(by: { Int($0.sortOrder ?? "") ?? 0 < Int($1.sortOrder ?? "") ?? 0 })
                    self.getDocumentStatutoryRegisterAll()
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                self.loadingStatus = .failed
            }
        }
    }
    
    func getDocumentStatutoryRegisterAll() {
        let apiService = ApiService.statutoryRegisterAll
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<StatutoryRegistersModel>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single:
                    self.loadingStatus = .failed
                    break
                case .array(let array):
                    self.statutoryRegisterAllItemArray = array
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
extension StatutoryRegisterReportVC {
    
    func setupViews() {
        self.requirementXIB.title = "Select Requirement to check all sites"
        self.requirementXIB.text = "Select Requirements"
    }
    
    func reloadViews() {
        self.setupRequirementMenu()
        self.setupChart()
    }
    
    func setupRequirementMenu() {
        let view: OptionBtnXib = self.requirementXIB.optionXIB
        let defaultStr = "Select Requirements"
        
        let allCases: [String] = self.statutoryRegisterBySiteIdItemArray.compactMap({ $0.requirement })
        
        let performAction: ((String?) -> Void) = { [weak self] item in
            guard let self else { return }
            self.selectedRequirement = item
            view.lblText.text = item ?? defaultStr
            self.reloadViews()
        }
        
        var actions: [UIMenuElement] = []
        let titleAction = UIAction(title: defaultStr, state: self.selectedRequirement == nil ? .on : .off) { [weak self] action in
            guard self != nil else { return }
            performAction(nil)
        }
        actions.append(titleAction)
        
        for item in allCases {
            let action = UIAction(title: item, state: self.selectedRequirement == item ? .on : .off) { [weak self] action in
                guard self != nil else { return }
                performAction(item)
            }
            actions.append(action)
        }
        view.btnDownClick.menu = UIMenu(children: actions)
        view.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func processStatutoryRegisters() -> (dutiesMet: [StatutoryModel], dutiesNotMet: [StatutoryModel]) {
        let data = self.statutoryRegisterAllItemArray
        let requirement = self.selectedRequirement
        
        data.forEach { statutoryRegistersModel in
            statutoryRegistersModel.statutoryRegisters?.forEach({ statutoryModel in
                statutoryModel.siteName = statutoryRegistersModel.siteName
            })
        }
        
        let statutoryRegisters = data.reduce([StatutoryModel](), { $0 + ($1.statutoryRegisters ?? []) }).filter({ $0.required == true && $0.requirement == requirement })
        
        let dutiesMet = statutoryRegisters.filter { $0.status == "Passed" }
        let dutiesNotMet = statutoryRegisters.filter { $0.status == "Fail" }
        
        return (dutiesMet, dutiesNotMet)
    }
    
    func setupChart() {
        let data = processStatutoryRegisters()
        let dutiesMet = data.dutiesMet
        let dutiesNotMet = data.dutiesNotMet
        let totalDuties = dutiesMet + dutiesNotMet
        
        let view: UIView! = self.chartContainerView
        view.stopSkeleton()
        view.subviews.filter { $0 is HIChartView }.forEach { $0.removeFromSuperview() }
        
        self.chartContainerViewWidth.constant = self.view.frame.width-10-10
        view.frame.size.width = self.chartContainerViewWidth.constant
        
        var itemArray: [(label: String, data: [StatutoryModel], color: UIColor)] = []
        itemArray.append((label: "Duties Met", data: dutiesMet, color: UIColor(hexString: "#1E3A8A")))
        itemArray.append((label: "Duties Not Met", data: dutiesNotMet, color: UIColor(hexString: "#2563EB")))
        
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
        let requirement = self.selectedRequirement ?? ""
        title.text = totalDuties.count > 0 ? "\(totalDuties.count) Duties Status Analysis for Requirement: \(requirement)" : "No duties for Requirement: \(requirement)"
        options.title = title
        
        let tooltip = HITooltip()
        tooltip.enabled = false
        //tooltip.headerFormat = ""
        //tooltip.pointFormat = "<b>{point.name}: {point.y}</b><br/>{point.custom.siteNames}"
        options.tooltip = tooltip
        
        let legends = HILegend()
        legends.itemStyle = HICSSObject()
        legends.itemStyle.fontSize = isiPadDevice ? "17" : "15"
        options.legend = legends
        
        let plotOptions = HIPlotOptions()
        plotOptions.pie = HIPie()
        plotOptions.pie.allowPointSelect = false
        //plotOptions.pie.cursor = "pointer"
        
        let clickFunc = HIFunction(closure: { context in
            if let id = context?.getProperty("this.id") as? String, let index = Int(id) {
                if itemArray.count > index {
                    let item = itemArray[index]
                    self.showDetailViewController(item)
                }
            }
        }, properties: ["this.id"])
        
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
        for (index, item) in itemArray.enumerated() {
            let data = HIData()
            data.id = "\(index)"
            data.name = item.label
            data.y = NSNumber(integerLiteral: item.data.count)
            data.color = HIColor(uiColor: item.color)
            //data.custom = ["siteNames": item.data.compactMap({ "<span>• \($0.siteName ?? "") (\($0.subType ?? $0.requirement ?? ""))</span>" }).joined(separator: "<br/>")]
            chartData.append(data)
        }
        pie.data = chartData
        pie.tooltip = tooltip
        
        pie.allowPointSelect = true
        pie.point = HIPoint()
        pie.point.events = HIEvents()
        pie.point.events.click = clickFunc
        
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
    
    func showDetailViewController(_ item: (label: String, data: [StatutoryModel], color: UIColor)) {
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.paragraphSpacing = 8
        let attributedString1 = NSAttributedString(
            string: "\(item.data.first?.subType ?? item.data.first?.requirement ?? "")\n",
            attributes: [
                .font: UIFont(name: .MontserratSemiBold, size: 18) as Any,
                .paragraphStyle: paraStyle
            ]
        )
        let attributedString2 = NSAttributedString(
            string: item.data.compactMap({ "• \($0.siteName ?? "")" }).joined(separator: "\n"),
            attributes: [
                .font: UIFont(name: .MontserratMedium, size: 17) as Any,
                .paragraphStyle: paraStyle
            ]
        )
        let attributedString = NSMutableAttributedString()
        attributedString.append(attributedString1)
        attributedString.append(attributedString2)
        
        let vc = reportsSB.instantiateViewController(withIdentifier: "TextViewVC") as! TextViewVC
        vc.title = "\(item.label): \(item.data.count)"
        vc.attributedText = attributedString
        let nav = UINavigationController(rootViewController: vc)
        (nav.presentationController as? UISheetPresentationController)?.detents = [.medium()]
        self.present(nav, animated: true)
    }
    
}
