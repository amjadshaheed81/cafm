//
//  EventCalendarVC.swift
//  cafm
//
//  Created by NS on 19/08/24.
//
//

import UIKit
import FSCalendar
import SCLAlertView

class EventCalendarVC: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var emptyView: EmptyView!
    @IBOutlet weak var calendarContainerView: UIView!
    @IBOutlet weak var calendarContainerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    var calendarView: UIView!
    
    var cal: Calendar = cafmCalendar()
    
    //var allCalendarEvents: [CalendarEvent] = []
    var itemArray: [CalendarEvent] = []
    var calendarEventsDict: [Date: [CalendarEvent]] = [:]
    
    var didViewLayoutSubviews: Bool = false
    var isForSite: Bool = false
    private var myContext = 0
    
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
        setupCalendarView()
        
        self.emptyView.delegate = self
        
        self.tableView.addObserver(self, forKeyPath: #keyPath(UITableView.contentSize), options: [NSKeyValueObservingOptions.old, NSKeyValueObservingOptions.new], context: &myContext)
        
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 60
        
        self.loadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !didViewLayoutSubviews {
            let minHeight = self.scrollView.frame.height-(self.calendarContainerView.frame.height+1)
            self.tableViewHeight.constant = minHeight
            self.tableView.frame.size.height = minHeight
            didViewLayoutSubviews.toggle()
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &myContext,
           keyPath == #keyPath(UITableView.contentSize),
           let oldContentSize = change?[NSKeyValueChangeKey.oldKey] as? CGSize,
           let newContentSize = change?[NSKeyValueChangeKey.newKey] as? CGSize,
           oldContentSize.height != newContentSize.height {
            let minHeight = self.scrollView.frame.height-(self.calendarContainerView.frame.height+1)
            let height = max(minHeight, self.tableView.contentSize.height+self.tableView.contentInset.top+self.tableView.contentInset.bottom)
            self.tableViewHeight.constant = height
            self.tableView.frame.size.height = height
        }
    }
    
    func setupCalendarView() {
        self.calendarContainerView.layoutIfNeeded()
        if #available(iOS 16.0, *) {
            let calendarView = UICalendarView(frame: calendarContainerView.bounds)
            calendarView.delegate = self
            calendarView.selectionBehavior = UICalendarSelectionSingleDate(delegate: self)
            calendarView.calendar = self.cal //Calendar(identifier: .gregorian)
            calendarView.fontDesign = UIFontDescriptor.SystemDesign.rounded
            self.calendarView = calendarView
            
            calendarView.translatesAutoresizingMaskIntoConstraints = false
            calendarContainerView.addSubview(calendarView)
            NSLayoutConstraint.activate([
                calendarView.topAnchor.constraint(equalTo: calendarContainerView.topAnchor),
                calendarView.leadingAnchor.constraint(equalTo: calendarContainerView.leadingAnchor),
                calendarView.trailingAnchor.constraint(equalTo: calendarContainerView.trailingAnchor),
                calendarView.bottomAnchor.constraint(equalTo: calendarContainerView.bottomAnchor)
            ])
            
            //let height1 = calendarView.sizeThatFits(CGSize(width: calendarContainerView.bounds.width, height: CGFloat.greatestFiniteMagnitude)).height
            let height = calendarView.intrinsicContentSize.height
            self.calendarContainerViewHeight.constant = height
            self.calendarContainerView.frame.size.height = height
        } else {
            let calendarView = FSCalendar(frame: calendarContainerView.bounds)
            calendarView.dataSource = self
            calendarView.delegate = self
            self.calendarView = calendarView
            
            calendarView.translatesAutoresizingMaskIntoConstraints = false
            calendarContainerView.addSubview(calendarView)
            NSLayoutConstraint.activate([
                calendarView.topAnchor.constraint(equalTo: calendarContainerView.topAnchor),
                calendarView.leadingAnchor.constraint(equalTo: calendarContainerView.leadingAnchor),
                calendarView.trailingAnchor.constraint(equalTo: calendarContainerView.trailingAnchor),
                calendarView.bottomAnchor.constraint(equalTo: calendarContainerView.bottomAnchor)
            ])
            
            let height: CGFloat = isiPadDevice ? 400 : 400
            self.calendarContainerViewHeight.constant = height
            self.calendarContainerView.frame.size.height = height
            
            self.setupFSCalendarAppearance()
            self.configureVisibleCells()
            
            let btnWidth = self.calendarContainerView.frame.size.width*0.25
            var headerHeight = (FSCalendarStandardHeaderHeight/FSCalendarStandardMonthlyPageHeight)*height
            headerHeight -= (headerHeight-FSCalendarStandardHeaderHeight)*0.5
            
            let prevBtn = UIButton(type: .custom)
            prevBtn.frame = CGRect(x: 0, y: headerHeight*0.1, width: btnWidth, height: headerHeight*0.9)
            prevBtn.backgroundColor = UIColor(appColor: .BG1)
            prevBtn.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
            prevBtn.addTarget(self, action: #selector(self.fsCalenderHeaderPrevBtnClicked(_:)), for: .touchUpInside)
            calendarContainerView.addSubview(prevBtn)
            
            let nextBtn = UIButton(type: .custom)
            nextBtn.frame = CGRect(x: self.calendarContainerView.frame.size.width-btnWidth, y: headerHeight*0.1, width: btnWidth, height: headerHeight*0.9)
            nextBtn.backgroundColor = UIColor(appColor: .BG1)
            nextBtn.setImage(UIImage(systemName: "chevron.forward"), for: .normal)
            nextBtn.addTarget(self, action: #selector(self.fsCalenderHeaderNextBtnClicked(_:)), for: .touchUpInside)
            calendarContainerView.addSubview(nextBtn)
        }
    }
    
    func loadData() {
        if self.isForSite {
            self.fetchSiteCalendarEvents()
        }else {
            self.fetchUserCalendarEvents()
        }
    }
    
    func fetchUserCalendarEvents() {
        guard let userId = UserConstants.shared.currentUserID else {
            return
        }
        
        self.loadingStatus = .loading
        let apiService = ApiService.userCalendarEventsAPI(userId: userId.stringValue, siteId: nil)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<CalendarEvent>, Error>) in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single:
                    strongSelf.loadingStatus = .failed
                    break
                case .array(var array):
                    array = self?.getUniqueEvents(events: array) ?? array
                    strongSelf.loadingStatus = .default
                    array.forEach({ calendarEvent in
                        calendarEvent.start_date = calendarEvent.startDate?.transformToDate(dateFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
                        calendarEvent.end_date = calendarEvent.endDate?.transformToDate(dateFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
                    })
                    let cal = strongSelf.cal
                    let startOfDay = cal.startOfDay(for: Date())
                    strongSelf.calendarEventsDict = Dictionary(grouping: array, by: { cal.startOfDay(for: $0.end_date ?? $0.start_date ?? startOfDay) })
                    strongSelf.selectDate(startOfDay)
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                strongSelf.loadingStatus = .failed
            }
        }
    }
    
    func fetchSiteCalendarEvents() {
        guard let siteId = UserConstants.shared.selectedSiteID else {
            return
        }
        
        self.loadingStatus = .loading
        let apiService = ApiService.userCalendarEventsAPI(userId: nil, siteId: "undefined")
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<CalendarEvent>, Error>) in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single:
                    strongSelf.loadingStatus = .failed
                    break
                case .array(var array):
                    array = self?.getUniqueEvents(events: array) ?? array
                    strongSelf.loadingStatus = .default
                    print(array.toJSONString())
                    array.forEach({ calendarEvent in
                        calendarEvent.start_date = calendarEvent.startDate?.transformToDate(dateFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
                        calendarEvent.end_date = calendarEvent.endDate?.transformToDate(dateFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
                    })
                    let cal = strongSelf.cal
                    let startOfDay = cal.startOfDay(for: Date())
                    strongSelf.calendarEventsDict = Dictionary(grouping: array, by: { cal.startOfDay(for: $0.end_date ?? $0.start_date ?? startOfDay) })
                    strongSelf.selectDate(startOfDay)
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                strongSelf.loadingStatus = .failed
            }
        }
    }
    
    func getUniqueEvents(events: [CalendarEvent]) -> [CalendarEvent] {
        var seenKeys = Set<String>()
        return events.filter { event in
            // Create the unique key using section, eventType, siteId, startDate, endDate, and shortText
            guard let section = event.section,
                  let eventType = event.eventType,
                  let siteId = event.siteId,
                  let startDate = event.startDate,
                  let endDate = event.endDate,
                  let shortText = event.shortText else { return false }
            
            let key = "\(section)-\(eventType)-\(siteId)-\(startDate)-\(endDate)-\(shortText)"
            
            if seenKeys.contains(key) {
                return false
            } else {
                seenKeys.insert(key)
                return true
            }
        }
    }

    
    func selectDate(_ date: Date) {
        let startOfDay = cal.startOfDay(for: Date())
        if #available(iOS 16.0, *) {
            if let calendarView = self.calendarView as? UICalendarView {
                let thisMonthDate = self.cal.dateInterval(of: .month, for: startOfDay)
                let dateComponents: [DateComponents] = self.calendarEventsDict.filter { thisMonthDate?.contains($0.key) ?? false }.compactMap { self.cal.dateComponents([.year, .month, .day], from: $0.key) }
                calendarView.reloadDecorations(forDateComponents: dateComponents, animated: true)
                
                (calendarView.selectionBehavior as? UICalendarSelectionSingleDate)?.setSelected(cal.dateComponents([.year, .month, .day], from: startOfDay), animated: true)
            }
        } else {
            if let calendarView = self.calendarView as? FSCalendar {
                calendarView.reloadData()
                calendarView.select(startOfDay, scrollToDate: true)
                calendarView.currentPage = startOfDay
                self.configureVisibleCells()
            }
        }
        self.showEventsForSelectedDate(startOfDay)
    }
    
    func showEventsForSelectedDate(_ date: Date) {
        let startOfDay = cal.startOfDay(for: date)
        
        self.itemArray = []
        if let events = self.calendarEventsDict[startOfDay] {
            self.itemArray = events
        }
        self.tableView.reloadData()
    }
    
    func getSiteCheckByCheckId(checkId: Int) {
        guard let siteID = UserConstants.shared.selectedSiteID else {
            return
        }
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false // if you dont want the close button use false
        )
        let scl = SCLAlertView(appearance: appearance)
        scl.showWait("", subTitle: "please wait...", closeButtonTitle: "")
        let api = ApiService.uploadFileInFolder

        let apiService = ApiService.get_siteCheckBy(checkId: checkId)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<SiteCheckModel>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single(let item):
                    if item.checkId != nil {
                        let apiService = ApiService.getAllUserBy(siteId: siteID)
                        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<UsersList>, Error>) in
                            guard let self else { return }
                            switch result {
                            case .success(let mappableResult):
                                switch mappableResult {
                                case .single(let single):
                                    let userBySiteIdItemArray = single.users ?? []
                                    let apiService = ApiService.lovAPI(lovType: .SITE_CHECK_TYPE)
                                    APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<LOV_Model>, Error>) in
                                        guard let self else { return }
                                        switch result {
                                        case .success(let mappableResult):
                                            switch mappableResult {
                                            case .single:
                                                DispatchQueue.main.async {
                                                    scl.hideView()
                                                    SCLAlertView().showError("Error", subTitle: "Oops! please try again")
                                                }
                                                break
                                            case .array(let SITE_CHECK_TYPE_ItemArray):
                                                DispatchQueue.main.async {
                                                    scl.hideView()
                                                    self.getData(item: item, userBySiteIdItemArray: userBySiteIdItemArray, SITE_CHECK_TYPE_ItemArray: SITE_CHECK_TYPE_ItemArray)
                                                }
                                                break
                                            }
                                        case .failure(let error):
                                            print(apiService.api(), "Error:", error.localizedDescription)
                                            self.loadingStatus = .failed
                                        }
                                    }
                                    break
                                case .array:
                                    DispatchQueue.main.async {
                                        scl.hideView()
                                        SCLAlertView().showError("Error", subTitle: "Oops! please try again")
                                    }
                                    break
                                }
                            case .failure(let error):
                                DispatchQueue.main.async {
                                    scl.hideView()
                                    SCLAlertView().showError("Error", subTitle: "Oops! please try again")
                                }
                            }
                        }
                    }else {
                        DispatchQueue.main.async {
                            scl.hideView()
                            SCLAlertView().showError("Error", subTitle: "Oops! please try again")
                        }
                    }
                    break
                case .array:
                    DispatchQueue.main.async {
                        scl.hideView()
                        SCLAlertView().showError("Error", subTitle: "Oops! please try again")
                    }
                    break
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    scl.hideView()
                    print(apiService.api(), "Error:", error.localizedDescription)
                    SCLAlertView().showError("Error", subTitle: "Oops! please try again")
                }
                break
            }
        }
    }
        
    func getData(item: SiteCheckModel, userBySiteIdItemArray: [User], SITE_CHECK_TYPE_ItemArray: [LOV_Model]/*, SITE_CHECK_SUB_TYPE_ItemDict: [String: [LOV_Model]]*/) {
        let vc = siteCheckSB.instantiateViewController(withIdentifier: "AddSiteCheckVC") as! AddSiteCheckVC
        //        vc.delegate = self
        vc.isForCreateNew = false
        vc.isViewModeEdit = true
        vc.siteCheckModel = item
        vc.userBySiteIdItemArray = userBySiteIdItemArray
        vc.SITE_CHECK_TYPE_ItemArray = SITE_CHECK_TYPE_ItemArray
        //        vc.SITE_CHECK_SUB_TYPE_ItemDict = SITE_CHECK_SUB_TYPE_ItemDict
        self.navigationController?.pushViewController(vc, animated: true)
    }

    
}

