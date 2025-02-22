//
//  BasicReportsVC.swift
//  cafm
//
//  Created by NS on 01/12/24.
//
//

import UIKit
import SCLAlertView

class BasicReportsVC: UIViewController {
    
    @IBOutlet weak var emptyView: EmptyView!
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    private let loadingSCLAlertView = SCLAlertView(appearance: loadingSCLAppearance)
    private var loadingStatus: LoadingStatus = .default {
        didSet {
            if self.loadingStatus.hasData {
                self.mainView.isHidden = false
                self.emptyView.isHidden = true
            }else {
                if self.loadingStatus == .loading || self.loadingStatus.shouldReload {
                    self.emptyView.mainLbl.text = self.loadingStatus.rawValue
                    self.emptyView.isHidden = false
                    self.mainView.isHidden = true
                }else {
                    self.mainView.isHidden = false
                    self.emptyView.isHidden = true
                }
            }
        }
    }
    
    weak var homeVC: ReportsVC?
    var isViewModeEdit: Bool = false
    
    private let kResponseDateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    private let kRequestDateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'" //"yyyy-MM-dd HH:mm:ss"
    private let ddMMyyyyStr = "dd/MM/yyyy"
    private let yyyyMMddStr = "yyyy-MM-dd"
    
    private let itemArray = basicReportsQuestions
    private var siteItemArray: [CreateSiteRequestModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emptyView.delegate = self
        self.setupViews()
        self.loadData()
    }
    
}

//MARK: - EmptyViewDelegate
extension BasicReportsVC: EmptyViewDelegate {
    func emptyViewDidTapView(_ view: EmptyView) {
        if self.loadingStatus.shouldReload {
            self.loadData()
        }
    }
    
    func hideLoadingAndShowError(message: String? = nil) {
        self.loadingSCLAlertView.hideView()
        let subTitle: String = message ?? "Something went wrong, Please try again!"
        SCLAlertView.showErrorAlert(title: "Error", message: subTitle, cancelButtonTitle: "OK")
    }
}

//MARK: - load data
extension BasicReportsVC {
    
    func loadData() {
        self.getAllSitesWithDetails()
    }
    
    func getAllSitesWithDetails() {
        self.loadingStatus = .loading
        let apiService = ApiService.siteAllWithDetails(withDetails: true)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<CreateSiteRequestModel>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single:
                    self.loadingStatus = .failed
                    break
                case .array(let array):
                    self.siteItemArray = array
                    //self.reloadViews()
                    self.loadingStatus = .default
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                self.loadingStatus = .failed
            }
        }
    }
    
}

//MARK: - setup views
extension BasicReportsVC {
    
    func setupViews() {
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.separatorStyle = .none
        
        self.reloadViews()
    }
    
    func reloadViews() {
        self.tableView.reloadData()
    }
    
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension BasicReportsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.itemArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.selectionStyle = .none
        
        if self.itemArray.count > indexPath.row {
            let item = self.itemArray[indexPath.row]
            
            cell.textLabel?.text = "• " + item.question
            cell.textLabel?.font = UIFont(name: .MontserratMedium, size: 17)
            cell.textLabel?.textColor = UIColor(appColor: .AppTint)
            cell.textLabel?.numberOfLines = 0
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.itemArray.count > indexPath.row {
            let item = self.itemArray[indexPath.row]
            
            let vc = reportsSB.instantiateViewController(withIdentifier: "BasicReportsTableVC") as! BasicReportsTableVC
            vc.question = item
            vc.itemArrayJson = self.siteItemArray.toJSON().filter({ json in
                if let main = json[item.main] as? [String: Any] {
                    return main[item.key] != nil
                }
                return false
            })
            self.homeVC?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}
