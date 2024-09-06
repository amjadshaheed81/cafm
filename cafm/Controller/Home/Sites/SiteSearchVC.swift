//
//  SiteSearchVC.swift
//  cafm
//
//  Created by NS on 21/08/24.
//
//

import UIKit
import SCLAlertView

class SiteSearchVC: UIViewController {
    
    //@IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var createNewSiteView: DesignableView!
    @IBOutlet weak var createNewSiteViewHeight: NSLayoutConstraint!
    
    let searchController = UISearchController(searchResultsController: nil)
    private var searchBar: UISearchBar! {
        return self.searchController.searchBar
    }
    let loadingSCLAlertView = SCLAlertView(appearance: loadingSCLAppearance)
    
    weak var delegate: SiteSearchDelegate?
    
    var filterSiteArray: [SiteModel] = []
    var favoriteSiteIDs: [Int] = []
    
    let userRole: UserEnum = UserDefaults.standard.userRole
    
    override func loadView() {
        super.loadView()
        self.navigationController?.view.backgroundColor = UIColor.white
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationItem.searchController = self.searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchBar.placeholder = "Search for Site"
        self.searchBar.searchTextField.font = UIFont(name: .MontserratRegular, size: 17)
        
        self.searchBar.delegate = self
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.tableView.rowHeight = UITableView.automaticDimension
        
        self.setup()
        
        self.setFavoriteSiteIDs()
        self.filterSiteArray = UserConstants.shared.allSites
        reloadTableView()
    }
    
    func setup() {
        if userRole != .admin {
            hideCreateNewSiteView()
        }
    }
    
    func hideCreateNewSiteView() {
        let height: CGFloat = 0
        self.createNewSiteViewHeight.constant = height
        self.createNewSiteView.frame.size.height = height
    }
    
    func reloadTableView() {
        self.tableView.reloadData()
        self.tableView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    func setFavoriteSiteIDs() {
        if let favorite = UserConstants.shared.userDetail?.favorite {
            self.favoriteSiteIDs = favorite.components(separatedBy: ",").compactMap({ Int($0) })
        }
    }
    
    @IBAction func createNewSiteBtnClicked(_ sender: UIButton) {
        //TODO: Savan
        let vc = siteActionSB.instantiateViewController(withIdentifier: "CreateNewSiteVC") as! CreateNewSiteVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func hideLoadingAndShowError(addToFavorite: Bool = false, removeFromFavorite: Bool = false, message: String? = nil) {
        self.loadingSCLAlertView.hideView()
        let subTitle: String
        if addToFavorite {
            subTitle = "Failed to add to Favorite!"
        }else if removeFromFavorite {
            subTitle = "Failed to remove from Favorite!"
        }else {
            subTitle = message ?? "Something went wrong, Please try again!"
        }
        SCLAlertView.showLoading(title: "Error", message: subTitle, cancelButtonTitle: "OK")
    }
    
    func getUserDetails(sites: [SiteModel]? = nil, afterManage: Bool, addToFavorite: Int?, removeFromFavorite: Int?) {
        guard let userID = UserConstants.shared.currentUserID else {
            self.hideLoadingAndShowError(addToFavorite: addToFavorite != nil, removeFromFavorite: removeFromFavorite != nil)
            return
        }
        let apiService = ApiService.userDetailsAPI(userId: userID)
        
        self.loadingSCLAlertView.showLoading()
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<UserModel>, Error>) in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single(let response):
                    UserConstants.shared.userDetail = response
                    if let sites {
                        UserConstants.shared.setAllSites(from: sites)
                        strongSelf.setFavoriteSiteIDs()
                        strongSelf.filterSiteArray = UserConstants.shared.allSites
                        strongSelf.reloadTableView()
                    }
                    if afterManage {
                        strongSelf.loadingSCLAlertView.hideView()
                    }else {
                        let favorite = response.favorite ?? ""
                        var favoriteSiteIDs = favorite.components(separatedBy: ",").compactMap({ Int($0) })
                        if let addToFavorite {
                            favoriteSiteIDs.append(addToFavorite)
                            if favoriteSiteIDs.count == 1 {
                                response.favorite = "\(addToFavorite)"
                            }else {
                                response.favorite = favoriteSiteIDs.compactMap({ "\($0)" }).joined(separator: ",")
                            }
                        }else if let removeFromFavorite {
                            favoriteSiteIDs.removeAll { $0 == removeFromFavorite }
                            if favoriteSiteIDs.isEmpty {
                                response.favorite = ""
                            }else {
                                response.favorite = favoriteSiteIDs.compactMap({ "\($0)" }).joined(separator: ",")
                            }
                        }
                        strongSelf.callUserManage(addToFavorite: addToFavorite, removeFromFavorite: removeFromFavorite)
                    }
                    break
                case .array:
                    strongSelf.hideLoadingAndShowError(addToFavorite: addToFavorite != nil, removeFromFavorite: removeFromFavorite != nil)
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                strongSelf.hideLoadingAndShowError(addToFavorite: addToFavorite != nil, removeFromFavorite: removeFromFavorite != nil)
            }
        }
    }
    
    func callUserManage(addToFavorite: Int?, removeFromFavorite: Int?) {
        if let manageUserDetail = UserConstants.shared.userDetail {
            manageUserDetail.userId = manageUserDetail.id
            if let name = manageUserDetail.name {
                let components = splitName(fullName: name)
                manageUserDetail.firstName = components.firstName
                manageUserDetail.lastName = components.lastName
            }
            let apiService = ApiService.userManageAPI(userModel: manageUserDetail)
            
            APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<UserModel>, Error>) in
                guard let strongSelf = self else { return }
                switch result {
                case .success(let mappableResult):
                    switch mappableResult {
                    case .single(let response):
                        UserConstants.shared.userDetail = response
                        strongSelf.getAllSites(addToFavorite: addToFavorite, removeFromFavorite: removeFromFavorite)
                        break
                    case .array:
                        strongSelf.hideLoadingAndShowError(addToFavorite: addToFavorite != nil, removeFromFavorite: removeFromFavorite != nil)
                        break
                    }
                case .failure(let error):
                    print(apiService.api(), "Error:", error.localizedDescription)
                    strongSelf.hideLoadingAndShowError(addToFavorite: addToFavorite != nil, removeFromFavorite: removeFromFavorite != nil)
                }
            }
        }
    }
    
    func getAllSites(addToFavorite: Int?, removeFromFavorite: Int?) {
        let apiService = ApiService.siteAllDetails
        
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<SiteModel>, Error>) in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single:
                    strongSelf.hideLoadingAndShowError(addToFavorite: addToFavorite != nil, removeFromFavorite: removeFromFavorite != nil)
                    break
                case .array(let array):
                    strongSelf.getUserDetails(sites: array, afterManage: true, addToFavorite: nil, removeFromFavorite: nil)
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                strongSelf.hideLoadingAndShowError(addToFavorite: addToFavorite != nil, removeFromFavorite: removeFromFavorite != nil)
            }
        }
    }
    
}

