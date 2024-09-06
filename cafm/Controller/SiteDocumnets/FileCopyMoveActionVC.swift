//
//  FileCopyMoveActionVC.swift
//  cafm
//
//  Created by ShitaRam on 04/09/24.
//

import UIKit
import SpreadsheetView

class FileCopyMoveActionVC: UIViewController, SpreadsheetViewDataSource, SpreadsheetViewDelegate  {
    
    @IBOutlet weak var viewSpread: SpreadsheetView!
    var loadingStatus: LoadingStatus = .loading
    
    struct FolderCollectonModel {
        let name: String
        let id: Int
    }
    
    var folderCollection: [FolderCollectonModel] = [] {
        didSet {
            print(folderCollection)
        }
    }
    
    var headerRow: [String] = ["Document Name", "Actions"]
    
    let homeFolder = [
        Folder(id: 1, name: "Statutory Documents", required: false, status: ""),
        Folder(id: 2, name: "Occupation H&S policies", required: false, status: ""),
        Folder(id: 3, name: "Mechanical O&M Manuals", required: false, status: ""),
        Folder(id: 4, name: "others", required: false, status: ""),
        Folder(id: 5, name: "Building Report", required: false, status: ""),
        Folder(id: 6, name: "Electrical O&M Manuals", required: false, status: ""),
        Folder(id: 7, name: "Log Book", required: false, status: ""),
    ]
    
    var isDataNotRecive : Bool {
        return (loadingStatus == .loading || loadingStatus == .failed || loadingStatus == .noResponse || loadingStatus == .noInternet)
    }
    
    var subFolderDetails: DocumentResponse?

    override func viewDidLoad() {
        super.viewDidLoad()
        viewSpread.register(UINib(nibName: String(describing: FolderViewXib.self), bundle: nil), forCellWithReuseIdentifier: String(describing: FolderViewXib.self))
        viewSpread.register(UINib(nibName: String(describing: FolderViewImgXib.self), bundle: nil), forCellWithReuseIdentifier: String(describing: FolderViewImgXib.self))
        viewSpread.register(UINib(nibName: String(describing: CellTextXib.self), bundle: nil), forCellWithReuseIdentifier: String(describing: CellTextXib.self))
        viewSpread.register(UINib(nibName: String(describing: MoreEditOption.self), bundle: nil), forCellWithReuseIdentifier: String(describing: MoreEditOption.self))
        viewSpread.bounces = false
        viewSpread.dataSource = self
        viewSpread.delegate = self
        setupHomeFolder()
    }
    