extension EventCalendarVC: EmptyViewDelegate {
    func emptyViewDidTapView(_ view: EmptyView) {
        if self.loadingStatus.shouldReload {
            self.loadData()
        }
    }
}

@available(iOS 16.0, *)
extension EventCalendarVC: UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
    
    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        guard let date = cal.date(from: dateComponents), let events = self.calendarEventsDict[date] else { return nil }
        if !events.isEmpty {
            return UICalendarView.Decoration.default(color: UIColor(appColor: .AppTint), size: .small)
        }
        return nil
    }
    
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        if let dateComponents, let date = cal.date(from: dateComponents) {
            self.showEventsForSelectedDate(date)
        }
    }
    
}

extension EventCalendarVC: FSCalendarDataSource, FSCalendarDelegate {
    
    func setupFSCalendarAppearance() {
        guard let calendarView = self.calendarView as? FSCalendar else { return }
        let appearance = calendarView.appearance
        
        calendarView.placeholderType = .none
        
        appearance.headerMinimumDissolvedAlpha = 0
        
        appearance.headerTitleFont = UIFont(name: .MontserratSemiBold, size: 17)
        appearance.weekdayFont = UIFont(name: .MontserratSemiBold, size: 14)
        appearance.titleFont = UIFont(name: .MontserratRegular, size: 17)
        
        appearance.headerTitleColor = UIColor.black
        appearance.weekdayTextColor = UIColor.tertiaryLabel
        
        appearance.todayColor = UIColor.clear
        
        appearance.titleDefaultColor = UIColor.black
        appearance.titleSelectionColor = UIColor(appColor: .AppTint)
        //appearance.selectionColor = UIColor(appColor: .AppTintBG)
        appearance.selectionColor = UIColor(hexString: "#DDE2F6")
        
        appearance.titleTodayColor = UIColor(appColor: .AppTint)
        appearance.todaySelectionColor = UIColor(appColor: .AppTint)
        
        appearance.eventDefaultColor = UIColor(appColor: .AppTint)
        appearance.eventSelectionColor = UIColor(appColor: .AppTint)
        appearance.eventOffset = CGPoint(x: 0, y: 4)
    }
    
