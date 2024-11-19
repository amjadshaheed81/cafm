//
//  CategoriesManagementVC.swift
//  cafm
//
//  Created by ShitaRam on 31/10/24.
//

import UIKit
import ObjectMapper
import SpreadsheetView

class CategoriesManagementVC: UIViewController, SpreadsheetViewDataSource, SpreadsheetViewDelegate {
    
    @IBOutlet weak var viewSpread: SpreadsheetView!
    
    var itemArray = [APiCategoryTypeModel]()
    var loadingStatus: LoadingStatus = .loading
    
    var headerRow: [String] = ["Type", "Sub type", "Category","Action"]
    
    var isDataNotRecive : Bool {
        return (loadingStatus == .loading || loadingStatus == .failed || loadingStatus == .noResponse || loadingStatus == .noInternet)
    }
    
    var newFixItemArray = [CategoriesManageModel]()
    
    struct CategoriesManageModel {
        var type: String?
        var subtype: String?
        var category: String?
        var ind: Int
    }
    
    func setInd() {
        for (ind,type) in itemArray.enumerated() {
            if ind == 0 {
                itemArray[ind].indRage.0 = 1
            }else {
                itemArray[ind].indRage.0 = itemArray[ind-1].indRage.1+1
            }
            for (sunInd, SubType) in type.subTypeArray.enumerated() {
                if sunInd == 0 {
                    itemArray[ind].subTypeArray[sunInd].indRage.0 = itemArray[ind].indRage.0
                    if itemArray[ind].subTypeArray[sunInd].subTypeCategoryArray.isEmpty {
                        itemArray[ind].subTypeArray[sunInd].indRage.1 = itemArray[ind].subTypeArray[sunInd].indRage.0
                    }else {
                        itemArray[ind].subTypeArray[sunInd].indRage.1 = itemArray[ind].subTypeArray[sunInd].indRage.0 + itemArray[ind].subTypeArray[sunInd].subTypeCategoryArray.count-1
                    }
                }else {
                    itemArray[ind].subTypeArray[sunInd].indRage.0 = itemArray[ind].subTypeArray[sunInd-1].indRage.1+1
                    if itemArray[ind].subTypeArray[sunInd].subTypeCategoryArray.isEmpty {
                        itemArray[ind].subTypeArray[sunInd].indRage.1 = itemArray[ind].subTypeArray[sunInd].indRage.0
                    }else {
                        itemArray[ind].subTypeArray[sunInd].indRage.1 = itemArray[ind].subTypeArray[sunInd].indRage.0 + itemArray[ind].subTypeArray[sunInd].subTypeCategoryArray.count-1
                    }
                }
            }
            itemArray[ind].indRage.1 = itemArray[ind].subTypeArray.last?.indRage.1 ?? itemArray[ind].indRage.0
        }
        newFixItemArray = []
        for (ind,type) in itemArray.enumerated() {
            if !type.subTypeArray.isEmpty {
                for (sunInd, subType) in type.subTypeArray.enumerated() {
                    if !subType.subTypeCategoryArray.isEmpty {
                        for category in subType.subTypeCategoryArray {
                            newFixItemArray.append(CategoriesManageModel(type: type.type?.lovValue, subtype: subType.subType?.lovValue, category: category.lovValue, ind: ind))
                        }
                    }else {
                        newFixItemArray.append(CategoriesManageModel(type: type.type?.lovValue, subtype: subType.subType?.lovValue, category: nil, ind: ind))
                    }
                }
            }else {
                newFixItemArray.append(CategoriesManageModel(type: type.type?.lovValue, subtype: nil, category: nil, ind: ind))
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Categories Management"
        viewSpread.bounces = false
        viewSpread.dataSource = self
        viewSpread.delegate = self
        viewSpread.register(UINib(nibName: String(describing: CellTextForCatXib.self), bundle: nil), forCellWithReuseIdentifier: String(describing: CellTextForCatXib.self))
        viewSpread.register(UINib(nibName: String(describing: MoreEditCatOption.self), bundle: nil), forCellWithReuseIdentifier: String(describing: MoreEditCatOption.self))
        fetchData()
        let rightBarButton = UIBarButtonItem(title: "  Add New", style: .plain, target: self, action: #selector(buttonTapped))
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    @objc func buttonTapped() {
        print("Navigation bar button tapped")
        let vc = categoriesManagementSB.instantiateViewController(withIdentifier: "AddNewCategoryAdminVC") as! AddNewCategoryAdminVC
        vc.homeVC = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func fetchData() {
        self.loadingStatus = .loading
        reloadCollection()
        let siteType = ApiService.getSITE_CHECK_TYPE
        APIClient.request(siteType) { [weak self] (result: Result<APIClient.MappableResult<CategoriesManagementModel>, Error>) in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                switch result {
                case .success(let mappableResult):
                    switch mappableResult {
                    case .array(let array):
                        itemArray = []
                        for item in array {
                            let elemnet = APiCategoryTypeModel()
                            elemnet.type = item
                            itemArray.append(elemnet)
                        }
                        let siteSubType = ApiService.getSITE_CHECK_SUB_TYPE
                        APIClient.request(siteSubType) { [weak self] (result: Result<APIClient.MappableResult<CategoriesManagementModel>, Error>) in
                            DispatchQueue.main.async { [weak self] in
                                guard let self else { return }
                                switch result {
                                case .success(let mappableResult):
                                    switch mappableResult {
                                    case .array(let array):
                                        for item in array {
                                            if let attribite1 = item.attribite1, !attribite1.isEmpty, let ind = self.itemArray.firstIndex(where: {$0.type?.lovValue ?? "" == attribite1}) {
                                                let subTypeModel = APiSubTypeModel()
                                                subTypeModel.subType = item
                                                self.itemArray[ind].subTypeArray.append(subTypeModel)
                                            }
//                                                else if let ind = self.itemArray.firstIndex(where: {$0.type?.lovValue ?? "" == "" && $0.type?.id == nil}) {
//                                                let subTypeModel = APiSubTypeModel()
//                                                subTypeModel.subType = item
//                                                self.itemArray[ind].subTypeArray.append(subTypeModel)
//                                            }else {
//                                                let elemnet = APiCategoryTypeModel()
//                                                elemnet.type = CategoriesManagementModel()
//                                                elemnet.type?.lovValue = ""
//                                                itemArray.append(elemnet)
//                                                let subTypeModel = APiSubTypeModel()
//                                                subTypeModel.subType = item
//                                                self.itemArray[self.itemArray.count-1].subTypeArray.append(subTypeModel)
//                                            }
                                        }
                                        let siteCategoryType = ApiService.getSITE_CHECK_CATEGORY
                                        APIClient.request(siteCategoryType) { [weak self] (result: Result<APIClient.MappableResult<CategoriesManagementModel>, Error>) in
                                            DispatchQueue.main.async { [weak self] in
                                                guard let self else { return }
                                                switch result {
                                                case .success(let mappableResult):
                                                    switch mappableResult {
                                                    case .array(let array):
                                                        for item in array {
                                                            if let attribite1 = item.attribite1, !attribite1.isEmpty, let ind = self.itemArray.firstIndex(where: {$0.subTypeArray.contains(where: {$0.subType?.lovValue == attribite1})}), let subInd = self.itemArray[ind].subTypeArray.firstIndex(where: {$0.subType?.lovValue == attribite1}) {
                                                                self.itemArray[ind].subTypeArray[subInd].subTypeCategoryArray.append(item)
                                                            }
                                                        }
                                                        self.setInd()
                                                        self.loadingStatus = .default
                                                        print("data : \(self.itemArray)")
                                                        break
                                                    default:
                                                        print("error")
                                                        break
                                                    }
                                                case .failure(let error):
                                                    print(error)
                                                }
                                                
                                                self.reloadCollection()
                                            }
                                        }
                                        break
                                    default:
                                        self.loadingStatus = .failed
                                        print("error")
                                        break
                                    }
                                case .failure(let error):
                                    self.loadingStatus = .failed
                                    print(error)
                                }
                                self.reloadCollection()
                            }
                        }
                        break
                    default:
                        self.loadingStatus = .failed
                        break
                    }
                case .failure(let error):
                    self.loadingStatus = .failed
                }
                self.reloadCollection()
            }
        }
    }
    
    func reloadCollection() {
        viewSpread.reloadData()
    }
    
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return headerRow.count
    }
    
    func getArray(item: APiCategoryTypeModel) -> Int {
        var count = 0
        for subType in item.subTypeArray {
            for category in subType.subTypeCategoryArray {
                count += 1
            }
        }
        return count
    }
    
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        switch self.loadingStatus {
        case .default:
            var count = 0
            for item in itemArray {
                count += max(1, item.subTypeArray.count, getArray(item: item))
            }
            return self.newFixItemArray.count+1
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
                stringsArray = newFixItemArray.compactMap{$0.type}
                stringsArray.append(headerRow[column])
            }else if column == 1 {
                stringsArray = newFixItemArray.compactMap{$0.subtype}
                stringsArray.append(headerRow[column])
            }else if column == 2 {
                stringsArray = newFixItemArray.compactMap{$0.category}
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
            var mergeArray = [CellRange]()
            for type in itemArray {
                if type.indRage.1  > type.indRage.0 {
                    mergeArray.append(CellRange(from: IndexPath(row: type.indRage.0, column: 0), to: IndexPath(row: type.indRage.1, column: 0)))
                    mergeArray.append(CellRange(from: IndexPath(row: type.indRage.0, column: 3), to: IndexPath(row: type.indRage.1, column: 3)))
                }
                for subType in type.subTypeArray {
                    if subType.indRage.1 > subType.indRage.0 {
                        mergeArray.append(CellRange(from: IndexPath(row: subType.indRage.0, column: 1), to: IndexPath(row: subType.indRage.1, column: 1)))
                    }
                }
            }
            return mergeArray
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
                    newFixItemArray[row-1].type,
                    newFixItemArray[row-1].subtype,
                    newFixItemArray[row-1].category
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
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextForCatXib", for: indexPath) as! CellTextForCatXib
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
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextForCatXib", for: indexPath) as! CellTextForCatXib
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
        }else if indexPath.section == 0 || indexPath.section == 1 || indexPath.section == 2  {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextForCatXib", for: indexPath) as! CellTextForCatXib
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
                text = newFixItemArray[indexPath.row-1].type
            }else if indexPath.section == 1 {
                text = newFixItemArray[indexPath.row-1].subtype
            }else if indexPath.section == 2 {
                text = newFixItemArray[indexPath.row-1].category
            }
            cell.lblText.text = text
            return cell
        }else if indexPath.section == 3 {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "MoreEditCatOption", for: indexPath) as! MoreEditCatOption
            cellBorderSetUp(cell: cell, isHeader: false)
            cell.imgView.image = UIImage(systemName: "square.and.pencil")
            cell.btnAction.addAction { [weak self] in
                DispatchQueue.main.async { [weak self] in
                    guard let self else {return}
                    let ind = self.newFixItemArray[indexPath.row-1].ind
                    let vc = categoriesManagementSB.instantiateViewController(withIdentifier: "AddNewCategoryAdminVC") as! AddNewCategoryAdminVC
                    vc.homeVC = self
                    vc.editData = self.itemArray[ind]
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            return cell
        }else {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextForCatXib", for: indexPath) as! CellTextForCatXib
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

class CategoriesManagementModel: Mappable {
    var id: Int?
    var lovType: String?
    var lovValue: String?
    var attribite1: String?

    required init?(map: Map) {}
    
    init() {
        
    }

    func mapping(map: Map) {
        id          <- map["id"]
        lovType     <- map["lovType"]
        lovValue    <- map["lovValue"]
        attribite1  <- map["attribite1"]
    }
}


class APiCategoryTypeModel {
    var type: CategoriesManagementModel?
    var subTypeArray: [APiSubTypeModel] = []
    var indRage: (Int,Int) = (0,0)
}

class APiSubTypeModel {
    var subType: CategoriesManagementModel?
    var indRage: (Int,Int) = (0,0)
    var subTypeCategoryArray: [CategoriesManagementModel] = []
}
