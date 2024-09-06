//
//  SiteInformationVC.swift
//  cafm
//
//  Created by NS on 01/09/24.
//
//

import UIKit
import SCLAlertView

class SiteInformationVC: UIViewController {
    
    @IBOutlet weak var emptyView: EmptyView!
    @IBOutlet weak var tableView: UITableView!
    
    let loadingSCLAlertView = SCLAlertView(appearance: loadingSCLAppearance)
    
    var loadingStatus: LoadingStatus = .default {
        didSet {
            if self.loadingStatus.hasData {
                self.tableView.isHidden = false
                self.emptyView.isHidden = true
            }else {
                self.emptyView.mainLbl.text = self.loadingStatus.rawValue
                self.emptyView.isHidden = false
                self.tableView.isHidden = true
            }
        }
    }
    
    weak var homeVC: CreateNewSiteVC?
    var selectedSiteID: Int?
    var isViewModeEdit: Bool = false
    
    let itemArray: [SiteInformationEnum] = SiteInformationEnum.allCases
    
    var siteInfoModel: SiteInformationModel?
    var siteAreaModel: SiteInformationModel?
    var siteSafetyModel: SiteInformationModel?
    var siteUtilityModel: SiteInformationModel?
    var siteLiftsModel: SiteInformationModel?
    var siteScapeModel: SiteInformationModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emptyView.delegate = self
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = UITableView.automaticDimension
        
        self.loadData()
    }
    
    func loadData() {
        guard let siteID = self.selectedSiteID else {
            return
        }
        
        self.loadingStatus = .loading
        var itemCompleted: Int = 0
        let itemCompletion: (() -> Void) = { [weak self] in
            guard let strongSelf = self else { return }
            itemCompleted += 1
            if itemCompleted == strongSelf.itemArray.count {
                strongSelf.loadingStatus = .default
            }
        }
        for item in self.itemArray {
            let apiService = ApiService.getSiteSiteInfo(siteId: siteID, query: item.rawValue)
            APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<SiteInformationModel>, Error>) in
                guard let strongSelf = self else { return }
                switch result {
                case .success(let mappableResult):
                    switch mappableResult {
                    case .single(let result):
                        switch item {
                        case .siteInfo:
                            strongSelf.siteInfoModel = result
                        case .siteArea:
                            strongSelf.siteAreaModel = result
                        case .siteSafety:
                            strongSelf.siteSafetyModel = result
                        case .siteUtility:
                            strongSelf.siteUtilityModel = result
                        case .siteLifts:
                            strongSelf.siteLiftsModel = result
                        case .siteScape:
                            strongSelf.siteScapeModel = result
                        }
                        strongSelf.tableView.reloadData()
                        break
                    case .array:
                        strongSelf.loadingStatus = .failed
                        break
                    }
                case .failure(let error):
                    print(apiService.api(), "Error:", error.localizedDescription)
                    strongSelf.loadingStatus = .failed
                }
                itemCompletion()
            }
        }
    }
    
    func saveSiteInformation() {
        
    }
    
}

extension SiteInformationVC: EmptyViewDelegate {
    func emptyViewDidTapView(_ view: EmptyView) {
        if self.loadingStatus.shouldReload {
            self.loadData()
        }
    }
}

extension SiteInformationVC: SiteInformationDelegate {
    func performSiteInformationSaveAction(modelType: SiteInformationEnum, model: SiteInformationModel?) {
        let apiService: ApiService
        
        switch modelType {
        case .siteInfo:
            apiService = ApiService.siteSiteInfo(model: self.siteInfoModel)
        case .siteArea:
            apiService = ApiService.siteSiteAreaInfo(model: self.siteAreaModel)
        case .siteSafety:
            apiService = ApiService.siteSiteSecurityInfo(model: self.siteSafetyModel)
        case .siteUtility:
            apiService = ApiService.siteSiteUtilityInfo(model: self.siteUtilityModel)
        case .siteLifts:
            apiService = ApiService.siteSiteLiftInfo(model: self.siteLiftsModel)
        case .siteScape:
            apiService = ApiService.siteSiteLandscapeInfo(model: self.siteScapeModel)
        }
        
        self.loadingSCLAlertView.showLoading()
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<SiteInformationModel>, Error>) in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single(let result):
                    switch modelType {
                    case .siteInfo:
                        strongSelf.siteInfoModel = result
                    case .siteArea:
                        strongSelf.siteAreaModel = result
                    case .siteSafety:
                        strongSelf.siteSafetyModel = result
                    case .siteUtility:
                        strongSelf.siteUtilityModel = result
                    case .siteLifts:
                        strongSelf.siteLiftsModel = result
                    case .siteScape:
                        strongSelf.siteScapeModel = result
                    }
                    strongSelf.loadingSCLAlertView.hideView()
                    break
                case .array:
                    strongSelf.hideLoadingAndShowError()
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                strongSelf.hideLoadingAndShowError()
            }
        }
    }
    
    func hideLoadingAndShowError(message: String? = nil) {
        self.loadingSCLAlertView.hideView()
        let subTitle = message ?? "Something went wrong, Please try again!"
        SCLAlertView.showLoading(title: "Error", message: subTitle, cancelButtonTitle: "OK")
    }
    
}

extension SiteInformationVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.itemArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.selectionStyle = .none
        cell.accessoryType = .disclosureIndicator
        
        if self.itemArray.count > indexPath.row {
            let item = self.itemArray[indexPath.row]
            cell.textLabel?.text = item.title
            cell.textLabel?.font = UIFont(name: .MontserratMedium, size: 15)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.itemArray.count > indexPath.row {
            let item = self.itemArray[indexPath.row]
            let vc = generalSB.instantiateViewController(withIdentifier: "SiteInformationDetailVC") as! SiteInformationDetailVC
            vc.delegate = self
            vc.isViewModeEdit = self.isViewModeEdit
            vc.screenType = item
            switch item {
            case .siteInfo:
                vc.siteInformationModel = self.siteInfoModel
            case .siteArea:
                vc.siteInformationModel = self.siteAreaModel
            case .siteSafety:
                vc.siteInformationModel = self.siteSafetyModel
            case .siteUtility:
                vc.siteInformationModel = self.siteUtilityModel
            case .siteLifts:
                vc.siteInformationModel = self.siteLiftsModel
            case .siteScape:
                vc.siteInformationModel = self.siteScapeModel
            }
            let nav = UINavigationController(rootViewController: vc)
            self.present(nav, animated: true)
        }
    }
    
}