    @objc func fsCalenderHeaderPrevBtnClicked(_ sender: UIButton) {
        guard let calendarView = self.calendarView as? FSCalendar else { return }
        let currentMonth = calendarView.currentPage
        let prevMonth = cal.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
        calendarView.setCurrentPage(prevMonth, animated: true)
    }
    
    @objc func fsCalenderHeaderNextBtnClicked(_ sender: UIButton) {
        guard let calendarView = self.calendarView as? FSCalendar else { return }
        let currentMonth = calendarView.currentPage
        let nextMonth = cal.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
        calendarView.setCurrentPage(nextMonth, animated: true)
    }
    
    private func configureVisibleCells() {
        guard let calendarView = self.calendarView as? FSCalendar else { return }
        calendarView.visibleCells().forEach { (cell) in
            let date = calendarView.date(for: cell)
            let position = calendarView.monthPosition(for: cell)
            self.configure(cell: cell, for: date!, at: position)
        }
    }
    
    private func configure(cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
        //guard let calendarView = self.calendarView as? FSCalendar else { return }
        if position == .current {
            if cell.isSelected {
                cell.titleLabel.font = UIFont(name: .MontserratSemiBold, size: 17)
                if cell.dateIsToday {
                    cell.titleLabel.textColor = UIColor.white
                }else {
                    cell.titleLabel.textColor = UIColor(appColor: .AppTint)
                }
            }else {
                cell.titleLabel.font = UIFont(name: .MontserratRegular, size: 17)
                if cell.dateIsToday {
                    cell.titleLabel.textColor = UIColor(appColor: .AppTint)
                }else {
                    cell.titleLabel.textColor = UIColor.black
                }
            }
        }
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        guard let events = self.calendarEventsDict[date] else { return 0 }
        if !events.isEmpty {
            return 1
        }
        return 0
    }
    
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at monthPosition: FSCalendarMonthPosition) {
        self.configure(cell: cell, for: date, at: monthPosition)
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        self.configureVisibleCells()
        self.showEventsForSelectedDate(date)
    }
    
}

