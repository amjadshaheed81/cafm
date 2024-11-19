//
//  CompanyManagementVC.swift
//  cafm
//
//  Created by Savan Lakhani on 07/10/24.
//

import UIKit
import SpreadsheetView
import SCLAlertView

class CompanyManagementVC: UIViewController {
    
    @IBOutlet weak var companyDetailSpreedSheetView: SpreadsheetView!
    
    @IBOutlet weak var addCompanyBtn: UIButton!
    
    var headerRowArray = ["COMPANY NAME", "EMAIL", "PHONE", "ACTIONS"]
    
    var loadingStatus: LoadingStatus = .loading
    
    var allCompanyResponseArray: [CompanyDetails] = []
    
    var isDataNotReceive : Bool {
        return (loadingStatus == .loading || loadingStatus == .failed || loadingStatus == .noResponse || loadingStatus == .noInternet)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Company Management"
        self.addCompanyBtn.addCorner()
        self.addCompanyBtn.titleLabel?.font = UIFont(name: .MontserratMedium, size: 17.0)
        self.setUpSpreedSheetView()
        self.getAllCompanies()
     }
    
    func setUpSpreedSheetView() {
        self.companyDetailSpreedSheetView.register(UINib(nibName: String(describing: CellTextXib.self), bundle: nil), forCellWithReuseIdentifier: String(describing: CellTextXib.self))
        self.companyDetailSpreedSheetView.register(UINib(nibName: String(describing: UserActionCellXib.self), bundle: nil), forCellWithReuseIdentifier: String(describing: UserActionCellXib.self))
        self.companyDetailSpreedSheetView.bounces = false
        self.companyDetailSpreedSheetView.dataSource = self
        self.companyDetailSpreedSheetView.delegate = self
        self.companyDetailSpreedSheetView.showsHorizontalScrollIndicator = false
        self.companyDetailSpreedSheetView.showsVerticalScrollIndicator = false
        self.companyDetailSpreedSheetView.addCorner()
        self.companyDetailSpreedSheetView.addBorder(color: .gray.withAlphaComponent(0.4))
    }
    
