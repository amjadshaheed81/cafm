//
//  EnergyReadingVC.swift
//  cafm
//
//  Created by ShitaRam on 12/10/24.
//

import UIKit
import SpreadsheetView
import SCLAlertView

class EnergyReadingVC: UIViewController, SpreadsheetViewDataSource, SpreadsheetViewDelegate {
    
    @IBOutlet weak var spreadView: SpreadsheetView!
    
    var headerRow: [String] = ["Reading Date", "Reading", "Usage", "Action"]
    
    var itemArray: [Reading] = []
    var loadingStatus: LoadingStatus = .default
    
    var item: Energy?
    weak var homeVC: SiteReadingsCostVC?
    
    var isDataNotRecive : Bool {
        return (loadingStatus == .loading || loadingStatus == .failed || loadingStatus == .noResponse || loadingStatus == .noInternet)
    }
    
    weak var delegate : ReloadEnegyCostDelgate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadingStatus = itemArray.isEmpty ? .noResponse : .default
        spreadView.register(UINib(nibName: String(describing: CellTextXib.self), bundle: nil), forCellWithReuseIdentifier: String(describing: CellTextXib.self))
        spreadView.register(UINib(nibName: String(describing: MoreEditOption.self), bundle: nil), forCellWithReuseIdentifier: String(describing: MoreEditOption.self))
        spreadView.bounces = false
        spreadView.dataSource = self
        spreadView.delegate = self
        self.isModalInPresentation = true
    }
    
    
    @IBAction func btbAddClick(_ sender: UIButton) {
        let vc = siteReadingsCostSB.instantiateViewController(withIdentifier: "AddEnergyReadingsVC") as! AddEnergyReadingsVC
        vc.item = self.item
        vc.homeVC = self
        self.present(vc, animated: true)
    }
    
    func handleFetchData() {
        self.homeVC?.fetchData()
        self.dismiss(animated: true)
    }
    
    @IBAction func btnCloseClick(_ sender: Any) {
        self.dismiss(animated: true)
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
        if column == 0 || column == 1 || column == 2 {
            var stringsArray = [String]()
            if column == 0 {
                stringsArray = itemArray.compactMap{convertDateString($0.readingDate)}
                stringsArray.append(headerRow[column])
            }else if column == 1 {
                stringsArray = itemArray.compactMap{"\(String(format: "%.2f", $0.readingValue ?? 0.0)) \($0.readingUnit ?? "")"}
                stringsArray.append(headerRow[column])
            }else if column == 2 {
                stringsArray = itemArray.compactMap{"\(String(format: "%.2f", $0.readingValue ?? 0.0)) \($0.readingUnit ?? "")"}
                stringsArray.append(headerRow[column])
            }
            let maxColumnWidth = getMaxLabelSize(textArray: stringsArray, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 200).width
            return maxColumnWidth
        }
        return 95
    }
    
    func calculateValue(ind: Int) -> String {
        if ind == 0 {
            return "\(String(format: "%.2f", itemArray[ind].readingValue ?? 0.0)) \(itemArray[ind].readingUnit ?? "")"
        }else if let current = itemArray[ind].readingValue, let previous = itemArray[ind-1].readingValue {
            let unit = current-previous
            return "\(String(format: "%.2f", unit)) \(itemArray[ind].readingUnit ?? "")"
        }
        return "\(String(format: "%.2f", itemArray[ind].readingValue ?? 0.0)) \(itemArray[ind].readingUnit ?? "")"
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
                    convertDateString(itemArray[row-1].readingDate),
                    "\(String(format: "%.2f", itemArray[row-1].readingValue ?? 0.0)) \(itemArray[row-1].readingUnit ?? "")",
                    calculateValue(ind: row-1),
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
        }else if indexPath.section == 0 || indexPath.section == 1 || indexPath.section == 2 {
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
                text = convertDateString(itemArray[indexPath.row-1].readingDate)
            }else if indexPath.section == 1 {
                text = "\(String(format: "%.2f", itemArray[indexPath.row-1].readingValue ?? 0.0)) \(itemArray[indexPath.row-1].readingUnit ?? "")"
            }else if indexPath.section == 2 {
                text = calculateValue(ind: indexPath.row-1)
            }
            cell.lblText.text = text
            return cell
        }else if indexPath.section == 3 {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "MoreEditOption", for: indexPath) as! MoreEditOption
            cellBorderSetUp(cell: cell, isHeader: false)
            
            cell.imgView.image = UIImage(systemName: "trash")
            cell.btnAction.addAction { [weak self] in
                DispatchQueue.main.async { [weak self] in
                    let appearance = SCLAlertView.SCLAppearance(
                        showCloseButton: false // if you dont want the close button use false
                    )
                    let scl = SCLAlertView(appearance: appearance)
                    scl.showWait("", subTitle: "please wait...", closeButtonTitle: "")
                    guard let self else {return}
                    let api = ApiService.deleteEnegySubReading(readingId: itemArray[indexPath.row-1].readingId ?? 0)
                    APIClient.requestWithCode(api) { [weak self] isSucess, code in
                        DispatchQueue.main.async { [weak self] in
                            guard let self else {return}
                            scl.hideView()
                            if isSucess, code == 200 {
                                let sclAlertView = SCLAlertView()
                                self.delegate?.reloadData()
                                self.dismiss(animated: true)
                            }else {
                                SCLAlertView().showError("Error", subTitle: "Oops! please try again")
                            }
                        }
                    }
                }
            }
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
            
        }
    }
    
    func frozenRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 1
    }

    
}