extension SiteSearchVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let text = searchText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).lowercased()
        if text.isEmpty {
            self.filterSiteArray = UserConstants.shared.allSites
            self.tableView.reloadData()
            self.tableView.setContentOffset(CGPoint.zero, animated: true)
        }else {
            self.filterSiteArray = UserConstants.shared.allSites.filter({ $0.siteName?.lowercased().contains(text) ?? false })
            self.tableView.reloadData()
            self.tableView.setContentOffset(CGPoint.zero, animated: true)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.filterSiteArray = UserConstants.shared.allSites
        self.tableView.reloadData()
        self.tableView.setContentOffset(CGPoint.zero, animated: true)
    }
    
}

extension SiteSearchVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filterSiteArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchSiteCell", for: indexPath) as! SearchSiteCell
        if self.filterSiteArray.count > indexPath.row {
            let item = self.filterSiteArray[indexPath.row]
            
            cell.favoriteClickAction = { [weak self] sender in
                guard let strongSelf = self else { return }
                if let id = item.siteId {
                    if strongSelf.favoriteSiteIDs.contains(id) {
                        strongSelf.getUserDetails(afterManage: false, addToFavorite: nil, removeFromFavorite: id)
                    }else {
                        strongSelf.getUserDetails(afterManage: false, addToFavorite: id, removeFromFavorite: nil)
                    }
                }
            }
            
            cell.siteNameLbl.text = item.siteName
            if let id = item.siteId, self.favoriteSiteIDs.contains(id) {
                cell.favoriteImageView.image = UIImage(appSystemImage: .favorite)
            }else {
                cell.favoriteImageView.image = UIImage(appSystemImage: .unfavorite)
            }
            
            cell.setSiteImageViewHidden(true)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.filterSiteArray.count > indexPath.row {
            let item = self.filterSiteArray[indexPath.row]
            
            //TODO: NKS
            //let vc = generalSB.instantiateViewController(withIdentifier: "SiteInformationVC") as! SiteInformationVC
            //let vc = generalSB.instantiateViewController(withIdentifier: "FloorLayoutPlanVC") as! FloorLayoutPlanVC
            //vc.selectedSiteID = item.siteId
            //vc.isViewModeEdit = true
            //self.navigationController?.pushViewController(vc, animated: true)
            
            self.delegate?.siteSearchDidSelectSite(item)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
}

protocol SiteSearchDelegate: AnyObject {
    func siteSearchDidSelectSite(_ site: SiteModel)
}
