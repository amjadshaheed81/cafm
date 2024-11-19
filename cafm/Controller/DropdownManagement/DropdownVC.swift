//
//  DropdownVC.swift
//  cafm
//
//  Created by ShitaRam on 19/10/24.
//

import UIKit
import SpreadsheetView
import SCLAlertView

class DropdownVC: UIViewController, SpreadsheetViewDataSource, SpreadsheetViewDelegate {
    
    
    @IBOutlet weak var categoryListXib: OptionBtnXib!
    @IBOutlet weak var viewAddNewValue: DesignableCornerView!
    @IBOutlet weak var heightOfAddValue: NSLayoutConstraint!
    
    var categoryList: [String] = []
    var selectedCategoryInd = 0
    
    @IBOutlet weak var spreadView: SpreadsheetView!    
    
    var itemArray: [DropDownModel] = []
    
    var headerRow: [String] = ["Value", "Description", "Depends On", "Additional Attribute", "Sort Order", "Actions"]
    
    var loadingStatus: LoadingStatus = .loading

    var isDataNotRecive : Bool {
        return (loadingStatus == .loading || loadingStatus == .failed || loadingStatus == .noResponse || loadingStatus == .noInternet)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        categoryList.insert("Select", at: 0)
        self.title = "Dropdown Management"
        categoryListXib.lblText.text = "Select"
        setUpCategoryXib()
        self.viewAddNewValue.isHidden = true
        self.heightOfAddValue.constant = 0
        spreadView.register(UINib(nibName: String(describing: CellTextXib.self), bundle: nil), forCellWithReuseIdentifier: String(describing: CellTextXib.self))
        spreadView.register(UINib(nibName: String(describing: MoreEditOption.self), bundle: nil), forCellWithReuseIdentifier: String(describing: MoreEditOption.self))
        spreadView.dataSource = self
        spreadView.delegate = self
        spreadView.bounces = false
        self.spreadView.isHidden = true
    }
    
    func setUpCategoryXib() {
        var actions = [UIAction]()
        for (i,item) in categoryList.enumerated() {
            actions.append(UIAction(title: item.replacingOccurrences(of: "_", with: " "), state: selectedCategoryInd == i ? .on : .off, handler: { [weak self] _ in
                DispatchQueue.main.async { [weak self] in
                    guard let self else {return}
                    self.selectedCategoryInd = i
                    self.categoryListXib.lblText.text = item.replacingOccurrences(of: "_", with: " ")
                    self.setUpCategoryXib()
                    if i == 0 {
                        self.viewAddNewValue.isHidden = true
                        self.heightOfAddValue.constant = 0
                        self.spreadView.isHidden = true
                    }else {
                        self.viewAddNewValue.isHidden = false
                        self.heightOfAddValue.constant = 40
                        self.spreadView.isHidden = false
                        fetchData()
                    }
                }
            }))
        }
        categoryListXib.btnDownClick.menu = UIMenu(title: "", children: actions)
        categoryListXib.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    @IBAction func btnAddNewDropDown(_ sender: Any) {
        let vc = dropdownSB.instantiateViewController(withIdentifier: "AddMainDropDowan") as! AddMainDropDowan
        vc.homeVC = self
        self.present(vc, animated: true)
    }
    
    @IBAction func btnAddNewVAlue(_ sender: Any) {
        let vc = dropdownSB.instantiateViewController(withIdentifier: "AddNewDropDownValue") as! AddNewDropDownValue
        vc.homeVC = self
        vc.lovType = categoryList[selectedCategoryInd]
        self.present(vc, animated: true)
    }
    
    func fetchMainCategory() {
        let apiService = ApiService.dropDownTyprList
        APIClient.requestWithStringArray(apiService) { [weak self] catData, error in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                if let data = catData {
                    print(data)
                    self.categoryList = data
                    self.categoryList.insert("Select", at: 0)
                    self.selectedCategoryInd = 0
                    categoryListXib.lblText.text = "Select"
                    setUpCategoryXib()
                    self.spreadView.isHidden = true
                }
            }
        }
    }
    
