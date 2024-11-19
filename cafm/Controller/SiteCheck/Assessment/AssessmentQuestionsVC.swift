//
//  AssessmentQuestionsVC.swift
//  cafm
//
//  Created by NS on 27/09/24.
//
//

import UIKit
import SCLAlertView

class AssessmentQuestionsVC: UIViewController {
    
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
    
    weak var addSiteCheckVC: AddSiteCheckVC?
    var siteCheckModel: SiteCheckModel?
    var questionItemArray: [SiteCheckAssessmentQuestions] = []
    var responseItemArray: [SiteCheckAssessmentResponse] = []
    var siteLayoutItemArray: [SiteLayoutModel] = []
    var assetsItemArray: [AssetDetailsResponse] = []
    
    private var itemArray: [(question: SiteCheckAssessmentQuestions, response: SiteCheckAssessmentResponse)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isModalInPresentation = true
        self.configureNavigationBar()
        self.emptyView.delegate = self
        self.setupViews()
        self.loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    func configureNavigationBar() {
        self.title = "Questions"
        let closeBtn = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(self.navCloseBtnClicked(_:)))
        self.navigationItem.leftBarButtonItem = closeBtn
        self.configureNavigationBackButton()
    }
    
    @objc func navCloseBtnClicked(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
}

//MARK: - EmptyViewDelegate
extension AssessmentQuestionsVC: EmptyViewDelegate {
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
extension AssessmentQuestionsVC {
    
    func loadData() {
        
    }
    
    func reloadAfterGetSiteCheckAssessmentResponseByCheckId(questionItemArray: [SiteCheckAssessmentQuestions], responseItemArray: [SiteCheckAssessmentResponse]) {
        self.questionItemArray = questionItemArray
        self.responseItemArray = responseItemArray
        self.reloadViews()
    }
    
}

//MARK: - setup views
extension AssessmentQuestionsVC {
    
    func setupViews() {
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = UITableView.automaticDimension
        
        self.reloadViews()
    }
    
    func reloadViews() {
        self.itemArray = []
        for question in self.questionItemArray {
            let respoonse = self.responseItemArray.first { $0.qid == question.qid } ?? SiteCheckAssessmentResponse()
            self.itemArray.append((question: question, response: respoonse))
        }
        self.tableView.reloadData()
    }
    
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension AssessmentQuestionsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2+self.itemArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EventCalendarTableCell", for: indexPath) as! EventCalendarTableCell
            cell.selectionStyle = .none
            cell.accessoryType = .none
            cell.bgView.addCorner(value: 8)
            let total = self.questionItemArray.count
            let closed = self.responseItemArray.filter { $0.status == .closed }.count
            let open = total-closed
            cell.mainLbl.text = "Total: \(total), Open: \(open), Closed: \(closed)"
            return cell
        }else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RiskScoreTableCell", for: indexPath) as! RiskScoreTableCell
            cell.selectionStyle = .none
            cell.accessoryType = .none
            
            if let xib = cell.xib {
                let greenResponse = self.responseItemArray.filter { [Int](1...4).contains($0.totalRiskScore ?? 0) }.count
                let yellowResponse = self.responseItemArray.filter { [Int](5...9).contains($0.totalRiskScore ?? 0) }.count
                let amberResponse = self.responseItemArray.filter { [Int](10...16).contains($0.totalRiskScore ?? 0) }.count
                let redResponse = self.responseItemArray.filter { [Int](17...25).contains($0.totalRiskScore ?? 0) }.count
                
                xib.greenRiskLbl.text = "\(greenResponse)"
                xib.yelloriskLbl.text = "\(yellowResponse)"
                xib.amberRiskLbl.text = "\(amberResponse)"
                xib.redRiskLbl.text = "\(redResponse)"
            }
            
            return cell
        }else {
            let index = indexPath.row-2
            if self.itemArray.count > index {
                let item = self.itemArray[index]
                let que = item.question
                let ans = item.response
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "AssessmentQuestionTableCell", for: indexPath) as! AssessmentQuestionTableCell
                cell.selectionStyle = .none
                cell.accessoryType = .disclosureIndicator
                
                if let question = que.question {
                    cell.mainLbl.text = "Q\(index+1). \(question)"
                }
                
                cell.yesXIB.isOn = ans.response == .yes
                cell.noXIB.isOn = ans.response == .no
                cell.yesXIB.isDisabled = ans.status == .closed
                cell.noXIB.isDisabled = ans.status == .closed
                let status = ans.status ?? .open
                cell.setBadgeData(text: status.rawValue, textColor: status.textColor, bgColor: status.bgColor)
                
                cell.yesXIB.actionBtn.addAction { [weak self] in
                    guard self != nil else { return }
                    ans.response = .yes
                    cell.yesXIB.isOn = true
                    cell.noXIB.isOn = !cell.yesXIB.isOn
                }
                cell.noXIB.actionBtn.addAction { [weak self] in
                    guard self != nil else { return }
                    ans.response = .no
                    cell.noXIB.isOn = true
                    cell.yesXIB.isOn = !cell.noXIB.isOn
                }
                
                return cell
            }
        }
        return UITableViewCell(style: .default, reuseIdentifier: "cell")
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
        }else if indexPath.row == 1 {
        }else {
            let index = indexPath.row-2
            if self.itemArray.count > index {
                let item = self.itemArray[index]
                let que = item.question
                let ans = item.response
                
                if ans.response == .no {
                    let vc = siteCheckSB.instantiateViewController(withIdentifier: "AssessmentQuestionResponseVC") as! AssessmentQuestionResponseVC
                    vc.addSiteCheckVC = self.addSiteCheckVC
                    vc.assessmentQuestionsVC = self
                    vc.questionIndex = index
                    vc.question = que
                    vc.response = ans
                    vc.siteLayoutItemArray = self.siteLayoutItemArray
                    vc.assetsItemArray = self.assetsItemArray
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
}