    func getAllCompanies() {
        let apiService = ApiService.getAllCompanies
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<CompanyDetails>, Error>) in
            switch result {
            case .success(let responseResult):
                guard let self = self else { return }
                if case .array(let result) = responseResult {
                    DispatchQueue.main.async {
                        self.loadingStatus = .default
                        self.allCompanyResponseArray = result
                        self.companyDetailSpreedSheetView.reloadData()
                    }
                }else {
                    self.loadingStatus = .failed
                    self.companyDetailSpreedSheetView.reloadData()
                }
            case .failure(let error):
                guard let self = self else { return }
                self.loadingStatus = .failed
                self.companyDetailSpreedSheetView.reloadData()
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    @IBAction func addCompanyAction(_ sender: Any) {
        let vc = CompanyManagementSB.instantiateViewController(withIdentifier: "AddNewCompanyVC") as! AddNewCompanyVC
        self.navigationController?.pushViewController(vc, animated: true)
    }

}

extension CompanyManagementVC: SpreadsheetViewDataSource, SpreadsheetViewDelegate {
    
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return self.headerRowArray.count
    }
    
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        switch self.loadingStatus {
        case .default:
            if !self.allCompanyResponseArray.isEmpty {
                return self.allCompanyResponseArray.count + 1
            }
            return 1 + 1
        case .loading, .failed, .noResponse, .noInternet:
            return 1+1
        }
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        switch loadingStatus {
        case .loading, .failed, .noResponse, .noInternet:
            var stringsArray = ["Loading..."]
            stringsArray.append(headerRowArray[column])
            let maxColumnWidth = getMaxLabelSize(textArray: stringsArray, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 200).width
            return maxColumnWidth
        default:
            var stringsArray = [String]()
            if column == 0 {
                stringsArray = self.allCompanyResponseArray.compactMap{$0.companyName}
            }else if column == 1 {
                stringsArray = self.allCompanyResponseArray.compactMap{$0.email}
            }else if column == 2 {
                stringsArray = self.allCompanyResponseArray.compactMap{$0.phone}
            }
            stringsArray.append(headerRowArray[column])
            if column != 3 {
                let maxColumnWidth = getMaxLabelSize(textArray: stringsArray, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 200).width
                return maxColumnWidth
            }else if column == 3 {
                return 120
            }else {
                return 0
            }
        }
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        switch loadingStatus {
        case .loading, .failed, .noResponse, .noInternet:
            let refSize = CGSize(width: 100, height: 40)
            let heightAddition: CGFloat = 10+10
            let minHeight = refSize.height-heightAddition
            let textArray = self.headerRowArray
            let font = UIFont(name: .MontserratSemiBold, size: textFontSize)
            let headerHeight = getMaxLabelSize(textArray: textArray, font: font, maxWidth: 200, minHeight: minHeight, heightAddition: heightAddition).height
            return headerHeight
        default:
            if row == 0 {
                let refSize = CGSize(width: 100, height: 40)
                let heightAddition: CGFloat = 10+10
                let minHeight = refSize.height-heightAddition
                let textArray = self.headerRowArray
                let font = UIFont(name: .MontserratSemiBold, size: textFontSize)
                let headerHeight = getMaxLabelSize(textArray: textArray, font: font, maxWidth: 200, minHeight: minHeight, heightAddition: heightAddition).height
                return headerHeight
            }else {
                let refSize = CGSize(width: 100, height: 50)
                let heightAddition: CGFloat = 10+10
                let minHeight = refSize.height-heightAddition
                var optionArray = [String?]()
                optionArray.append(contentsOf: self.allCompanyResponseArray.compactMap{$0.companyName})
                optionArray.append(contentsOf: self.allCompanyResponseArray.compactMap{$0.email})
                optionArray.append(contentsOf: self.allCompanyResponseArray.compactMap{$0.phone})
                optionArray.append(contentsOf: headerRowArray)
                let textArray = optionArray.compactMap{$0}
                let font = UIFont(name: .MontserratRegular, size: textFontSize)
                let headerHeight = getMaxLabelSize(textArray: textArray, font: font, maxWidth: 200, minHeight: minHeight, heightAddition: heightAddition).height
                return headerHeight
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
            cell.lblText.text = headerRowArray[indexPath.section]
            return cell
        } else if indexPath.row == 1 && isDataNotReceive {
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
            if loadingStatus == .noResponse && !self.allCompanyResponseArray.isEmpty {
                cell.lblText.text = "No result found!!"
            }
            return cell
        }else if indexPath.section == 0 || indexPath.section == 1 || indexPath.section == 2 {
            
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextXib", for: indexPath) as! CellTextXib
            cell.backgroundColor = .white
            cell.lblText.textColor = .black
            cell.gridlines.top = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
            cell.gridlines.bottom = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
            cell.gridlines.left = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
            cell.gridlines.right = .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
            cell.lblText.addCorner(value: 0)
            cell.lblText.font = UIFont(name: .MontserratRegular, size: textFontSize)
            cell.lblText.backgroundColor = UIColor.clear
            
            if indexPath.section == 0 {
                cell.lblText.text = self.allCompanyResponseArray[indexPath.row-1].companyName
            }else if indexPath.section == 1 {
                cell.lblText.text = self.allCompanyResponseArray[indexPath.row-1].email
            }else if indexPath.section == 2 {
                cell.lblText.text = self.allCompanyResponseArray[indexPath.row-1].phone
            }
            return cell
        }else if indexPath.section == 3 {
            let cell = spreadsheetView.dequeueReusableCell(
                withReuseIdentifier: "UserActionCellXib",
                for: indexPath
            ) as! UserActionCellXib
            cell.gridlines.top = 
                .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
            cell.gridlines.bottom = 
                .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
            cell.gridlines.left = 
                .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
            cell.gridlines.right = 
                .solid(width: 1, color: UIColor.black.withAlphaComponent(0.175))
            cell.view.isHidden = true
            cell.lockView.isHidden = true
            
            cell.stackViewLeftCons.constant = 15
            cell.stackViewRightCons.constant = 15
            
            cell.btnEditView.addAction { [weak self] in
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    let row = indexPath.row-1
                    self.editCompany(companyDetail: allCompanyResponseArray[row])
                }
            }
            
            cell.btnDelete.addAction { [weak self] in
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    let row = indexPath.row-1
                    if let companyId = self.allCompanyResponseArray[row].companyId {
                        self.deleteCompany(id:companyId)
                    }
                }
            }
            return cell
        }
        let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextXib", for: indexPath) as! CellTextXib
        cell.lblText.text = "s:\(indexPath.section),r:\(indexPath.row)"
        return cell
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, didSelectItemAt indexPath: IndexPath) {
    }
    
    func mergedCells(in spreadsheetView: SpreadsheetView) -> [CellRange] {
        switch self.loadingStatus {
        case .default:
            return []
        case .loading, .failed, .noResponse, .noInternet:
            let totalColumn = self.headerRowArray.count
            return [CellRange(from: IndexPath(row: 1, column: 0), to: IndexPath(row: 1, column: totalColumn-1))]
        }
    }
    
    func frozenRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 1
    }
    
}

extension CompanyManagementVC {
    
    func editCompany(companyDetail: CompanyDetails) {
        let vc = CompanyManagementSB.instantiateViewController(withIdentifier: "AddNewCompanyVC") as! AddNewCompanyVC
        vc.companyDetail = companyDetail
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func deleteCompany(id: Int) {
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false // if you dont want the close button use false
        )
        let scl = SCLAlertView(appearance: appearance)
        scl.showWait("", subTitle: "please wait...", closeButtonTitle: "")

        let apiService = ApiService.deleteCompanyAPI(id: id)
        APIClient.requestWithCode(apiService) { [weak self] isSucess, code in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                scl.hideView()
                if isSucess, code == 200 {
                    scl.hideView()
                    self.getAllCompanies()
                }else {
                    SCLAlertView().showError("Error", subTitle: "Oops! please try again")
                }
            }
        }
    }
    
}