extension EventCalendarVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.itemArray.isEmpty {
            return 1
        }
        return self.itemArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCalendarTableCell", for: indexPath) as! EventCalendarTableCell
        cell.selectionStyle = .none
        cell.bgView.addCorner(value: 8)
        if self.itemArray.isEmpty {
            cell.bgView.isHidden = true
            cell.mainLbl.text = "No Events!!"
            cell.mainLbl.textColor = UIColor(appColor: .PrimaryText)
        }else if self.itemArray.count > indexPath.row {
            cell.bgView.isHidden = false
            let item = self.itemArray[indexPath.row]
            cell.mainLbl.text = item.shortText
            
            //let bgColor: UIColor
            let textColor: UIColor
            if item.eventType?.contains("Audit") ?? false {
                textColor = UIColor(red: 52/255, green: 89/255, blue: 230/255, alpha: 1)
            }else if item.eventType?.contains("Assessment") ?? false {
                textColor = UIColor(red: 33/255, green: 37/255, blue: 41/255, alpha: 1)
            }else if item.eventType?.contains("Inspection") ?? false {
                textColor = UIColor(red: 47/255, green: 179/255, blue: 128/255, alpha: 1)
            }else if item.eventType?.contains("Survey") ?? false {
                textColor = UIColor(red: 218/255, green: 41/255, blue: 46/255, alpha: 1)
            }else if item.eventType?.contains("Asbestos") ?? false {
                textColor = UIColor(red: 244/255, green: 189/255, blue: 97/255, alpha: 1)
            }else if item.eventType?.contains("Document") ?? false {
                textColor = UIColor(red: 40/255, green: 123/255, blue: 181/255, alpha: 1)
            }else if item.eventType?.contains("Contract") ?? false {
                textColor = UIColor(red: 40/255, green: 123/255, blue: 181/255, alpha: 1)
            }else {
                textColor = UIColor(appColor: .AppTint)
            }
            cell.bgView.backgroundColor = textColor.withAlphaComponent(0.1)
            cell.mainLbl.textColor = textColor
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.itemArray.isEmpty {
        }else if self.itemArray.count > indexPath.row {
            let item = self.itemArray[indexPath.row]
            print("LogLog", "shortText:", item.shortText ?? "NULL", "eventType:", item.eventType ?? "NULL", "section:", item.section ?? "NULL")
            guard let type = extractTypeAndID(from: item.section ?? "").type, let id = extractTypeAndID(from: item.section ?? "").id else {return}
            if type == "site-checks" {
                getSiteCheckByCheckId(checkId: id)
            }else if type == "subfolder" {
                let vc = documnetSB.instantiateViewController(withIdentifier: "DocumnetsVC") as! DocumnetsVC
                vc.fromCalenderID = id
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
}

func extractTypeAndID(from path: String) -> (type: String?, id: Int?) {
    // Define the regex patterns for both formats
    let siteCheckPattern = "^/site-checks/(\\d+)/update$" // Pattern for the first format
    let subfolderPattern = "^/subfolder/\\?id=(\\d+)$" // Pattern for the second format
    
    // Check for site-checks format
    if let siteCheckMatch = path.range(of: siteCheckPattern, options: .regularExpression) {
        // Extract the ID from the path
        let siteCheckID = path.matchingString(for: siteCheckPattern)
        return ("site-checks", Int(siteCheckID ?? ""))
    }
    
    // Check for subfolder format
    if let subfolderMatch = path.range(of: subfolderPattern, options: .regularExpression) {
        // Extract the ID from the path
        let subfolderID = path.matchingString(for: subfolderPattern)
        return ("subfolder", Int(subfolderID ?? ""))
    }
    
    return (nil, nil)
}



extension String {
    func matchingString(for pattern: String) -> String? {
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let nsrange = NSRange(self.startIndex..<self.endIndex, in: self)
            if let match = regex.firstMatch(in: self, options: [], range: nsrange) {
                // Extract the first capture group (ID in this case)
                if let range = Range(match.range(at: 1), in: self) {
                    return String(self[range])
                }
            }
        }
        return nil
    }
}

