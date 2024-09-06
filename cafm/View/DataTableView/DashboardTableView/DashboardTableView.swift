//
//  DashboardTableView.swift
//  cafm
//
//  Created by NS on 18/08/24.
//
//

import UIKit
import SpreadsheetView

let dashboardPrimaryTextSize: CGFloat = isiPadDevice ? 16 : 15

class DashboardTableView: NibView {
    
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var viewAllBtn: SecondaryButton!
    @IBOutlet weak var spreadsheetContainerView: UIView!
    @IBOutlet weak var spreadsheetView: SpreadsheetView!
    @IBOutlet weak var spreadsheetViewWidth: NSLayoutConstraint!
    
    weak var delegate: DashboardTableViewDelegate?
    
    var tableData: [DashboardTableData] = []
    var loadingStatus: LoadingStatus = .default
    var isViewAll: Bool = false
    
    var title: String? {
        get {
            return titleLbl.text
        }
        set {
            self.titleLbl.text = newValue
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.spreadsheetView.addCorner(value: 12)
        self.spreadsheetView.addBorder(width: 1, color: UIColor(appColor: .Separator2))
        
        self.spreadsheetView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.spreadsheetView.showsVerticalScrollIndicator = false
        self.spreadsheetView.showsHorizontalScrollIndicator = false
        self.spreadsheetView.bounces = false
        //self.spreadsheetView.intercellSpacing = CGSize.zero
        //self.spreadsheetView.gridStyle = .solid(width: 1, color: UIColor(appColor: .Separator2))
        
        self.spreadsheetView.register(UINib(nibName: DashboardTableCell.className(), bundle: nil), forCellWithReuseIdentifier: DashboardTableCell.className())
        self.spreadsheetView.dataSource = self
        self.spreadsheetView.delegate = self
    }
    
    func reloadSpreadsheetView() {
        self.spreadsheetView.reloadData()
        self.viewAllBtn.isHidden = !self.loadingStatus.hasData
        let spreadsheetSize = self.spreadsheetView.contentSize
        let width = min(self.frame.width-20, spreadsheetSize.width)
        self.spreadsheetViewWidth.constant = width
        self.spreadsheetView.frame.size.width = width
        let height = self.titleView.frame.height+14+spreadsheetSize.height+41
        self.delegate?.dashboardTableViewHeightDidChange(self, height: height)
    }
    
    @IBAction func viewAllBtnClicked(_ sender: SecondaryButton) {
        self.delegate?.dashboardTableViewViewAllBtnClicked(self, sender: sender)
    }
    
}

extension DashboardTableView: SpreadsheetViewDataSource, SpreadsheetViewDelegate {
    
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return self.tableData.count
    }
    
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        switch self.loadingStatus {
        case .default:
            if !self.tableData.isEmpty, let totalRow = self.tableData.max(by: { $0.columnData.count < $1.columnData.count })?.columnData.count {
                if totalRow == 0 {
                    return 1+1
                }
                return self.isViewAll ? max(5, totalRow)+1 : 5+1
            }
            return 0
        case .loading, .failed, .noResponse, .noInternet:
            return 1+1
        }
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: DashboardTableCell.className(), for: indexPath) as! DashboardTableCell
        if self.tableData.count > indexPath.section {
            let item = self.tableData[indexPath.section]
            if indexPath.row == 0 {
                cell.setGridLines(width: 1, color: UIColor(appColor: .AppTint))
                
                cell.backgroundColor = UIColor(appColor: .AppTint)
                cell.mainLbl.addCorner(value: 0)
                cell.mainLbl.font = UIFont(name: .MontserratSemiBold, size: dashboardPrimaryTextSize)
                cell.mainLbl.textColor = UIColor.white
                cell.mainLbl.backgroundColor = UIColor.clear
                
                cell.mainLbl.text = item.columnHeaderText
            }else {
                cell.setGridLines(width: 1, color: UIColor(appColor: .Separator2))
                
                cell.backgroundColor = UIColor.white
                cell.mainLbl.addCorner(value: 0)
                cell.mainLbl.font = UIFont(name: .MontserratRegular, size: dashboardPrimaryTextSize)
                cell.mainLbl.textColor = UIColor.black
                cell.mainLbl.backgroundColor = UIColor.clear
                
                switch self.loadingStatus {
                case .default:
                    let index = indexPath.row-1
                    if item.columnData.count > index {
                        let cellItem = item.columnData[index]
                        cell.mainLbl.text = cellItem.text
                        
                        if item.isStatusData {
                            cell.mainLbl.addCorner()
                            cell.mainLbl.font = UIFont(name: .MontserratSemiBold, size: dashboardPrimaryTextSize)
                            cell.mainLbl.textColor = cellItem.textColor ?? UIColor.black
                            cell.mainLbl.backgroundColor = cellItem.textBGColor ?? UIColor.clear
                        }
                    }else {
                        cell.mainLbl.text = ""
                    }
                case .loading, .failed, .noResponse, .noInternet:
                    cell.mainLbl.text = self.loadingStatus.rawValue
                }
            }
        }
        return cell
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, didSelectItemAt indexPath: IndexPath) {
        if self.tableData.count > indexPath.section {
            let item = self.tableData[indexPath.section]
            if indexPath.row == 0 {
            }else {
                switch self.loadingStatus {
                case .default:
                    break
                case .loading, .failed, .noResponse, .noInternet:
                    self.delegate?.dashboardTableViewDidTapForRetry(self, status: self.loadingStatus)
                    break
                }
            }
        }
    }
    
    func mergedCells(in spreadsheetView: SpreadsheetView) -> [CellRange] {
        if !self.loadingStatus.hasData {
            let totalColumn = self.tableData.count
            return [CellRange(from: IndexPath(row: 1, column: 0), to: IndexPath(row: 1, column: totalColumn-1))]
        }
        return []
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        if self.tableData.count > column {
            let item = self.tableData[column]
            
            let refSize = CGSize(width: 12+30+12, height: 10+18+10)
            let widthAddition: CGFloat = 12+12
            let minWidth = refSize.width-widthAddition
            let maxWidth: CGFloat = isiPadDevice ? 300 : 200
            
            let headerText = item.columnHeaderText
            let headerWidth = getLabelSize(text: headerText, font: UIFont(name: .MontserratSemiBold, size: dashboardPrimaryTextSize), minWidth: minWidth, widthAddition: widthAddition, maxWidth: maxWidth).width
            
            if !self.loadingStatus.hasData {
                let maxColumnWidth = getLabelSize(text: self.loadingStatus.rawValue, font: UIFont(name: .MontserratRegular, size: dashboardPrimaryTextSize), minWidth: minWidth, widthAddition: widthAddition).width
                return max(headerWidth, maxColumnWidth/CGFloat(self.tableData.count))
            }else {
                let textArray = item.columnData.compactMap { $0.text }
                if item.isStatusData {
                    let refSize = CGSize(width: 12+8+10+8+12, height: 10+4+18+4+10)
                    let widthAddition: CGFloat = 12+8+8+12
                    let minWidth = refSize.width-widthAddition
                    
                    let maxColumnWidth = getMaxLabelSize(textArray: textArray, font: UIFont(name: .MontserratSemiBold, size: dashboardPrimaryTextSize), minWidth: minWidth, widthAddition: widthAddition, maxWidth: maxWidth).width
                    return max(headerWidth, maxColumnWidth)
                }else {
                    let maxColumnWidth = getMaxLabelSize(textArray: textArray, font: UIFont(name: .MontserratRegular, size: dashboardPrimaryTextSize), minWidth: minWidth, widthAddition: widthAddition, maxWidth: maxWidth).width
                    return max(headerWidth, maxColumnWidth)
                }
            }
        }
        return 0
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        let refSize = CGSize(width: 100, height: 40)
        let heightAddition: CGFloat = row == 0 || !self.tableData.contains { $0.isStatusData } ? 10+10 : 10+4+4+10
        let minHeight = refSize.height-heightAddition
        let maxWidth: CGFloat = isiPadDevice ? 300 : 200
        
        if row == 0 {
            let textArray = self.tableData.compactMap { $0.columnHeaderText }
            let font = UIFont(name: .MontserratSemiBold, size: dashboardPrimaryTextSize)
            let headerHeight = getMaxLabelSize(textArray: textArray, font: font, maxWidth: maxWidth, minHeight: minHeight, heightAddition: heightAddition).height
            return headerHeight
        }else {
            if !self.loadingStatus.hasData {
                return getLabelSize(text: self.loadingStatus.rawValue, font: UIFont(name: .MontserratRegular, size: dashboardPrimaryTextSize), minHeight: minHeight, heightAddition: heightAddition).height
            }else {
                let refSize1 = CGSize(width: 12+8+10+8+12, height: 10+4+18+4+10)
                let heightAddition1: CGFloat = 10+4+4+10
                let minHeight1 = refSize1.height-heightAddition1
                
                let index = row-1
                
                let textArray = self.tableData.filter({ !$0.isStatusData }).compactMap { data in
                    if data.columnData.count > index {
                        let item = data.columnData[index]
                        return item.text
                    }
                    return nil
                }
                let textArray1 = self.tableData.filter({ $0.isStatusData }).compactMap { data in
                    if data.columnData.count > index {
                        let item = data.columnData[index]
                        return item.text
                    }
                    return nil
                }
                
                let maxHeight = getMaxLabelSize(textArray: textArray, font: UIFont(name: .MontserratRegular, size: dashboardPrimaryTextSize), maxWidth: maxWidth, minHeight: minHeight, heightAddition: heightAddition).height
                let maxHeight1 = getMaxLabelSize(textArray: textArray1, font: UIFont(name: .MontserratSemiBold, size: dashboardPrimaryTextSize), maxWidth: maxWidth, minHeight: minHeight1, heightAddition: heightAddition1).height
                return max(maxHeight, maxHeight1)
            }
        }
    }
    
}

protocol DashboardTableViewDelegate: AnyObject {
    func dashboardTableViewHeightDidChange(_ view: DashboardTableView, height: CGFloat)
    func dashboardTableViewDidTapForRetry(_ view: DashboardTableView, status: LoadingStatus)
    func dashboardTableViewViewAllBtnClicked(_ view: DashboardTableView, sender: SecondaryButton)
}
