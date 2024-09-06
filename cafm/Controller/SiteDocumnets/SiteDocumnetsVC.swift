//
//  SiteDocumnetsVC.swift
//  cafm
//
//  Created by ShitaRam on 30/08/24.
//

import UIKit
import SpreadsheetView
import SCLAlertView

class DocumnetsVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SpreadsheetViewDataSource, SpreadsheetViewDelegate {
        
    @IBOutlet weak var clView: UICollectionView!
    
    @IBOutlet weak var heightOfCollectionView: NSLayoutConstraint!
    
    @IBOutlet weak var viewSpreadsView: SpreadsheetView!
    var loadingStatus: LoadingStatus = .loading
    
    struct FolderCollectonModel {
        let name: String
        let id: Int
    }
    
    var folderCollection: [FolderCollectonModel] = [] {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.heightOfCollectionView.constant = self.folderCollection.count == 1 ? 0 : 50
                self.clView.isHidden = self.folderCollection.count == 1 ? true : false
                self.clView.reloadData()
            }
        }
    }
    
    var headerRow: [String] = ["Document Name", "Uploader", "Issue Date", "Expiry Date", "Source", "Actions"]
    
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
        clView.delegate = self
        clView.dataSource = self
        self.title = "Document Management"
        viewSpreadsView.register(UINib(nibName: String(describing: FolderViewXib.self), bundle: nil), forCellWithReuseIdentifier: String(describing: FolderViewXib.self))
        viewSpreadsView.register(UINib(nibName: String(describing: FolderViewImgXib.self), bundle: nil), forCellWithReuseIdentifier: String(describing: FolderViewImgXib.self))
        viewSpreadsView.register(UINib(nibName: String(describing: CellTextXib.self), bundle: nil), forCellWithReuseIdentifier: String(describing: CellTextXib.self))
        viewSpreadsView.register(UINib(nibName: String(describing: MoreEditOption.self), bundle: nil), forCellWithReuseIdentifier: String(describing: MoreEditOption.self))
        viewSpreadsView.bounces = false
        viewSpreadsView.dataSource = self
        viewSpreadsView.delegate = self
        setupHomeFolder()
    }
    
    func setupHomeFolder() {
        loadingStatus = .default
        folderCollection = [FolderCollectonModel(name: "Documents", id: 0)]
        viewSpreadsView.reloadData()
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
                        self.loadingStatus = (self.subFolderDetails?.document?.childFolders?.isEmpty ?? false) && (self.subFolderDetails?.document?.files?.isEmpty ?? false) ? .noResponse : .default
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
    
    func deleteFile(id: Int) {
        let apiData = ApiService.deleteFile(id: id)
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false // if you dont want the close button use false
        )
        let sclAlert = SCLAlertView(appearance: appearance)
        sclAlert.showWait("", subTitle: "please wait...", closeButtonTitle: "")
        APIClient.requestWithCode(apiData) { [weak self] isSuccess, code in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                sclAlert.hideView()
                if code == 200 {
                    SCLAlertView().showSuccess("", subTitle: "File Delete successfully.")
                    if let id = self.folderCollection.last?.id {
                        fetchData(id: id)
                    }
                }else {
                    SCLAlertView().showError("Error", subTitle: "Oops! please try again")
                }
            }
        }
    }
    
    
    func createFolder(folder: CreateFolderReq, isInsideFolder: Bool = false ) {
        let apiData = ApiService.createFolder(folder: folder)
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false // if you dont want the close button use false
        )
        let sclAlert = SCLAlertView(appearance: appearance)
        sclAlert.showWait("", subTitle: "please wait...", closeButtonTitle: "")
        APIClient.requestWithCode(apiData) { [weak self] isSuccess, code in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                sclAlert.hideView()
                if code == 200 {
                    SCLAlertView().showSuccess("", subTitle: "Folder created successfully.")
                    if !isInsideFolder {
                        if let id = self.folderCollection.last?.id {
                            fetchData(id: id)
                        }
                    }
                }else {
                    SCLAlertView().showError("Error", subTitle: "Oops! please try again")
                }
            }
        }
    }
    
    
    func reloadCollection() {
        viewSpreadsView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return folderCollection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FolderCollectonViewCell", for: indexPath) as! FolderCollectonViewCell
        cell.lblFolderName.font = UIFont(name: .MontserratSemiBold, size: 18)
        cell.lblFolderName.text = folderCollection[indexPath.row].name
        cell.imgForword.isHidden = folderCollection.count-1 == indexPath.row ? true : false
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let stringsArray = [folderCollection[indexPath.row].name]
        let maxColumnWidth = getMaxLabelSize(textArray: stringsArray, font: UIFont(name: .MontserratSemiBold, size: 18), minWidth: 70, widthAddition: 6+35+5+5+14+5, maxWidth: 350).width
        return CGSize(width: maxColumnWidth, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            setupHomeFolder()
        }else if indexPath.row == folderCollection.count-1 {
            fetchData(id: folderCollection[indexPath.row].id)
        }else {
            var array = [Int]()
            for i in indexPath.row+1...folderCollection.count-1 {
                array.append(i)
            }
            for ind in array.reversed() {
                folderCollection.remove(at: ind)
            }
            fetchData(id: folderCollection[indexPath.row].id)
        }
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
                let documentCount = self.subFolderDetails?.document?.files?.count ?? 0
                return 1+1+folderCount+documentCount
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
            case 6 :
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
            case 1,2,3,4:
                var stringsArray = [headerRow[column]]
                if column == 1 {
                    stringsArray.append(contentsOf: subFolderDetails?.document?.files?.compactMap({$0.uploaderUserName}) ?? [])
                }else if column == 2 {
                    stringsArray.append(contentsOf: subFolderDetails?.document?.files?.compactMap({(convertDateString($0.issueDate))}) ?? [])
                }else if column == 3 {
                    stringsArray.append(contentsOf: subFolderDetails?.document?.files?.compactMap({(convertDateString($0.expiryDate))}) ?? [])
                }else if column == 4 {
                    stringsArray.append(contentsOf: subFolderDetails?.document?.files?.compactMap({$0.source}) ?? [])
                }
                return max(getMaxLabelSize(textArray: stringsArray, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 250).width,30)
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
                }else if row > (self.subFolderDetails?.document?.childFolders?.count ?? 0) + 1 {
                    let convertRow = row - (self.subFolderDetails?.document?.childFolders?.count ?? 0) - 2
                    let refSize = CGSize(width: 100, height: 40)
                    let heightAddition: CGFloat = 5+5+35
                    let minHeight = refSize.height-heightAddition
                    let textArray = headerRow
                    let font = UIFont(name: .MontserratSemiBold, size: textFontSize)
                    let stringsArray = [self.subFolderDetails?.document?.files?[convertRow].name ?? ""]
                    let headerHeight = getMaxLabelSize(textArray: stringsArray, font: font, maxWidth: 250, minHeight: minHeight, heightAddition: heightAddition).height
                    
                    let heightAdditionOther: CGFloat = 10+10
                    var optionArray = [String?]()
                    optionArray.append(contentsOf: [
                        self.subFolderDetails?.document?.files?[convertRow].uploaderUserName,
                        convertDateString( self.subFolderDetails?.document?.files?[convertRow].issueDate),
                        convertDateString( self.subFolderDetails?.document?.files?[convertRow].expiryDate),
                        self.subFolderDetails?.document?.files?[convertRow].source
                    ])
                    let textArrayA = optionArray.compactMap{$0}
                    let otherHeight = getMaxLabelSize(textArray: textArrayA, font: font, maxWidth: 200, minHeight: minHeight, heightAddition: heightAdditionOther).height
                    return max(headerHeight, heightAdditionOther)
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
            case 5:
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
            case 5:
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
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "FolderViewXib", for: indexPath) as! FolderViewXib
                    let convertRow = indexPath.row - (self.subFolderDetails?.document?.childFolders?.count ?? 0) - 2
                    cellBorderSetUp(cell: cell, isHeader: false)
                    cell.setUpDocView()
                    cell.lblFolderName.text = self.subFolderDetails?.document?.files?[convertRow].name
                    cell.lblFolderName.font = UIFont(name: .MontserratRegular, size: textFontSize)
                    cell.btnFolder.addAction { [weak self] in
                        DispatchQueue.main.async { [weak self] in
                            guard let self else { return }
                            let vc = documnetSB.instantiateViewController(withIdentifier: "FilePreviewVC") as! FilePreviewVC
                            let urlString = self.subFolderDetails?.document?.files?[convertRow].fileBlobUrl ?? ""
                            vc.url = URL(string: urlString)
                            self.present(vc, animated: true)
                        }
                    }
                    return cell
                }
            }else if indexPath.column == 1 || indexPath.column == 2 || indexPath.column == 3 || indexPath.column == 4 {
                if indexPath.row == 1 || (indexPath.row <= (self.subFolderDetails?.document?.childFolders?.count ?? 0) + 1) {
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextXib", for: indexPath) as! CellTextXib
                    cellBorderSetUp(cell: cell, isHeader: false)
                    cell.lblText.text = "--"
                    cell.lblText.textColor = .black
                    cell.lblText.font = UIFont(name: .MontserratRegular, size: textFontSize)
                    return cell
                }else if indexPath.row > (self.subFolderDetails?.document?.childFolders?.count ?? 0) + 1 {
                    let convertRow = indexPath.row - (self.subFolderDetails?.document?.childFolders?.count ?? 0) - 2
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextXib", for: indexPath) as! CellTextXib
                    cellBorderSetUp(cell: cell, isHeader: false)
                    var text: String? = ""
                    if indexPath.column == 1 {
                        text = self.subFolderDetails?.document?.files?[convertRow].uploaderUserName
                    }else if indexPath.column == 2 {
                        text = convertDateString(self.subFolderDetails?.document?.files?[convertRow].issueDate)
                    }else if indexPath.column == 3 {
                        text = convertDateString(self.subFolderDetails?.document?.files?[convertRow].expiryDate)
                    }else if indexPath.column == 4 {
                        text = self.subFolderDetails?.document?.files?[convertRow].source
                    }
                    cell.lblText.text = text
                    cell.lblText.textColor = .black
                    cell.lblText.font = UIFont(name: .MontserratRegular, size: textFontSize)
                    return cell
                }else {
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextXib", for: indexPath) as! CellTextXib
                    cellBorderSetUp(cell: cell, isHeader: false)
                    cell.lblText.text = "r \(indexPath.row) c \(indexPath.column)"
                    cell.lblText.textColor = .black
                    return cell
                }
            }else if indexPath.column == 5 {
                //rk-pd
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "MoreEditOption", for: indexPath) as! MoreEditOption
                cellBorderSetUp(cell: cell, isHeader: false)
                cell.btnAction.showsMenuAsPrimaryAction = true
                if indexPath.row == 1 {
                    let goBackAction = UIAction(title: "Go back", image: UIImage(systemName: "arrow.left")) { [weak self] _ in
                        guard let self else {return}
                        self.folderCollection.removeLast()
                        if self.folderCollection.count == 1 {
                            self.setupHomeFolder()
                        }else if let id = self.folderCollection.last?.id {
                            self.fetchData(id: id)
                        }
                    }

                    let createNewFolderAction = UIAction(title: "Create new Folder", image: UIImage(systemName: "folder.badge.plus")) { [weak self]  _ in
                        guard let self else {return}
                        let alertController = UIAlertController(title: "Create New Folder", message: nil, preferredStyle: .alert)
                        
                        // Add the text field to the alert
                        alertController.addTextField { textField in
                            textField.placeholder = "Folder name"
                        }
                        
                        // Add the Cancel action
                        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                        alertController.addAction(cancelAction)
                        
                        // Add the Save action
                        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
                            guard let self else {return}
                            if let folderName = alertController.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) , !folderName.isEmpty {
                                self.createFolder(folder: CreateFolderReq(folderName: folderName, parentFolderId: "\(self.folderCollection.last?.id ?? 0)", siteId: 1, isStatutoryRegister: true))
                            }else {
                                let errorAlert = UIAlertController(title: "Error", message: "Folder name cannot be empty.", preferredStyle: .alert)
                                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                errorAlert.addAction(okAction)
                                self.present(errorAlert, animated: true, completion: nil)
                            }
                        }
                        alertController.addAction(saveAction)
                        
                        // Present the alert
                        self.present(alertController, animated: true, completion: nil)
                    }

                    let uploadNewFileAction = UIAction(title: "Upload new file", image: UIImage(systemName: "doc.badge.plus")) { [weak self] _ in
                        // Handle upload new file action
                        DispatchQueue.main.async { [weak self] in
                            guard let self else { return }
                            let vc = documnetSB.instantiateViewController(withIdentifier: "UploadDocumnetVC") as! UploadDocumnetVC
                            vc.folderName = folderCollection.last?.name ?? ""
                            vc.folderId = folderCollection.last?.id
                            vc.homeVC = self
                            self.present(vc, animated: true)
                        }
                        
                    }

                    let bulkUploadAction = UIAction(title: "Bulk Upload", image: UIImage(systemName: "tray.full")) { [weak self] _ in
                        // Handle bulk upload action
                        DispatchQueue.main.async { [weak self] in
                            guard let self else { return }
                            let vc = documnetSB.instantiateViewController(withIdentifier: "BulkUploadVC") as! BulkUploadVC
                            vc.folderName = folderCollection.last?.name ?? ""
                            vc.folderId = folderCollection.last?.id
                            vc.homeVC = self
                            self.present(vc, animated: true)
                        }
                    }

                    // Create the UIMenu with the actions
                    let menu = UIMenu(title: "", children: [goBackAction, createNewFolderAction, uploadNewFileAction, bulkUploadAction])
                    // Assign the menu to the button
                    cell.btnAction.menu = menu
                }else if indexPath.row <= (self.subFolderDetails?.document?.childFolders?.count ?? 0) + 1 {

                    let createNewFolderAction = UIAction(title: "Create new Folder", image: UIImage(systemName: "folder.badge.plus")) { [weak self]  _ in
                        guard let self else {return}
                        let alertController = UIAlertController(title: "Create New Folder", message: nil, preferredStyle: .alert)
                        
                        // Add the text field to the alert
                        alertController.addTextField { textField in
                            textField.placeholder = "Folder name"
                        }
                        
                        // Add the Cancel action
                        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                        alertController.addAction(cancelAction)
                        
                        // Add the Save action
                        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
                            guard let self else {return}
                            if let folderName = alertController.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) , !folderName.isEmpty {
                                self.createFolder(folder: CreateFolderReq(folderName: folderName, parentFolderId: "\(self.subFolderDetails?.document?.childFolders?[indexPath.row-2].id ?? 0)", siteId: 1, isStatutoryRegister: true), isInsideFolder: true)
                            }else {
                                let errorAlert = UIAlertController(title: "Error", message: "Folder name cannot be empty.", preferredStyle: .alert)
                                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                errorAlert.addAction(okAction)
                                self.present(errorAlert, animated: true, completion: nil)
                            }
                        }
                        alertController.addAction(saveAction)
                        
                        // Present the alert
                        self.present(alertController, animated: true, completion: nil)
                    }

                    let uploadNewFileAction = UIAction(title: "Upload new file", image: UIImage(systemName: "doc.badge.plus")) { [weak self] _ in
                        // Handle upload new file action
                        DispatchQueue.main.async { [weak self] in
                            guard let self else { return }
                            let vc = documnetSB.instantiateViewController(withIdentifier: "UploadDocumnetVC") as! UploadDocumnetVC
                            vc.folderName = self.subFolderDetails?.document?.childFolders?[indexPath.row-2].name ?? ""
                            vc.folderId = self.subFolderDetails?.document?.childFolders?[indexPath.row-2].id
//                            vc.homeVC = self
                            self.present(vc, animated: true)
                        }
                        
                    }

                    let bulkUploadAction = UIAction(title: "Bulk Upload", image: UIImage(systemName: "tray.full")) { [weak self] _ in
                        // Handle bulk upload action
                        DispatchQueue.main.async { [weak self] in
                            guard let self else { return }
                            let vc = documnetSB.instantiateViewController(withIdentifier: "BulkUploadVC") as! BulkUploadVC
                            vc.folderName = self.subFolderDetails?.document?.childFolders?[indexPath.row-2].name ?? ""
                            vc.folderId = self.subFolderDetails?.document?.childFolders?[indexPath.row-2].id
//                            vc.homeVC = self
                            self.present(vc, animated: true)
                        }
                    }

                    // Create the UIMenu with the actions
                    let menu = UIMenu(title: "", children: [createNewFolderAction, uploadNewFileAction, bulkUploadAction])
                    // Assign the menu to the button
                    cell.btnAction.menu = menu
                    return cell
                }else {
                    let convertRow = indexPath.row - (self.subFolderDetails?.document?.childFolders?.count ?? 0) - 2
                    let replaceAction = UIAction(title: "Replace with new version", image: UIImage(systemName: "arrow.triangle.2.circlepath")) { [weak self] action in
                        print("Replace with new version tapped")
                        DispatchQueue.main.async { [weak self] in
                            guard let self else {return}
                            let vc = documnetSB.instantiateViewController(withIdentifier: "FileVersionHistoryVC") as! FileVersionHistoryVC
                            vc.folderName = self.folderCollection.last?.name ?? ""
                            vc.folderId = self.folderCollection.last?.id
                            vc.fileID = self.subFolderDetails?.document?.files?[convertRow].id
                            vc.selectedFile = self.subFolderDetails?.document?.files?[convertRow]
                            vc.homeVC = self
                            self.present(vc, animated: true)
                        }
                    }
                    
                    let historyAction = UIAction(title: "Version History", image: UIImage(systemName: "clock.arrow.circlepath")) { [weak self] action in
                        print("Version History tapped")
                        DispatchQueue.main.async { [weak self] in
                            guard let self else {return}
                            let vc = documnetSB.instantiateViewController(withIdentifier: "FileVersionHistoryVC") as! FileVersionHistoryVC
                            vc.folderName = self.folderCollection.last?.name ?? ""
                            vc.folderId = self.folderCollection.last?.id
                            vc.fileID = self.subFolderDetails?.document?.files?[convertRow].id
                            vc.isPreview = true
                            vc.selectedFile = self.subFolderDetails?.document?.files?[convertRow]
                            self.present(vc, animated: true)
                        }

                    }
                    
                    let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash")) { [weak self] action in
                        print("Delete tapped")
                        DispatchQueue.main.async { [weak self] in
                            guard let self, let id = self.subFolderDetails?.document?.files?[convertRow].id else {return}
                            let alertController = UIAlertController(
                                title: "Delete File",
                                message: "Do you want to delete this file?",
                                preferredStyle: .alert
                            )
                            
                            // Add the "Cancel" action
                            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                            alertController.addAction(cancelAction)
                            
                            // Add the "Delete" action
                            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
                                // Handle the delete action here
                                DispatchQueue.main.async { [weak self] in
                                    self?.deleteFile(id: id)
                                }
                                print("File deleted")
                            }
                            alertController.addAction(deleteAction)
                            
                            // Present the alert
                            self.present(alertController, animated: true, completion: nil)

                        }
                    }
                    
                    let copyAction = UIAction(title: "Copy", image: UIImage(systemName: "doc.on.doc")) { action in
                        print("Copy tapped")
                    }
                    
                    let moveAction = UIAction(title: "Move", image: UIImage(systemName: "folder")) { action in
                        print("Move tapped")
                    }
                    
                    // Create a UIMenu with the actions
                    let menu = UIMenu(title: "", children: [replaceAction, historyAction, deleteAction, copyAction, moveAction])
                    
                    cell.btnAction.menu = menu
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




class FolderCollectonViewCell: UICollectionViewCell {
    
    @IBOutlet weak var lblFolderName: UILabel!
    @IBOutlet weak var imgForwordImage: UIImageView!
    
    @IBOutlet weak var imgForword: UIImageView!
    
}
