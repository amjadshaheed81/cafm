//
//  NotificationListVC.swift
//  cafm
//
//  Created by ShitaRam on 26/10/24.
//

import UIKit
import SpreadsheetView

class NotificationListVC: UIViewController, SpreadsheetViewDataSource, SpreadsheetViewDelegate{
    
    @IBOutlet weak var spreadView: SpreadsheetView!
    
    var headerRow: [String] = ["Notification", "Date"]
    
    var itemArray: [PreAction] = []
    var loadingStatus: LoadingStatus = .loading
    
    var isDataNotRecive : Bool {
        return (loadingStatus == .loading || loadingStatus == .failed || loadingStatus == .noResponse || loadingStatus == .noInternet)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var titleStr = "Notifications"
        if let siteName = UserConstants.shared.selectedSiteName {
            titleStr += " - \(siteName)"
        }
        self.title = titleStr
        spreadView.bounces = false
        spreadView.dataSource = self
        spreadView.delegate = self
        spreadView.register(UINib(nibName: String(describing: CellTextXib.self), bundle: nil), forCellWithReuseIdentifier: String(describing: CellTextXib.self))
        spreadView.register(UINib(nibName: String(describing: MoreEditOption.self), bundle: nil), forCellWithReuseIdentifier: String(describing: MoreEditOption.self))
        fetchData()
    }
    
    func fetchData() {
        loadingStatus = .loading
        reloadCollection()
        guard let siteID = UserConstants.shared.selectedSiteID else {
            return
        }
        let apiService = ApiService.actionSummaryAPI(siteId: siteID)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<PreActionsResponse>, Error>) in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                switch result {
                case .success(let mappableResult):
                    switch mappableResult {
                    case .single(let single):
                        if let array = single.preActions?.filter({ $0.status == "Pending Action" || $0.status == "Closed" }) {
                            itemArray = array
                            loadingStatus = self.itemArray.isEmpty ? .noResponse : .default
                        }else {
                            self.loadingStatus = .failed
                        }
                        break
                    case .array:
                        self.loadingStatus = .failed
                        break
                    }
                case .failure(let error):
                    print(apiService.api(), "Error:", error.localizedDescription)
                    self.loadingStatus = .failed
                }
                self.reloadCollection()
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
            
            return column == 0 ? min(screenWidth, screenHeight)-113.0-4 : 113.0
        default:
            break
        }
        if column == 0 || column == 1  {
            var stringsArray = [String]()
            if column == 0 {
                stringsArray = itemArray.compactMap{$0.description}
                stringsArray.append(headerRow[column])
                return min(screenWidth, screenHeight)-113.0-4
            }else if column == 1 {
                stringsArray = itemArray.compactMap({ $0.raisedDate?.transformToNewDateString(dateFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSSSS", newDateFormat: "dd/MM/yyyy") })
                stringsArray.append(headerRow[column])
                return 113.0
            }
            let maxColumnWidth = getMaxLabelSize(textArray: stringsArray, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: min(screenWidth, screenHeight)-113.0-4, widthAddition: 12+12, maxWidth: 200).width
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
                    itemArray[row-1].description,
                    itemArray[row-1].raisedDate?.transformToNewDateString(dateFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSSSS", newDateFormat: "dd/MM/yyyy"),
                ])
                let textArray = optionArray.compactMap{$0}
                let font = UIFont(name: .MontserratRegular, size: textFontSize)
                let headerHeight = getMaxLabelSize(textArray: textArray, font: font, maxWidth: min(screenWidth, screenHeight)-113.0-4, minHeight: minHeight, heightAddition: heightAddition).height
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
        }else if indexPath.section == 0 || indexPath.section == 1 {
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
                text = itemArray[indexPath.row-1].description
            }else if indexPath.section == 1 {
                text = itemArray[indexPath.row-1].raisedDate?.transformToNewDateString(dateFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSSSS", newDateFormat: "dd/MM/yyyy")
            }
            cell.lblText.text = text
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
