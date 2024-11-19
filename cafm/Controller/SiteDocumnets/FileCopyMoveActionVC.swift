//
//  FileCopyMoveActionVC.swift
//  cafm
//
//  Created by ShitaRam on 04/09/24.
//

import UIKit
import SpreadsheetView
import SCLAlertView

class FileCopyMoveActionVC: UIViewController, SpreadsheetViewDataSource, SpreadsheetViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
    
    @IBOutlet weak var viewSpread: SpreadsheetView!
    
    @IBOutlet weak var widthOfSpredView: NSLayoutConstraint!
    
    @IBOutlet weak var clview: UICollectionView!
    
    @IBOutlet weak var heightOfCollectionView: NSLayoutConstraint!
    
    @IBOutlet weak var lblTitle: UILabel!
    
    weak var addFolderToContractsDelegate: AddFolderToContractsDelegate?
    
    var loadingStatus: LoadingStatus = .loading
    
    var isNeedToClose = false
    
    enum ActionType {
        case copy
        case move
        case select
    }
    
    var actionType = ActionType.copy
    
    struct FolderCollectonModel {
        let name: String
        let id: Int
    }
    
    var folderCollection: [FolderCollectonModel] = [] {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.heightOfCollectionView.constant = self.folderCollection.count == 1 ? 5 : 50
                self.clview.isHidden = self.folderCollection.count == 1 ? true : false
                self.clview.reloadData()
                DispatchQueue.main.asyncAfter(deadline: .now()+0.2) { [weak self] in
                    guard let self else {return}
                    self.clview.scrollToItem(at: IndexPath(row: self.folderCollection.count-1, section: 0), at: .centeredHorizontally, animated: true)
                }
            }
        }
    }
    
    var headerRow: [String] = ["Document Name", "Actions"]
    
    var homeFolder = [ParentFolder]()//[
