//
//  SiteReadingsCostVC.swift
//  cafm
//
//  Created by ShitaRam on 05/10/24.
//

import UIKit
import SpreadsheetView
import SCLAlertView

class SiteReadingsCostVC: UIViewController, SpreadsheetViewDataSource, SpreadsheetViewDelegate, UITextFieldDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var viewSpread: SpreadsheetView!
    
    @IBOutlet weak var viewCategoryXib: OptionBtnXib!
    
    var itemArray: [Energy] = []
    var searchEnergyList = [Energy]()
    var category: [EnergyCostBudgetCategory] = []
    
    var loadingStatus: LoadingStatus = .loading
    var selectedCategoryID = 0
    
    var headerRow: [String] = ["Meter Reference", "Budget Category", "From Date", "To Date", "Reading", "Cost (GBP)", "Actions"]
    
    var isDataNotRecive : Bool {
        return (loadingStatus == .loading || loadingStatus == .failed || loadingStatus == .noResponse || loadingStatus == .noInternet)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Site Energy Readings & Cost"
        viewCategoryXib.lblText.text = "Budget Category"
        viewSpread.bounces = false
        viewSpread.dataSource = self
        viewSpread.delegate = self
        searchBar.delegate = self
        searchBar.searchTextField.delegate = self
        viewSpread.register(UINib(nibName: String(describing: CellTextXib.self), bundle: nil), forCellWithReuseIdentifier: String(describing: CellTextXib.self))
        viewSpread.register(UINib(nibName: String(describing: MoreEditOption.self), bundle: nil), forCellWithReuseIdentifier: String(describing: MoreEditOption.self))
        fetchData()
        setCategoryXib()
    }
    
    func setCategoryXib() {
        var actions = [UIAction]()
        actions.append(UIAction(title: "Budget Category", state: selectedCategoryID == 0 ? .on : .off, handler: { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.selectedCategoryID = 0
                self.viewCategoryXib.lblText.text = "Budget Category"
                self.setCategoryXib()
                self.searchFilter(searchText:self.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
            }
        }))
        for (key,item) in category.enumerated() {
            actions.append(UIAction(title: item.lovValue ?? "No Name", state: selectedCategoryID == item.id ?? 0 ? .on : .off, handler: { [weak self] _ in
                DispatchQueue.main.async { [weak self] in
                    guard let self else {return}
                    self.selectedCategoryID = item.id ?? 0
                    self.viewCategoryXib.lblText.text = item.lovValue
                    self.setCategoryXib()
                    self.searchFilter(searchText:self.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
                }
            }))
        }
        viewCategoryXib.btnDownClick.menu = UIMenu(title: "", children: actions)
        viewCategoryXib.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    
    func getCategory() {
        guard let siteID = UserConstants.shared.selectedSiteID else {
            return
        }
        let apiService = ApiService.energyCostCategory
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<EnergyCostBudgetCategory>, Error>) in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                switch result {
                case .success(let mappableResult):
                    switch mappableResult {
                    case .array(let response):
                        print("response category \(response)")
                        self.category = response
                        setCategoryXib()
                        break
                    default:
                        break
                    }
                case .failure(let error):
                    print(apiService.api(), "Error:", error.localizedDescription)
                }
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Get the updated text after the change
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string).trimmingCharacters(in: .whitespacesAndNewlines)

        // Call your search functionality with the updated text
        print("rk : \(updatedText)")
        
        searchFilter(searchText: updatedText)

        return true
    }

    func searchFilter(searchText: String) {
        if self.itemArray.isEmpty {
            return
        }
        DispatchQueue.main.async { [weak self] in
            guard let self else {return}
            if searchText == "" {
                self.searchEnergyList = self.itemArray
            }else {
                self.searchEnergyList = self.itemArray.filter({ data in
                    data.reference?.lowercased().contains(searchText.lowercased()) ?? false
                }).sorted { user1, user2 in
                    let name1 = user1.reference?.lowercased() ?? ""
                    let name2 = user2.reference?.lowercased() ?? ""
                    
                    // Check if either name starts with the search text
                    let startsWith1 = name1.hasPrefix(searchText.lowercased())
                    let startsWith2 = name2.hasPrefix(searchText.lowercased())
                    
                    // Sort by whether the name starts with the search text
                    if startsWith1 && !startsWith2 {
                        return true
                    } else if !startsWith1 && startsWith2 {
                        return false
                    } else {
                        // If both or neither start with the search text, preserve original order or sort alphabetically
                        return name1 < name2
                    }
                }
            }
            if selectedCategoryID != 0, let first = category.first(where: {$0.id == self.selectedCategoryID}) {
                self.searchEnergyList = self.searchEnergyList.filter({ data in
                    (data.budgetCategory?.lowercased() ?? "") == (first.lovValue?.lowercased() ?? "")
                })
            }
            if searchEnergyList.isEmpty {
                self.loadingStatus = .noResponse
            }else {
                self.loadingStatus = .default
            }
            self.reloadCollection()
        }
    }
    
    func fetchData() {
        getCategory()
        loadingStatus = .loading
        reloadCollection()
        guard let siteID = UserConstants.shared.selectedSiteID else {
            return
        }
        let energyCosetApi = ApiService.siteEnergyCostDetails(siteId: siteID)
        APIClient.request(energyCosetApi) { [weak self] (result: Result<APIClient.MappableResult<Energy>, Error>) in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                switch result {
                case .success(let mappableResult):
                    switch mappableResult {
                    case .array(let response):
                        print("response energy \(response)")
                        self.itemArray = response
                        self.searchEnergyList = self.itemArray
                        loadingStatus = self.itemArray.isEmpty ? .noResponse : .default
                        reloadCollection()
                        break
                    default:
                        break
                    }
                case .failure(let error):
                    print("Error:", error.localizedDescription)
                    self.loadingStatus = .failed
                    self.reloadCollection()
                }
            }
        }
    }
    
    
    
    func reloadCollection() {
        viewSpread.reloadData()
    }
    
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return headerRow.count
    }

    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        switch self.loadingStatus {
        case .default:
            if searchEnergyList.isEmpty {
                return 1+1
            }else {
                return searchEnergyList.count+1
            }
        case .loading, .failed, .noResponse, .noInternet:
            return 1+1
        }
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        switch loadingStatus {
        case .loading, .failed, .noResponse, .noInternet:
            var stringsArray = [headerRow[column]]
            let maxColumnWidth = getMaxLabelSize(textArray: stringsArray, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 200).width
            return maxColumnWidth
        default:
            break
        }
        if column == 0 || column == 1 || column == 2 || column == 3 || column == 4 || column == 5 {
            var stringsArray = [String]()
            if column == 0 {
                stringsArray = searchEnergyList.compactMap{$0.reference}
                stringsArray.append(headerRow[column])
            }else if column == 1 {
                stringsArray = searchEnergyList.compactMap{$0.budgetCategory}
                stringsArray.append(headerRow[column])
            }else if column == 2 {
                stringsArray = searchEnergyList.compactMap{convertDateString($0.costList?.first?.fromDate)}
                stringsArray.append(headerRow[column])
            }else if column == 3 {
                stringsArray = searchEnergyList.compactMap{convertDateString($0.costList?.last?.toDate)}
                stringsArray.append(headerRow[column])
            }else if column == 4 {
                stringsArray = searchEnergyList.compactMap{"\($0.readingList?.last?.readingValue ?? 0) \($0.readingList?.last?.readingUnit ?? "")"}
                stringsArray.append(headerRow[column])
            }else if column == 5 {
                stringsArray = searchEnergyList.compactMap{$0.cost()}
                stringsArray.append(headerRow[column])
            }
            let maxColumnWidth = getMaxLabelSize(textArray: stringsArray, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 200).width
            return maxColumnWidth
        }
        return 95
    }
    
    func mergedCells(in spreadsheetView: SpreadsheetView) -> [CellRange] {
        switch self.loadingStatus {
        case .default:
            return []
        case .loading, .failed, .noResponse, .noInternet:
            let totalColumn = self.headerRow.count
            return [CellRange(from: IndexPath(row: 1, column: 0), to: IndexPath(row: 1, column: totalColumn-1))]
        }
    }

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        switch loadingStatus {
        case .loading, .failed, .noResponse, .noInternet:
            let refSize = CGSize(width: 100, height: 40)
            let heightAddition: CGFloat = 10+10
            let minHeight = refSize.height-heightAddition
            let textArray = headerRow
            let font = UIFont(name: .MontserratSemiBold, size: textFontSize)
            let headerHeight = getMaxLabelSize(textArray: textArray, font: font, maxWidth: 200, minHeight: minHeight, heightAddition: heightAddition).height
            return headerHeight
        default:
            if row == 0 {
                let refSize = CGSize(width: 100, height: 40)
                let heightAddition: CGFloat = 10+10
                let minHeight = refSize.height-heightAddition
                let textArray = headerRow
                let font = UIFont(name: .MontserratSemiBold, size: textFontSize)
                let headerHeight = getMaxLabelSize(textArray: textArray, font: font, maxWidth: 200, minHeight: minHeight, heightAddition: heightAddition).height
                return headerHeight
            }else {
                let refSize = CGSize(width: 100, height: 50)
                let heightAddition: CGFloat = 10+10
                let minHeight = refSize.height-heightAddition
                var optionArray = [String?]()
                optionArray.append(contentsOf: [
                    searchEnergyList[row-1].reference,
                    searchEnergyList[row-1].budgetCategory,
                    convertDateString(searchEnergyList[row-1].costList?.first?.fromDate),
                    convertDateString(searchEnergyList[row-1].costList?.last?.toDate),
                    "\(searchEnergyList[row-1].readingList?.last?.readingValue ?? 0) \(searchEnergyList[row-1].readingList?.last?.readingUnit ?? "")",
                    searchEnergyList[row-1].cost()
                ])
                let textArray = optionArray.compactMap{$0}
                let font = UIFont(name: .MontserratRegular, size: textFontSize)
                let headerHeight = getMaxLabelSize(textArray: textArray, font: font, maxWidth: 200, minHeight: minHeight, heightAddition: heightAddition).height
                return max(headerHeight, 60)
            }
        }
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        if indexPath.row == 0 {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextXib", for: indexPath) as! CellTextXib
            cell.backgroundColor = .white
            cell.lblText.textColor = .black
            cell.gridlines.top = .solid(width: 1, color: UIColor(appColor: .AppTint))
            cell.gridlines.bottom = .solid(width: 1, color: UIColor(appColor: .AppTint))
            cell.gridlines.left = .solid(width: 1, color: UIColor(appColor: .AppTint))
            cell.gridlines.right = .solid(width: 1, color: UIColor(appColor: .AppTint))
            cell.backgroundColor = UIColor(appColor: .AppTint)
            cell.lblText.font = UIFont(name: .MontserratSemiBold, size: textFontSize)
            cell.lblText.textColor = UIColor.white
            cell.lblText.backgroundColor = UIColor.clear
            cell.lblText.text = headerRow[indexPath.section]
            return cell
        }else if indexPath.row == 1 && isDataNotRecive {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextXib", for: indexPath) as! CellTextXib
            cell.gridlines.top = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
            cell.gridlines.bottom = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
            cell.gridlines.left = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
            cell.gridlines.right = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
            cell.backgroundColor = UIColor.white
            cell.lblText.addCorner(value: 0)
            cell.lblText.font = UIFont(name: .MontserratRegular, size: textFontSize)
            cell.lblText.textColor = UIColor.black
            cell.lblText.backgroundColor = UIColor.clear
            cell.lblText.text = loadingStatus.rawValue
            if loadingStatus == .noResponse && !itemArray.isEmpty {
                cell.lblText.text = "No search result found!!"
            }
            return cell
        }else if indexPath.section == 0 || indexPath.section == 1 || indexPath.section == 2 || indexPath.section == 3 || indexPath.section == 4 || indexPath.section == 5 {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextXib", for: indexPath) as! CellTextXib
            cell.backgroundColor = .white
            cell.lblText.textColor = .black
            cell.gridlines.top = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
            cell.gridlines.bottom = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
            cell.gridlines.left = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
            cell.gridlines.right = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
            cell.backgroundColor = UIColor.white
            cell.lblText.addCorner(value: 0)
            cell.lblText.font = UIFont(name: .MontserratRegular, size: textFontSize)
            cell.lblText.textColor = UIColor.black
            cell.lblText.backgroundColor = UIColor.clear
            var text: String? = "--"
            if indexPath.section == 0 {
                text = searchEnergyList[indexPath.row-1].reference
            }else if indexPath.section == 1 {
                text = searchEnergyList[indexPath.row-1].budgetCategory
            }else if indexPath.section == 2 {
                text = convertDateString(searchEnergyList[indexPath.row-1].costList?.first?.fromDate)
            }else if indexPath.section == 3 {
                text = convertDateString(searchEnergyList[indexPath.row-1].costList?.last?.toDate)
            }else if indexPath.section == 4 {
                text =                     "\(searchEnergyList[indexPath.row-1].readingList?.last?.readingValue ?? 0) \(searchEnergyList[indexPath.row-1].readingList?.last?.readingUnit ?? "")"
            }else if indexPath.section == 5 {
                text = searchEnergyList[indexPath.row-1].cost()
            }
            cell.lblText.text = text
            return cell
        }else if indexPath.section == 6 {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "MoreEditOption", for: indexPath) as! MoreEditOption
            cellBorderSetUp(cell: cell, isHeader: false)
            cell.btnAction.showsMenuAsPrimaryAction = true
            
            // Create actions with SF Symbols
            let viewEditCost = UIAction(title: "View/Edit Energy Cost", image: UIImage(systemName: "dollarsign")) { _ in
                print("View/Edit Energy Cost selected")
                DispatchQueue.main.async { [weak self] in
                    guard let self else {return}
                    let vc = siteReadingsCostSB.instantiateViewController(withIdentifier: "EnergyCostVC") as! EnergyCostVC
                    vc.itemArray = self.searchEnergyList[indexPath.row-1].costList?.reversed() ?? []
                    vc.item = self.searchEnergyList[indexPath.row-1]
                    vc.delegate = self
                    vc.homeVC = self
                    self.present(vc, animated: true)
                }
            }

            let viewEditReading = UIAction(title: "View/Edit Energy Reading", image: UIImage(systemName: "chart.xyaxis.line")) { _ in
                print("View/Edit Energy Reading selected")
                let vc = siteReadingsCostSB.instantiateViewController(withIdentifier: "EnergyReadingVC") as! EnergyReadingVC
                vc.itemArray = self.searchEnergyList[indexPath.row-1].readingList ?? []
                vc.item = self.searchEnergyList[indexPath.row-1]
                vc.delegate = self
                vc.homeVC = self
                self.present(vc, animated: true)
            }

            let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                DispatchQueue.main.async { [weak self] in
                    let appearance = SCLAlertView.SCLAppearance(
                        showCloseButton: false // if you dont want the close button use false
                    )
                    let scl = SCLAlertView(appearance: appearance)
                    scl.showWait("", subTitle: "please wait...", closeButtonTitle: "")
                    guard let self else {return}
                    let api = ApiService.deleteEnergyServay(id:  self.searchEnergyList[indexPath.row-1].energyId ?? 0)
                    APIClient.requestWithCode(api) { [weak self] isSucess, code in
                        DispatchQueue.main.async { [weak self] in
                            guard let self else {return}
                            scl.hideView()
                            if isSucess, code == 200 {
                                let sclAlertView = SCLAlertView()
                                self.fetchData()
                            }else {
                                SCLAlertView().showError("Error", subTitle: "Oops! please try again")
                            }
                        }
                    }
                }
            }

            // Create a UIMenu and add the actions
            let menu = UIMenu(title: "", children: [viewEditCost, viewEditReading, delete])
            
            // Assign the menu to the button
            cell.btnAction.menu = menu

            return cell
        }else {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextXib", for: indexPath) as! CellTextXib
            cell.lblText.text = "s:\(indexPath.section),r:\(indexPath.row)"
            return cell
        }
    }
    
    func cellBorderSetUp(cell: Cell, isHeader: Bool) {
        if isHeader {
            cell.gridlines.top = .solid(width: 1, color: UIColor(appColor: .AppTint))
            cell.gridlines.bottom = .solid(width: 1, color: UIColor(appColor: .AppTint))
            cell.gridlines.left = .solid(width: 1, color: UIColor(appColor: .AppTint))
            cell.gridlines.right = .solid(width: 1, color: UIColor(appColor: .AppTint))
            cell.backgroundColor = UIColor(appColor: .AppTint)
        }else {
            cell.gridlines.top = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
            cell.gridlines.bottom = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
            cell.gridlines.left = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
            cell.gridlines.right = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
            cell.backgroundColor = .white
        }
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, didSelectItemAt indexPath: IndexPath) {
        if (loadingStatus == .noInternet || loadingStatus == .failed) {
            fetchData()
        }
    }
    
    func frozenRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 1
    }
    
    @IBAction func clickOnCreate(_ sender: Any) {
        let vc = siteReadingsCostSB.instantiateViewController(withIdentifier: "CreateEACVC") as! CreateEACVC
        vc.category = self.category
        vc.homeVC = self
        self.present(vc, animated: true)
    }
    
}

extension SiteReadingsCostVC : ReloadEnegyCostDelgate {
    func reloadData() {
        self.fetchData()
    }
}

protocol ReloadEnegyCostDelgate: AnyObject {
    func reloadData()
}
