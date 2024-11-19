//
//  StatutoryDocumnetVC.swift
//  cafm
//
//  Created by ShitaRam on 12/10/24.
//

import UIKit
import SpreadsheetView

class StatutoryDocumnetVC: UIViewController, SpreadsheetViewDataSource, SpreadsheetViewDelegate {
    
    @IBOutlet weak var spreadView: SpreadsheetView!
    
    var headerRow: [String] = ["File", "Folder", "Version", "Date", "Expiry", "Author", "Ref No."]
    
    var itemArray: [File] = []
    var loadingStatus: LoadingStatus = .default
    
    weak var homeVC: StatutoryRegisterVC?
    
    var isDataNotRecive : Bool {
        return (loadingStatus == .loading || loadingStatus == .failed || loadingStatus == .noResponse || loadingStatus == .noInternet)
    }
    
    var statutoryCategoryId = 0
    
    @IBOutlet weak var BtnAdd: UIButton!
    
    weak var delegate : ReloadEnegyCostDelgate?

    var isShowAddBtn = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.BtnAdd.isHidden = !isShowAddBtn
        self.loadingStatus = itemArray.isEmpty ? .noResponse : .default
        spreadView.register(UINib(nibName: String(describing: CellTextXib.self), bundle: nil), forCellWithReuseIdentifier: String(describing: CellTextXib.self))
        spreadView.register(UINib(nibName: String(describing: MoreEditOption.self), bundle: nil), forCellWithReuseIdentifier: String(describing: MoreEditOption.self))
        
        spreadView.register(UINib(nibName: String(describing: CellTextSelectionXib.self), bundle: nil), forCellWithReuseIdentifier: String(describing: CellTextSelectionXib.self))

        spreadView.bounces = false
        spreadView.dataSource = self
        spreadView.delegate = self
        self.isModalInPresentation = true
    }
    
    @IBAction func btbAddClick(_ sender: UIButton) {
        let vc =  statutoryRegisterSB.instantiateViewController(withIdentifier: "UploadStatutoryDocVC") as! UploadStatutoryDocVC
        vc.statutoryCategoryId = statutoryCategoryId
        vc.statDocVC = self
        self.present(vc, animated: true)
    }
    
    func handleNewTabbleFetch() {
        DispatchQueue.main.async { [weak self] in
            self?.homeVC?.fetchData()
            self?.dismiss(animated: true)
        }
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
        if column == 0 || column == 1 || column == 2 || column == 3 || column == 4 || column == 5 || column == 6 {
            var stringsArray = [String]()
            if column == 0 {
                stringsArray = itemArray.compactMap{$0.name}
                stringsArray.append(headerRow[column])
            }else if column == 1 {
                stringsArray = itemArray.compactMap{$0.folderName}
                stringsArray.append(headerRow[column])
            }else if column == 2 {
                stringsArray = itemArray.compactMap{String($0.fileVersion ?? 0)}
                stringsArray.append(headerRow[column])
            }else if column == 3 {
                stringsArray = itemArray.compactMap{convertDateString($0.issueDate)}
                stringsArray.append(headerRow[column])
            }else if column == 4 {
                stringsArray = itemArray.compactMap{convertDateString($0.expiryDate)}
                stringsArray.append(headerRow[column])
            }else if column == 5 {
                stringsArray = itemArray.compactMap{$0.uploaderUserName}
                stringsArray.append(headerRow[column])
            }else if column == 6 {
                stringsArray = itemArray.compactMap{String($0.reviewerUserId ?? 0)}
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
                    itemArray[row-1].name,
                    itemArray[row-1].folderName,
                    String(itemArray[row-1].fileVersion ?? 0),
                    convertDateString(itemArray[row-1].issueDate),
                    convertDateString(itemArray[row-1].expiryDate),
                    itemArray[row-1].uploaderUserName,
                    String(itemArray[row-1].reviewerUserId ?? 0)
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
        }else if indexPath.section == 0 {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextSelectionXib", for: indexPath) as! CellTextSelectionXib
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
            cell.lblText.textColor = UIColor(resource: .appTint)
            cell.lblText.text = itemArray[indexPath.row-1].name
            cell.btnDoc.addAction { [weak self] in
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    //let vc = documnetSB.instantiateViewController(withIdentifier: "FilePreviewVC") as! FilePreviewVC
                    let urlString = itemArray[indexPath.row-1].fileBlobUrl ?? ""
                    //vc.url = URL(string: urlString)
                    //self.present(vc, animated: true)
                    let vc = generalSB.instantiateViewController(withIdentifier: "FileViewVC") as! FileViewVC
                    vc.fileURL = URL(string: urlString)
                    let nav = UINavigationController(rootViewController: vc)
                    self.present(nav, animated: true)
                }
            }
            return cell
        }else if indexPath.section == 1 || indexPath.section == 2 || indexPath.section == 3 || indexPath.section == 4 || indexPath.section == 5 || indexPath.section == 6 {
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
                cell.lblText.textColor = UIColor(resource: .appTint)
                text = itemArray[indexPath.row-1].name
            }else if indexPath.section == 1 {
                text = itemArray[indexPath.row-1].folderName
            }else if indexPath.section == 2 {
                text = String(itemArray[indexPath.row-1].fileVersion ?? 0)
            }else if indexPath.section == 3 {
                text = convertDateString(itemArray[indexPath.row-1].issueDate)
            }else if indexPath.section == 4 {
                text = convertDateString(itemArray[indexPath.row-1].expiryDate)
            }else if indexPath.section == 5 {
                text = itemArray[indexPath.row-1].uploaderUserName
            }else if indexPath.section == 6 {
                text = String(itemArray[indexPath.row-1].reviewerUserId ?? 0)
            }
            cell.lblText.text = text
            return cell
        }else {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextXib", for: indexPath) as! CellTextXib
            cell.lblText.text = "s:\(indexPath.section),r:\(indexPath.row)"
            return cell
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