//        Folder(id: 1, name: "Statutory Documents", required: false, status: ""),
//        Folder(id: 2, name: "Occupation H&S policies", required: false, status: ""),
//        Folder(id: 3, name: "Mechanical O&M Manuals", required: false, status: ""),
//        Folder(id: 4, name: "others", required: false, status: ""),
//        Folder(id: 5, name: "Building Report", required: false, status: ""),
//        Folder(id: 6, name: "Electrical O&M Manuals", required: false, status: ""),
//        Folder(id: 7, name: "Log Book", required: false, status: ""),
//    ]
    
    var isDataNotRecive : Bool {
        return (loadingStatus == .loading || loadingStatus == .failed || loadingStatus == .noResponse || loadingStatus == .noInternet)
    }
    
    var subFolderDetails: DocumentResponse?
    var selectedFile: File?

    override func viewDidLoad() {
        super.viewDidLoad()
        if actionType == .copy {
            lblTitle.text = "Select folder to copy file"
        }else if actionType == .select {
            lblTitle.text = "Select Mandatory Folders"
        }else {
            lblTitle.text = "Select folder to move file"
        }
        widthOfSpredView.constant = screenWidth
        self.clview.delegate = self
        self.clview.dataSource = self
        
        self.isModalInPresentation = true
        viewSpread.register(UINib(nibName: String(describing: FolderViewXib.self), bundle: nil), forCellWithReuseIdentifier: String(describing: FolderViewXib.self))
        viewSpread.register(UINib(nibName: String(describing: FolderViewImgXib.self), bundle: nil), forCellWithReuseIdentifier: String(describing: FolderViewImgXib.self))
        viewSpread.register(UINib(nibName: String(describing: CellTextXib.self), bundle: nil), forCellWithReuseIdentifier: String(describing: CellTextXib.self))
        viewSpread.register(UINib(nibName: String(describing: MoreEditOption.self), bundle: nil), forCellWithReuseIdentifier: String(describing: MoreEditOption.self))
        viewSpread.bounces = false
        viewSpread.dataSource = self
        viewSpread.delegate = self
//        setupHomeFolder()
        getParentFoldersFromSiteId()
    }
    
    func getParentFoldersFromSiteId() {
        loadingStatus = .loading
        folderCollection = [FolderCollectonModel(name: "Documents", id: 0)]
        viewSpread.reloadData()

        guard let siteID = UserConstants.shared.selectedSiteID else {
            self.loadingStatus = .failed
            return
        }
        let apiService = ApiService.documentSiteParentFoldersAPI(siteId: siteID)
        
        self.loadingStatus = .loading
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<ParentFoldersResponse>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single(let single):
                    self.homeFolder = single.parentFolders ?? []
                    self.loadingStatus = self.homeFolder.isEmpty ? .noResponse : .default
                    setupHomeFolder()
                case .array:
                    self.loadingStatus = .failed
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                self.loadingStatus = .failed
            }
        }
    }

    
    @IBAction func btnCloseClick(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    func setupHomeFolder() {
        self.loadingStatus = self.homeFolder.isEmpty ? .noResponse : .default
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
    
    func handleTheCopyAndMoveEvent(id: Int, folderName: String) {
        switch actionType {
        case .copy:
            showCopyAlert(folderName: folderName, id: id)
            break
        case .move:
            showMoveAlert(folderName: folderName, id: id)
            break
        case .select:
            if let delegate = self.addFolderToContractsDelegate as? CreateContractsVC {
                if !delegate.selectedAssetsItemArray.isEmpty {
                    for item in delegate.selectedAssetsItemArray {
                        if item.values.first == id {
                            SCLAlertView().showError("Error", subTitle: "\(folderName) is already selected")
                            return
                        }
                    }
                }
                delegate.addFolderToCreateContract(folderName: folderName, folderId: id)
                self.showToast(message: "\(folderName) is selected.")
            }else if isNeedToClose {
                self.addFolderToContractsDelegate?.addFolderToCreateContract(folderName: folderName, folderId: id)
                self.dismiss(animated: true)
            }
        }
    }
    
    func showMoveAlert(folderName: String, id: Int) {
        guard let fileName = self.selectedFile?.name else {return}
        // Create the alert controller
        let alertController = UIAlertController(
            title: "Move File",
            message: "Do you want to move \(fileName) to \(folderName)?",
            preferredStyle: .alert
        )

        // Create the "Copy" action
        let copyAction = UIAlertAction(title: "Move", style: .default) { [weak self] (_) in
            DispatchQueue.main.async { [weak self] in
                guard let self, let selectedFile = selectedFile?.id else {return}
                let moveApi = ApiService.documnetFileMove(folderId: id, fileID: selectedFile)
                let appearance = SCLAlertView.SCLAppearance(
                    showCloseButton: false // if you dont want the close button use false
                )
                let sclAlert = SCLAlertView(appearance: appearance)
                sclAlert.showWait("", subTitle: "please wait...", closeButtonTitle: "")
                APIClient.request(moveApi) { [weak self] (result: Result<APIClient.MappableResult<FileResponseData>, Error>) in
                    DispatchQueue.main.async { [weak self] in
                        sclAlert.hideView()
                        switch result {
                        case .success(let responseResult):
                            if case .single(let documentResponse) = responseResult {
                                guard let self = self else { return }
                                SCLAlertView().showSuccess("", subTitle: "Move Successfully.")
                                self.dismiss(animated: true)
                            }
                        case .failure(let error):
                            SCLAlertView().showError("Error", subTitle: "Oops! please try again")
                        }
                    }
                }
            }
        }

        // Create the "Cancel" action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            // Code to handle the cancel action (if needed)
            print("Copy operation cancelled")
        }

        // Add the actions to the alert controller
        alertController.addAction(copyAction)
        alertController.addAction(cancelAction)

        // Present the alert
        self.present(alertController, animated: true)
    }
    
    func showCopyAlert(folderName: String, id: Int) {
        guard let fileName = self.selectedFile?.name else {return}
        // Create the alert controller
        let alertController = UIAlertController(
            title: "Copy File",
            message: "Do you want to copy \(fileName) to \(folderName)?",
            preferredStyle: .alert
        )

        // Create the "Copy" action
        let copyAction = UIAlertAction(title: "Copy", style: .default) { [weak self] (_) in
            DispatchQueue.main.async { [weak self] in
                guard let self, let selectedFile = selectedFile?.id else {return}
                let moveApi = ApiService.documnetFileCopy(folderId: id, fileID: selectedFile)
                let appearance = SCLAlertView.SCLAppearance(
                    showCloseButton: false // if you dont want the close button use false
                )
                let sclAlert = SCLAlertView(appearance: appearance)
                sclAlert.showWait("", subTitle: "please wait...", closeButtonTitle: "")
                APIClient.request(moveApi) { [weak self] (result: Result<APIClient.MappableResult<FileResponseData>, Error>) in
                    DispatchQueue.main.async { [weak self] in
                        sclAlert.hideView()
                        switch result {
                        case .success(let responseResult):
                            if case .single(let documentResponse) = responseResult {
                                guard let self = self else { return }
                                SCLAlertView().showSuccess("", subTitle: "Copy Successfully.")
                                self.dismiss(animated: true)
                            }
                        case .failure(let error):
                            SCLAlertView().showError("Error", subTitle: "Oops! please try again")
                        }
                    }
                }
            }
        }

        // Create the "Cancel" action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            // Code to handle the cancel action (if needed)
            print("Copy operation cancelled")
        }

        // Add the actions to the alert controller
        alertController.addAction(copyAction)
        alertController.addAction(cancelAction)

        // Present the alert
        self.present(alertController, animated: true)
    }

    func reloadCollection() {
        viewSpread.reloadData()
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
                if homeFolder.isEmpty {
                    return 1+1
                }else {
                    return homeFolder.count+1
                }
            }else {
                let folderCount = self.subFolderDetails?.document?.childFolders?.count ?? 0
                return 1+1+folderCount
            }
        case .loading, .failed, .noResponse, .noInternet:
            if folderCollection.count == 1 {
                return 1+1
            }else {
                return 1+1+1
            }
        }
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        switch loadingStatus {
        case .loading, .failed, .noResponse, .noInternet:
            if folderCollection.count == 1 {
                var stringsArray = [headerRow[column]]
                let maxColumnWidth = getMaxLabelSize(textArray: stringsArray, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 200).width

                if column == 0 {
                    let coloumSecondWidth = getMaxLabelSize(textArray: [headerRow[1]], font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 250).width
//                    self.widthOfSpredView.constant = min(screenWidth-20.0, maxColumnWidth+coloumSecondWidth+3.0)
                }
                return maxColumnWidth
            }else {
                let stringsArray = [folderCollection.last?.name ?? ""]
                let folderWidth = getMaxLabelSize(textArray: stringsArray, font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 5+35+5+5, maxWidth: 250).width
                
                let headerWidth = getMaxLabelSize(textArray: [headerRow[column]], font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 250).width
                
                if column == 0 {
                    let coloumSecondWidth = getMaxLabelSize(textArray: [headerRow[1]], font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 250).width
//                    self.widthOfSpredView.constant = min(screenWidth-20.0, (folderWidth > headerWidth ? folderWidth : headerWidth)+coloumSecondWidth+3.0)
                }
                
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
                
                if column == 0 {
                    let coloumSecondWidth = getMaxLabelSize(textArray: [headerRow[1]], font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 250).width
//                    self.widthOfSpredView.constant = min(screenWidth-20.0, (folderWidth > headerWidth ? folderWidth : headerWidth)+coloumSecondWidth+3.0)
                }
                
                
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
                
                var width: CGFloat = 0
                
                if (subFolderDetails?.document?.childFolders?.isEmpty ?? true) && (subFolderDetails?.document?.files?.isEmpty ?? true) {
                    width = folderWidth > headerWidth ? folderWidth : headerWidth
                }else {
                    width = (folderWidth > headerWidth ? folderWidth : headerWidth) + 15
                }

                if column == 0 {
                    let coloumSecondWidth = getMaxLabelSize(textArray: [headerRow[1]], font: UIFont(name: .MontserratSemiBold, size: textFontSize), minWidth: 50, widthAddition: 12+12, maxWidth: 250).width
//                    self.widthOfSpredView.constant = min(screenWidth-20.0, width+coloumSecondWidth+3.0)
                }

                return width
                
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
            if folderCollection.count == 1 {
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "CellTextXib", for: indexPath) as! CellTextXib
                cellBorderSetUp(cell: cell, isHeader: false)
                cell.lblText.addCorner(value: 0)
                cell.lblText.font = UIFont(name: .MontserratRegular, size: textFontSize)
                cell.lblText.textColor = UIColor.black
                cell.lblText.backgroundColor = UIColor.clear
                cell.lblText.text = loadingStatus.rawValue
                return cell
            }
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
                cell.imgView.image = actionType == .select ? UIImage(systemName: "plus")?.withRenderingMode(.alwaysTemplate) : actionType == .copy ?  UIImage(systemName: "doc.on.doc") : UIImage(systemName: "arrowshape.turn.up.right")
                cell.imgViewHeight.constant = actionType == .select ? 26 : 32
                cell.imgView.tintColor = actionType == .select ? .appTint : .systemBlue
                cell.btnPreview.addAction { [weak self] in
                    guard let self else { return }
                    if let id = folderCollection.last?.id {
//                        self.fetchData(id: id)
                        self.handleTheCopyAndMoveEvent(id: id, folderName: folderCollection.last?.name ?? "")
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
                cell.imgView.image = actionType == .select ? UIImage(systemName: "plus")?.withRenderingMode(.alwaysTemplate) : actionType == .copy ?  UIImage(systemName: "doc.on.doc") : UIImage(systemName: "arrowshape.turn.up.right")
                cell.imgViewHeight.constant = actionType == .select ? 26 : 32
                cell.imgView.tintColor = actionType == .select ? .appTint : .systemBlue
                cell.btnPreview.addAction { [weak self] in
                    guard let self else { return }
                    if let id = homeFolder[indexPath.row-1].id {
//                        self.folderCollection.append(FolderCollectonModel(name: homeFolder[indexPath.row-1].name ?? "", id: id))
//                        self.fetchData(id: id)
                        self.handleTheCopyAndMoveEvent(id: id, folderName: homeFolder[indexPath.row-1].name ?? "")
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
                cell.imgView.image = actionType == .select ? UIImage(systemName: "plus")?.withRenderingMode(.alwaysTemplate) : actionType == .copy ?  UIImage(systemName: "doc.on.doc") : UIImage(systemName: "arrowshape.turn.up.right")
                cell.moreIconImgWidthCons.constant = actionType == .select ? 26 : 32
                cell.imgView.tintColor = actionType == .select ? .appTint : .systemBlue
                if indexPath.row == 1 {
                    cell.btnAction.addAction { [weak self] in
                        guard let self else { return }
                        if let id = self.folderCollection.last?.id {
                            self.handleTheCopyAndMoveEvent(id: id, folderName: self.folderCollection.last?.name ?? "")
                        }
                    }
                }else if indexPath.row <= (self.subFolderDetails?.document?.childFolders?.count ?? 0) + 1 {
                    cell.btnAction.addAction { [weak self] in
                        guard let self else { return }
                        if let id = self.subFolderDetails?.document?.childFolders?[indexPath.row-2].id {
                            self.handleTheCopyAndMoveEvent(id: id, folderName: self.subFolderDetails?.document?.childFolders?[indexPath.row-2].name ?? "")
                        }
                    }
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
            if folderCollection.count == 1 {
                return [CellRange(from: IndexPath(row: 1, column: 0), to: IndexPath(row: 1, column: totalColumn-1))]
            }
            return [CellRange(from: IndexPath(row: 2, column: 0), to: IndexPath(row: 2, column: totalColumn-1))]
        }
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, didSelectItemAt indexPath: IndexPath) {
        if (loadingStatus == .noInternet || loadingStatus == .failed) {
            if folderCollection.count == 1 {
                self.getParentFoldersFromSiteId()
            }else if let id = folderCollection.last?.id {
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