    @IBAction func btnCloseClick(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    func setupHomeFolder() {
        loadingStatus = .default
        folderCollection = [FolderCollectonModel(name: "Documents", id: 0)]
        viewSpread.reloadData()
    }
    
    func fetchData(id: Int) {
        loadingStatus = .loading
        reloadCollection()
        let apiData = ApiService.folders(id: id)
        APIClient.request(apiData) { [weak self] (result: Result<APIClient.MappableResult<DocumentResponse>, Error>) in
            switch result {
            case .success(let responseResult):
                if case .single(let documentResponse) = responseResult {
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        self.subFolderDetails = documentResponse
                        self.loadingStatus = self.subFolderDetails?.document?.childFolders?.isEmpty ?? false ? .noResponse : .default
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

    func reloadCollection() {
        viewSpread.reloadData()
    }
    
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return headerRow.count
    }

    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        switch self.loadingStatus {
        case .default:
            if folderCollection.count == 1 {
                return homeFolder.count+1
            }else {
                let folderCount = self.subFolderDetails?.document?.childFolders?.count ?? 0
                return 1+1+folderCount
            }
        case .loading, .failed, .noResponse, .noInternet:
            return 1+1+1
        }
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        switch loadingStatus {
        case .loading, .failed, .noResponse, .noInternet:
            if folderCollection.count == 1 {
                var stringsArray = [headerRow[column]]
                let maxColumnWidth = getMaxLabelSize(textArray: stringsArray, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 200).width
                return maxColumnWidth
            }else {
                let stringsArray = [folderCollection.last?.name ?? ""]
                let folderWidth = getMaxLabelSize(textArray: stringsArray, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 5+35+5+5, maxWidth: 250).width
                
                let headerWidth = getMaxLabelSize(textArray: [headerRow[column]], font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 250).width
                return folderWidth > headerWidth ? folderWidth : headerWidth
            }
        default:
            break
        }
        if folderCollection.count == 1 {
            switch column {
            case 0:
                let stringsArray = homeFolder.compactMap({$0.name})
                let folderWidth = getMaxLabelSize(textArray: stringsArray, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 5+35+5+5, maxWidth: 250).width
                
                let headerWidth = getMaxLabelSize(textArray: [headerRow[column]], font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 250).width
                
                return folderWidth > headerWidth ? folderWidth : headerWidth
            case 1 :
                return max(getMaxLabelSize(textArray: [headerRow[column]], font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 250).width,30)
            default:
                return getMaxLabelSize(textArray: [headerRow[column]], font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 250).width
            }
        }else if folderCollection.count > 1 {
            switch column {
            case 0:
                var stringsArray = [String]()
                stringsArray.append(folderCollection.last?.name ?? "")
                stringsArray.append(contentsOf: subFolderDetails?.document?.childFolders?.compactMap({$0.name}) ?? [])
                stringsArray.append(contentsOf: subFolderDetails?.document?.files?.compactMap({$0.name}) ?? [])

                let folderWidth = getMaxLabelSize(textArray: stringsArray, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 5+35+5+5, maxWidth: 250).width
                
                let headerWidth = getMaxLabelSize(textArray: [headerRow[column]], font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 250).width
                
                if (subFolderDetails?.document?.childFolders?.isEmpty ?? true) && (subFolderDetails?.document?.files?.isEmpty ?? true) {
                    return folderWidth > headerWidth ? folderWidth : headerWidth
                }else {
                    return (folderWidth > headerWidth ? folderWidth : headerWidth) + 15
                }
            default:
                return getMaxLabelSize(textArray: [headerRow[column]], font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 250).width
            }
        }else {
            return 30
        }
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        switch loadingStatus {
        case .loading, .failed, .noResponse, .noInternet:
            if folderCollection.count == 1 {
                let refSize = CGSize(width: 100, height: 40)
                let heightAddition: CGFloat = 10+10
                let minHeight = refSize.height-heightAddition
                let textArray = headerRow
                let font = UIFont(name: .MontserratSemiBold, size: textFontSize)
                let headerHeight = getMaxLabelSize(textArray: textArray, font: font, maxWidth: 200, minHeight: minHeight, heightAddition: heightAddition).height
                return headerHeight
            }else {
                if row == 0 || row == 2 {
                    let refSize = CGSize(width: 100, height: 40)
                    let heightAddition: CGFloat = 10+10
                    let minHeight = refSize.height-heightAddition
                    let textArray = headerRow
                    let font = UIFont(name: .MontserratSemiBold, size: textFontSize)
                    let headerHeight = getMaxLabelSize(textArray: textArray, font: font, maxWidth: 250, minHeight: minHeight, heightAddition: heightAddition).height
                    return headerHeight
                }else {
                    let refSize = CGSize(width: 100, height: 40)
                    let heightAddition: CGFloat = 5+5+35
                    let minHeight = refSize.height-heightAddition
                    let font = UIFont(name: .MontserratSemiBold, size: textFontSize)
                    let stringsArray = [folderCollection.last?.name ?? ""]
                    let headerHeight = getMaxLabelSize(textArray: stringsArray, font: font, maxWidth: 250, minHeight: minHeight, heightAddition: heightAddition).height
                    return headerHeight
                }
            }
        default:
            if row == 0 {
                let refSize = CGSize(width: 100, height: 40)
                let heightAddition: CGFloat = 10+10
                let minHeight = refSize.height-heightAddition
                let textArray = headerRow
                let font = UIFont(name: .MontserratSemiBold, size: textFontSize)
                let headerHeight = getMaxLabelSize(textArray: textArray, font: font, maxWidth: 250, minHeight: minHeight, heightAddition: heightAddition).height
                return headerHeight
            }else {
                if folderCollection.count == 1 {
                    let refSize = CGSize(width: 100, height: 40)
                    let heightAddition: CGFloat = 5+5+35
                    let minHeight = refSize.height-heightAddition
                    let textArray = headerRow
                    let font = UIFont(name: .MontserratSemiBold, size: textFontSize)
                    let stringsArray = [homeFolder[row-1].name ?? ""]
                    let headerHeight = getMaxLabelSize(textArray: stringsArray, font: font, maxWidth: 250, minHeight: minHeight, heightAddition: heightAddition).height
                    return headerHeight
                }else if row == 1 {
                    let refSize = CGSize(width: 100, height: 40)
                    let heightAddition: CGFloat = 5+5+35
                    let minHeight = refSize.height-heightAddition
                    let textArray = headerRow
                    let font = UIFont(name: .MontserratSemiBold, size: textFontSize)
                    let stringsArray = [self.folderCollection.last?.name ?? ""]
                    let headerHeight = getMaxLabelSize(textArray: stringsArray, font: font, maxWidth: 250, minHeight: minHeight, heightAddition: heightAddition).height
                    return headerHeight
                }else if row <= (self.subFolderDetails?.document?.childFolders?.count ?? 0) + 1 {
                    let refSize = CGSize(width: 100, height: 40)
                    let heightAddition: CGFloat = 5+5+35
                    let minHeight = refSize.height-heightAddition
                    let textArray = headerRow
                    let font = UIFont(name: .MontserratSemiBold, size: textFontSize)
                    let stringsArray = [self.subFolderDetails?.document?.childFolders?[row-2].name ?? ""]
                    let headerHeight = getMaxLabelSize(textArray: stringsArray, font: font, maxWidth: 250, minHeight: minHeight, heightAddition: heightAddition).height
                    return headerHeight
                }
            }
        }
        return 60
    }

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        if indexPath.row == 0 {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextXib", for: indexPath) as! CellTextXib
            cellBorderSetUp(cell: cell, isHeader: true)
            cell.lblText.font = UIFont(name: .MontserratSemiBold, size: textFontSize)
            cell.lblText.textColor = UIColor.white
            cell.lblText.backgroundColor = UIColor.clear
            cell.lblText.text = headerRow[indexPath.section]
            return cell
        }else if indexPath.row == 1 && isDataNotRecive {
            switch indexPath.column {
            case 0:
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "FolderViewXib", for: indexPath) as! FolderViewXib
                cellBorderSetUp(cell: cell, isHeader: false)
                cell.setUpFolderView(isSubFolder: false)
                cell.lblFolderName.text = folderCollection.last?.name
                cell.lblFolderName.font = UIFont(name: .MontserratRegular, size: textFontSize)
                cell.btnFolder.addAction { [weak self] in
                    guard let self else { return }
                    if let id = folderCollection.last?.id {
                        self.fetchData(id: id)
                    }
                }
                return cell
            case 1:
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "FolderViewImgXib", for: indexPath) as! FolderViewImgXib
                cellBorderSetUp(cell: cell, isHeader: false)
                cell.btnPreview.addAction { [weak self] in
                    guard let self else { return }
                    if let id = folderCollection.last?.id {
                        self.fetchData(id: id)
                    }
                }
                return cell
            default:
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextXib", for: indexPath) as! CellTextXib
                cellBorderSetUp(cell: cell, isHeader: false)
                cell.lblText.text = "-"
                cell.lblText.textColor = .black
                cell.lblText.font = UIFont(name: .MontserratRegular, size: textFontSize)
                return cell
            }
        }else if indexPath.row == 2 && isDataNotRecive {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextXib", for: indexPath) as! CellTextXib
            cellBorderSetUp(cell: cell, isHeader: false)
            cell.lblText.addCorner(value: 0)
            cell.lblText.font = UIFont(name: .MontserratRegular, size: textFontSize)
            cell.lblText.textColor = UIColor.black
            cell.lblText.backgroundColor = UIColor.clear
            cell.lblText.text = loadingStatus.rawValue
            return cell
        }else if folderCollection.count == 1 {
            switch indexPath.column {
            case 0:
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "FolderViewXib", for: indexPath) as! FolderViewXib
                cellBorderSetUp(cell: cell, isHeader: false)
                cell.setUpFolderView(isSubFolder: false)
                cell.lblFolderName.text = homeFolder[indexPath.row-1].name
                cell.lblFolderName.font = UIFont(name: .MontserratRegular, size: textFontSize)
                cell.btnFolder.addAction { [weak self] in
                    guard let self else { return }
                    if let id = homeFolder[indexPath.row-1].id {
                        self.folderCollection.append(FolderCollectonModel(name: homeFolder[indexPath.row-1].name ?? "", id: id))
                        self.fetchData(id: id)
                    }
                }
                return cell
            case 1:
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "FolderViewImgXib", for: indexPath) as! FolderViewImgXib
                cellBorderSetUp(cell: cell, isHeader: false)
                cell.btnPreview.addAction { [weak self] in
                    guard let self else { return }
                    if let id = homeFolder[indexPath.row-1].id {
                        self.folderCollection.append(FolderCollectonModel(name: homeFolder[indexPath.row-1].name ?? "", id: id))
                        self.fetchData(id: id)
                    }
                }
                return cell
            default:
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextXib", for: indexPath) as! CellTextXib
                cellBorderSetUp(cell: cell, isHeader: false)
                cell.lblText.text = "-"
                cell.lblText.textColor = .black
                cell.lblText.font = UIFont(name: .MontserratRegular, size: textFontSize)
                return cell
            }
        }else if folderCollection.count > 1 {
            if indexPath.column == 0 {
                if indexPath.row == 1 {
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "FolderViewXib", for: indexPath) as! FolderViewXib
                    cellBorderSetUp(cell: cell, isHeader: false)
                    cell.setUpFolderView(isSubFolder: false)
                    cell.lblFolderName.text = folderCollection.last?.name
                    cell.lblFolderName.font = UIFont(name: .MontserratRegular, size: textFontSize)
                    cell.btnFolder.addAction { [weak self] in
                        guard let self else { return }
                        if let id = folderCollection.last?.id {
                            self.fetchData(id: id)
                        }
                    }
                    return cell
                }else if indexPath.row <= (self.subFolderDetails?.document?.childFolders?.count ?? 0) + 1 {
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "FolderViewXib", for: indexPath) as! FolderViewXib
                    cellBorderSetUp(cell: cell, isHeader: false)
                    cell.setUpFolderView(isSubFolder: true)
                    cell.lblFolderName.text = self.subFolderDetails?.document?.childFolders?[indexPath.row-2].name
                    cell.lblFolderName.font = UIFont(name: .MontserratRegular, size: textFontSize)
                    cell.btnFolder.addAction { [weak self] in
                        guard let self else { return }
                        if let folder = self.subFolderDetails?.document?.childFolders?[indexPath.row-2], let id = folder.id, let name = folder.name {
                            self.folderCollection.append(FolderCollectonModel(name: name, id: id))
                            self.fetchData(id: id)
                        }
                    }
                    return cell
                }else {
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextXib", for: indexPath) as! CellTextXib
                    cellBorderSetUp(cell: cell, isHeader: false)
                    cell.lblText.text = "-"
                    cell.lblText.textColor = .black
                    cell.lblText.font = UIFont(name: .MontserratRegular, size: textFontSize)
                    return cell
                }
            }else if indexPath.column == 1 {
                //rk-pd
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "MoreEditOption", for: indexPath) as! MoreEditOption
                cellBorderSetUp(cell: cell, isHeader: false)
                cell.btnAction.showsMenuAsPrimaryAction = true
                if indexPath.row == 1 {
                    
                }else if indexPath.row <= (self.subFolderDetails?.document?.childFolders?.count ?? 0) + 1 {
                    
                }
                return cell
            }else {
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextXib", for: indexPath) as! CellTextXib
                cellBorderSetUp(cell: cell, isHeader: false)
                cell.lblText.text = "r \(indexPath.row) c \(indexPath.column)"
                cell.lblText.textColor = .black
                return cell
            }
        }else {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextXib", for: indexPath) as! CellTextXib
            cellBorderSetUp(cell: cell, isHeader: false)
            cell.lblText.text = "r \(indexPath.row) c \(indexPath.column)"
            cell.lblText.textColor = .black
            return cell
        }
    }
    
    func mergedCells(in spreadsheetView: SpreadsheetView) -> [CellRange] {
        switch self.loadingStatus {
        case .default:
            return []
        case .loading, .failed, .noResponse, .noInternet:
            let totalColumn = self.headerRow.count
            return [CellRange(from: IndexPath(row: 2, column: 0), to: IndexPath(row: 2, column: totalColumn-1))]
        }
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, didSelectItemAt indexPath: IndexPath) {
        if (loadingStatus == .noInternet || loadingStatus == .failed) {
            if let id = folderCollection.last?.id {
                self.fetchData(id: id)
            }
        }
    }
    
    func frozenRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 1
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
    
}
