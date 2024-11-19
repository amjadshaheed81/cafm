//
//  NewContractsVC.swift
//  cafm
//
//  Created by ShitaRam on 10/09/24.
//

import UIKit
import SpreadsheetView
import SCLAlertView

class StatutoryRegisterVC: UIViewController, SpreadsheetViewDataSource, SpreadsheetViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var viewScroll: UIScrollView!
    
    @IBOutlet weak var lblDutiesIdentified: UILabel!
    @IBOutlet weak var lblDutiesIMeet: UILabel!
    @IBOutlet weak var lblDutiesIdNotMeet: UILabel!
    
    @IBOutlet weak var viewSpread: SpreadsheetView!
    
    
    var loadingStatus: LoadingStatus = .loading
    var itemArray = [StatutoryModel]()
    
    var headerRow: [String] = ["Id", "Requirement", "Required", "Responsible", "Document", "Status"]
    
    var isDataNotRecive : Bool {
        return (loadingStatus == .loading || loadingStatus == .failed || loadingStatus == .noResponse || loadingStatus == .noInternet)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Statutory Register"
        viewScroll.addCorner(value: 10)
        viewScroll.addBorder(width: 1, color: .separator)
        lblDutiesIdentified.text = "0"
        lblDutiesIMeet.text = "0"
        lblDutiesIdNotMeet.text = "0"
        viewSpread.register(UINib(nibName: String(describing: CellTextXib.self), bundle: nil), forCellWithReuseIdentifier: String(describing: CellTextXib.self))
        viewSpread.register(UINib(nibName: String(describing: CellTextWithBtnXib.self), bundle: nil), forCellWithReuseIdentifier: String(describing: CellTextWithBtnXib.self))
        viewSpread.register(UINib(nibName: String(describing: SwiSwitchXib.self), bundle: nil), forCellWithReuseIdentifier: String(describing: SwiSwitchXib.self))
        viewSpread.register(UINib(nibName: String(describing: TextFiledCellXib.self), bundle: nil), forCellWithReuseIdentifier: String(describing: TextFiledCellXib.self))
        viewSpread.register(UINib(nibName: String(describing: StatusPassFailedXib.self), bundle: nil), forCellWithReuseIdentifier: String(describing: StatusPassFailedXib.self))
        
        viewSpread.register(UINib(nibName: String(describing: FileUpdateAndPreviewXib.self), bundle: nil), forCellWithReuseIdentifier: String(describing: FileUpdateAndPreviewXib.self))
        
        

        viewSpread.bounces = false
        viewSpread.dataSource = self
        viewSpread.delegate = self
        fetchData()
    }
    
    func fetchData() {
        loadingStatus = .loading
        reloadCollection()
        
        guard let siteID = UserConstants.shared.selectedSiteID else {
            return
        }
        let apiData = ApiService.statutoryRegister(siteId: siteID)
        APIClient.request(apiData) { [weak self] (result: Result<APIClient.MappableResult<StatutoryModel>, Error>) in
            switch result {
            case .success(let responseResult):
                if case .array(let documentResponse) = responseResult {
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        self.itemArray = documentResponse
                        if !self.itemArray.isEmpty {
                            self.itemArray = self.itemArray.sorted(by: {Int($0.sortOrder ?? "100") ?? 0 < Int($1.sortOrder ?? "100") ?? 0})
                            self.lblDutiesIdentified.text = String(self.itemArray.filter({ item in
                                (item.required ?? false) == true
                            }).count)
                            self.lblDutiesIMeet.text = String(self.itemArray.filter({ item in
                                item.status?.lowercased() == "Passed".lowercased()
                            }).count)
                            self.lblDutiesIdNotMeet.text = String(self.itemArray.filter({ item in
                                (item.required ?? false) == true
                            }).count - self.itemArray.filter({ item in
                                item.status?.lowercased() == "Passed".lowercased()
                            }).count)
                        }
                        self.loadingStatus = self.itemArray.isEmpty ? .noResponse : .default
                        self.reloadCollection()
                    }
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                self?.loadingStatus = .failed
                self?.reloadCollection()
            }
        }
    }
    
    func updateManeg(item :StatutoryModel, ind: Int) {
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false // if you dont want the close button use false
        )
        let scl = SCLAlertView(appearance: appearance)
        scl.showWait("", subTitle: "please wait...", closeButtonTitle: "")
        item.checkStatus { status in
            item.status = item.required ?? false ? status ?? "" : ""
            let api = ApiService.manageStatutoryRegister(model: item)
            APIClient.request(api) { [weak self] (result: Result<APIClient.MappableResult<StatutoryModel>, Error>) in
                DispatchQueue.main.async { [weak self] in
                    guard let self else {return}
                    switch result {
                    case .success(let responseResult):
                        if case .single(let responseResult) = responseResult {
                            print(responseResult.toJSON())
                            guard let siteID = UserConstants.shared.selectedSiteID else {
                                scl.hideView()
                                return
                            }
                            let apiData = ApiService.statutoryRegister(siteId: siteID)
                            APIClient.request(apiData) { [weak self] (result: Result<APIClient.MappableResult<StatutoryModel>, Error>) in
                                DispatchQueue.main.async { [weak self] in
                                    guard let self else {return}
                                    scl.hideView()
                                    switch result {
                                    case .success(let responseResult):
                                        if case .array(let documentResponse) = responseResult {
                                            DispatchQueue.main.async { [weak self] in
                                                guard let self = self else { return }
                                                self.itemArray = documentResponse
                                                if !self.itemArray.isEmpty {
                                                    self.itemArray = self.itemArray.sorted(by: {($0.id ?? 0) < ($1.id ?? 0)})
                                                    self.lblDutiesIdentified.text = String(self.itemArray.filter({ item in
                                                        (item.required ?? false) == true
                                                    }).count)
                                                    self.lblDutiesIMeet.text = String(self.itemArray.filter({ item in
                                                        item.status?.lowercased() == "Passed".lowercased()
                                                    }).count)
                                                    self.lblDutiesIdNotMeet.text = String(self.itemArray.filter({ item in
                                                        (item.required ?? false) == true
                                                    }).count - self.itemArray.filter({ item in
                                                        item.status?.lowercased() == "Passed".lowercased()
                                                    }).count)
                                                }
                                                self.loadingStatus = self.itemArray.isEmpty ? .noResponse : .default
                                                self.reloadCollection()
                                            }
                                        }
                                    case .failure(let error):
                                        print("Error: \(error.localizedDescription)")
                                        self.loadingStatus = .failed
                                        self
                                            .reloadCollection()
                                    }
                                }
                            }
                        }
                    case .failure(let error):
                        print("Error: \(error.localizedDescription)")
                    }
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
            var stringsArray = [String]()
            stringsArray.append(headerRow[column])
            let maxColumnWidth = getMaxLabelSize(textArray: stringsArray, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 200).width
            return maxColumnWidth
        default:
            break
        }
        if column == 0 {
            var stringsArray = itemArray.compactMap{String($0.sortOrder ?? "100")}
            stringsArray.append(headerRow[column])
            let maxColumnWidth = getMaxLabelSize(textArray: stringsArray, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 200).width
            return maxColumnWidth
        }else if column == 1 {
            var stringsArray = itemArray.compactMap{"(\($0.subType ?? "")) \($0.requirement ?? "")"}
            stringsArray.append(headerRow[column])
            let maxColumnWidth = getMaxLabelSize(textArray: stringsArray, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 200).width
            return max(maxColumnWidth, 155.0+10.0+10.0)
        }else if column == 2 {
            var stringsArray = itemArray.compactMap{"(\($0.subType ?? "")) \($0.requirement ?? "")"}
            return 100
        }else if column == 3 {
            return 200
        }else if column == 4 {
            return 200
        } else if column == 5 {
            return 120
        }else {
            return 150
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
                let font = UIFont(name: .MontserratRegular, size: textFontSize)
                let requirementStringheight = getMaxLabelSize(textArray: ["(\(itemArray[row-1].subType ?? "")) \(itemArray[row-1].requirement ?? "")"], font: font, maxWidth: 200, minHeight: minHeight, heightAddition: heightAddition).height
                
                let secondHeight = itemArray[row-1].type == "Link" ? requirementStringheight+40+10 : requirementStringheight
                
                let textFiledheight = 35+10+10
                
                var hightForDocumnet = 35+10+10 //View and update Documnet
                
                
                if itemArray[row-1].type?.lowercased() == "Link".lowercased() {
                    hightForDocumnet = (itemArray[row-1].files?.isEmpty ?? true)  ? 35+10+10 : 35+10+10
                }else {
                    hightForDocumnet = (itemArray[row-1].files?.isEmpty ?? true)  ? 35+10+10 : 75+5+5
                }
                return CGFloat(max(Int(secondHeight), textFiledheight, hightForDocumnet))
            }
        }
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        if indexPath.row == 0 {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextXib", for: indexPath) as! CellTextXib
            cell.backgroundColor = .white
            cell.lblText.textColor = .black
            if indexPath.section == 0 {
                cell.lblText.textAlignment = .center
            }else {
                cell.lblText.textAlignment = .left
            }
            cellBorderSetUp(cell: cell, isHeader: true)
            cell.lblText.font = UIFont(name: .MontserratSemiBold, size: textFontSize)
            cell.lblText.textColor = UIColor.white
            cell.lblText.backgroundColor = UIColor.clear
            cell.lblText.text = headerRow[indexPath.section]
            return cell
        }else if indexPath.row == 1 && isDataNotRecive {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextXib", for: indexPath) as! CellTextXib
            cellBorderSetUp(cell: cell, isHeader: false)
            cell.lblText.addCorner(value: 0)
            cell.lblText.textAlignment = .left
            cell.lblText.font = UIFont(name: .MontserratRegular, size: textFontSize)
            cell.lblText.textColor = UIColor.black
            cell.lblText.backgroundColor = UIColor.clear
            cell.lblText.text = loadingStatus.rawValue
            if loadingStatus == .noResponse && !itemArray.isEmpty {
                cell.lblText.text = "No search result found!!"
            }
            return cell
        }else if indexPath.section == 0 {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextXib", for: indexPath) as! CellTextXib
            cellBorderSetUp(cell: cell, isHeader: false)
            cell.lblText.addCorner(value: 0)
            if indexPath.section == 0 {
                cell.lblText.textAlignment = .center
            }else {
                cell.lblText.textAlignment = .left
            }
            cell.lblText.font = UIFont(name: .MontserratRegular, size: textFontSize)
            cell.lblText.backgroundColor = UIColor.clear
            cell.lblText.textColor = .appTint
            cell.lblText.text = String(self.itemArray[indexPath.row-1].sortOrder ?? "100")
            return cell
        }else if indexPath.section == 1 {
            if itemArray[indexPath.row-1].type?.lowercased() == "Link".lowercased() {
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextWithBtnXib", for: indexPath) as! CellTextWithBtnXib
                cellBorderSetUp(cell: cell, isHeader: false)
                cell.lblText.addCorner(value: 0)
                cell.lblText.font = UIFont(name: .MontserratRegular, size: textFontSize)
                cell.lblText.textColor = UIColor.black
                cell.lblText.backgroundColor = UIColor.clear
                cell.lblText.text = "(\(itemArray[indexPath.row-1].subType ?? "")) \(itemArray[indexPath.row-1].requirement ?? "")"
                cell.btnViewEvidence.addAction { [weak self] in
                    DispatchQueue.main.async { [weak self] in
                        guard let self else {return}
                        let item = self.itemArray[indexPath.row-1]
                        let vc = siteCheckSB.instantiateViewController(withIdentifier: "SiteCheckVC") as! SiteCheckVC
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
                return cell
            }else {
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextXib", for: indexPath) as! CellTextXib
                cellBorderSetUp(cell: cell, isHeader: false)
                if indexPath.section == 0 {
                    cell.lblText.textAlignment = .center
                }else {
                    cell.lblText.textAlignment = .left
                }
                cell.lblText.addCorner(value: 0)
                cell.lblText.font = UIFont(name: .MontserratRegular, size: textFontSize)
                cell.lblText.textColor = UIColor.black
                cell.lblText.backgroundColor = UIColor.clear
                cell.lblText.text = "(\(itemArray[indexPath.row-1].subType ?? "")) \(itemArray[indexPath.row-1].requirement ?? "")"
                return cell
            }
        }else if indexPath.section == 2 {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "SwiSwitchXib", for: indexPath) as! SwiSwitchXib
            cell.viewSwitch.isOn = itemArray[indexPath.row-1].required ?? false
            cell.viewSwitch.tag = indexPath.row-1
            cell.viewSwitch.addAction { [weak self] isOn in
                DispatchQueue.main.async { [weak self] in
                    guard let self else {return}
                    let item = itemArray[indexPath.row-1]
                    itemArray[indexPath.row-1].required = isOn
                    self.updateManeg(item: itemArray[indexPath.row-1], ind: indexPath.row-1)
                }
            }
            return cell
        }else if indexPath.section == 3 {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "TextFiledCellXib", for: indexPath) as! TextFiledCellXib
            cell.tfView.text = itemArray[indexPath.row-1].residence ?? ""
            cell.tfView.tag = indexPath.row-1
            cell.tfView.delegate = self
            return cell
        }else if indexPath.section == 4 {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "FileUpdateAndPreviewXib", for: indexPath) as! FileUpdateAndPreviewXib
            if itemArray[indexPath.row-1].type?.lowercased() == "Link".lowercased() {
                cell.lblBtntext.text = (itemArray[indexPath.row-1].files?.isEmpty ?? true)  ? "No Document" : "View Document"
                if !(itemArray[indexPath.row-1].files?.isEmpty ?? true) {
                    cell.btnDocument.addAction { [weak self] in
                        DispatchQueue.main.async { [weak self] in
                            guard let self else {return}
                            let item = self.itemArray[indexPath.row-1]
                            let vc =  statutoryRegisterSB.instantiateViewController(withIdentifier: "StatutoryDocumnetVC") as! StatutoryDocumnetVC
                            vc.statutoryCategoryId = itemArray[indexPath.row-1].id ?? 0
                            vc.itemArray = item.files ?? []
                            vc.isShowAddBtn = false
                            vc.homeVC = self
                            self.present(vc, animated: true)
                        }
                    }
                }else {
                    cell.btnDocument.addAction { [weak self] in
                        DispatchQueue.main.async {
                            
                        }
                    }
                }
            }else {
                cell.lblBtntext.text = (itemArray[indexPath.row-1].files?.isEmpty ?? true)  ? "Upload File" : "View or Upload\nNew File"
                cell.btnDocument.addAction { [weak self] in
                    DispatchQueue.main.async { [weak self] in
                        guard let self else {return}
                        if !(itemArray[indexPath.row-1].files?.isEmpty ?? true){
                            let item = self.itemArray[indexPath.row-1]
                            let vc =  statutoryRegisterSB.instantiateViewController(withIdentifier: "StatutoryDocumnetVC") as! StatutoryDocumnetVC
                            vc.statutoryCategoryId = itemArray[indexPath.row-1].id ?? 0
                            vc.itemArray = item.files ?? []
                            vc.homeVC = self
                            self.present(vc, animated: true)
                        }else {
                            let vc =  statutoryRegisterSB.instantiateViewController(withIdentifier: "UploadStatutoryDocVC") as! UploadStatutoryDocVC
                            vc.statutoryCategoryId = itemArray[indexPath.row-1].id ?? 0
                            vc.homeVC = self
                            self.present(vc, animated: true)
                        }
                    }
                }
            }
            return cell
        }else if indexPath.section == 5 {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "StatusPassFailedXib", for: indexPath) as! StatusPassFailedXib
            if let status = itemArray[indexPath.row-1].status, status.lowercased() == "Fail".lowercased() {
                cell.lblDashLable.isHidden = true
                cell.viewPassMain.isHidden = true
                cell.viewFailedMain.isHidden = false
            }else if let status = itemArray[indexPath.row-1].status, status.lowercased() == "Passed".lowercased() {
                cell.lblDashLable.isHidden = true
                cell.viewPassMain.isHidden = false
                cell.viewFailedMain.isHidden = true
            }else {
                cell.lblDashLable.isHidden = false
                cell.viewPassMain.isHidden = true
                cell.viewFailedMain.isHidden = true
            }
            return cell
        }else {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextXib", for: indexPath) as! CellTextXib
            cell.lblText.textColor = .black
            cell.lblText.text = "s:\(indexPath.section),r:\(indexPath.row)"
            cellBorderSetUp(cell: cell, isHeader: false)
            return cell
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let ind = textField.tag
        if ind < itemArray.count {
            let item = itemArray[ind]
            itemArray[ind].residence = textField.text
            let api = ApiService.manageStatutoryRegister(model: item)
            APIClient.request(api) { [weak self] (result: Result<APIClient.MappableResult<StatutoryModel>, Error>) in
                DispatchQueue.main.async { [weak self] in
                    guard let self else {return}
                    switch result {
                    case .success(let responseResult):
                        if case .single(let responseResult) = responseResult {
                            print(responseResult.toJSON())
                        }
                    case .failure(let error):
                        print("Error: \(error.localizedDescription)")
                    }
                }
            }
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