    func fetchData() {
        loadingStatus = .loading
        reloadCollection()
        let catType = self.categoryList[selectedCategoryInd].replacingOccurrences(of: " ", with: "%20")
        let apiService = ApiService.dropDownList(catType: catType)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<DropDownModel>, Error>) in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                switch result {
                case .success(let mappableResult):
                    switch mappableResult {
                    case .array(let response):
                        print("response energy \(response)")
                        self.itemArray = response
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
        spreadView.reloadData()
    }
    
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return headerRow.count
    }
    
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        switch self.loadingStatus {
        case .default:
            if itemArray.isEmpty {
                return 1+1
            }else {
                return itemArray.count+1
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
                stringsArray = itemArray.compactMap{$0.lovValue}
                stringsArray.append(headerRow[column])
            }else if column == 1 {
                stringsArray = itemArray.compactMap{$0.lovDesc}
                stringsArray.append(headerRow[column])
            }else if column == 2 {
                stringsArray = itemArray.compactMap{$0.attribite1}
                stringsArray.append(headerRow[column])
            }else if column == 3 {
                stringsArray = itemArray.compactMap{$0.attribite2}
                stringsArray.append(headerRow[column])
            }else if column == 4 {
                stringsArray = itemArray.compactMap{$0.attribite3}
                stringsArray.append(headerRow[column])
            }else {
                stringsArray.append(headerRow[column])
            }
            let maxColumnWidth = getMaxLabelSize(textArray: stringsArray, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 200).width
            return maxColumnWidth
        }else {
            return 100
        }
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
                    itemArray[row-1].lovValue,
                    itemArray[row-1].lovDesc,
                    itemArray[row-1].attribite1,
                    itemArray[row-1].attribite2,
                    itemArray[row-1].attribite3
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
        }else if indexPath.section == 0 || indexPath.section == 1 || indexPath.section == 2 || indexPath.section == 3 || indexPath.section == 4 {
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
                text = itemArray[indexPath.row-1].lovValue
            }else if indexPath.section == 1 {
                text = itemArray[indexPath.row-1].lovDesc
            }else if indexPath.section == 2 {
                text = itemArray[indexPath.row-1].attribite1
            }else if indexPath.section == 3 {
                text = itemArray[indexPath.row-1].attribite2
            }else if indexPath.section == 4 {
                text = itemArray[indexPath.row-1].attribite3
            }
            cell.lblText.text = text
            return cell
        }else if indexPath.section == 5 {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "MoreEditOption", for: indexPath) as! MoreEditOption
            cellBorderSetUp(cell: cell, isHeader: false)
            cell.btnAction.showsMenuAsPrimaryAction = true
            
            let viewEditReading = UIAction(title: "Edit", image: UIImage(systemName: "pencil")) { _ in
                print("View/Edit Energy Reading selected")
                DispatchQueue.main.async { [weak self] in
                    guard let self else {return}
                    let vc = dropdownSB.instantiateViewController(withIdentifier: "AddNewDropDownValue") as! AddNewDropDownValue
                    vc.homeVC = self
                    vc.id = itemArray[indexPath.row-1].id
                    vc.data = itemArray[indexPath.row-1]
                    vc.lovType = categoryList[selectedCategoryInd]
                    self.present(vc, animated: true)
                }
            }

            let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                print("Delete selected")
                DispatchQueue.main.async { [weak self] in
                    let appearance = SCLAlertView.SCLAppearance(
                        showCloseButton: false // if you dont want the close button use false
                    )
                    let scl = SCLAlertView(appearance: appearance)
                    scl.showWait("", subTitle: "please wait...", closeButtonTitle: "")
                    guard let self else {return}
                    let api = ApiService.deleteDropDownValue(id: itemArray[indexPath.row-1].id ?? 0)
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
            let menu = UIMenu(title: "", children: [viewEditReading, delete])
            
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

    
}
