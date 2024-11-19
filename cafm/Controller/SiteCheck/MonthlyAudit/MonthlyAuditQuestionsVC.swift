//
//  MonthlyAuditQuestionsVC.swift
//  cafm
//
//  Created by NS on 12/11/24.
//
//

import UIKit
import SCLAlertView

class MonthlyAuditQuestionsVC: UIViewController {
    
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
    var assetsItemArray: [AssetDetailsResponse] = []
    var SITE_CHECK_AUDIT_HEADER_ItemArray: [LOV_Model] = []
    var questionCat: String = ""
    
    private var sectionArray: [SectionData] = []
    
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

extension MonthlyAuditQuestionsVC {
    struct SectionData {
        var header: LOV_Model
        var itemArray: [(question: SiteCheckAssessmentQuestions, response: SiteCheckAssessmentResponse)]
    }
}

//MARK: - EmptyViewDelegate
extension MonthlyAuditQuestionsVC: EmptyViewDelegate {
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
extension MonthlyAuditQuestionsVC {
    
    func loadData() {
        
    }
    
    func reloadAfterGetSiteCheckAssessmentResponseByCheckId(questionItemArray: [SiteCheckAssessmentQuestions], responseItemArray: [SiteCheckAssessmentResponse]) {
        self.questionItemArray = questionItemArray
        self.responseItemArray = responseItemArray
        self.reloadViews()
    }
    
}

//MARK: - setup views
extension MonthlyAuditQuestionsVC {
    
    func setupViews() {
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = UITableView.automaticDimension
        
        self.reloadViews()
    }
    
    func reloadViews() {
        self.sectionArray = self.SITE_CHECK_AUDIT_HEADER_ItemArray.filter({ $0.attribite1 == questionCat }).sorted(by: { Double($0.lovDesc ?? "0") ?? 0 < Double($1.lovDesc ?? "0") ?? 0 }).compactMap({ lov in
            let questions = self.questionItemArray.filter({ !($0.question?.contains("DELETE") ?? false) && ($0.order?.starts(with: (lov.lovDesc ?? "")+".") ?? false) })
            let itemArray = questions.compactMap { question in
                if let response = self.responseItemArray.first(where: { $0.qid == question.qid }) {
                    print("LogLog if", "question.qid:", question.qid ?? "NULL")
                    question.status = "Closed"
                    question.completed = true
                    return (question, response)
                }else {
                    print("LogLog else", "question.qid:", question.qid ?? "NULL")
                    let response = SiteCheckAssessmentResponse()
                    question.status = "Open"
                    question.completed = false
                    return (question, response)
                }
            }
            return SectionData(header: lov, itemArray: itemArray)
        })
        self.tableView.reloadData()
    }
    
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension MonthlyAuditQuestionsVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1+self.sectionArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else if self.sectionArray.count > section-1 {
            return self.sectionArray[section-1].itemArray.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return UIView(frame: CGRect(x: 0, y: 0, width: screenWidth-40, height: CGFloat.leastNonzeroMagnitude))
        }
        let section = section-1
        if self.sectionArray.count > section {
            let lov = self.sectionArray[section].header
            let title = "\(lov.lovDesc ?? "") \(lov.lovValue ?? "")"
            
            let viewWidth: CGFloat = screenWidth-40
            let view = UIView(frame: CGRect(x: 0, y: 0, width: viewWidth, height: 120))
            view.backgroundColor = UIColor.systemBackground
            
            let padding: CGFloat = 10
            let labelWidth: CGFloat = viewWidth-(padding*2)
            let label = UILabel(frame: CGRect(x: padding, y: padding, width: labelWidth, height: 120))
            label.text = title
            label.font = UIFont(name: .MontserratMedium, size: 21)
            label.textColor = UIColor(appColor: .PrimaryText)
            label.numberOfLines = 0
            let height = label.sizeThatFits(CGSize(width: labelWidth, height: CGFloat.greatestFiniteMagnitude)).height
            
            view.widthAnchor.constraint(equalToConstant: screenWidth-40).isActive = true
            view.heightAnchor.constraint(equalToConstant: height+(padding*2)).isActive = true
            
            label.widthAnchor.constraint(equalToConstant: labelWidth).isActive = true
            label.heightAnchor.constraint(equalToConstant: height).isActive = true
            label.sizeToFit()
            view.addSubview(label)
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20).isActive = true
            
            return view
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return CGFloat.leastNonzeroMagnitude
        }else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
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
            }
        }else {
            let section = indexPath.section-1
            let row = indexPath.row
            if self.sectionArray.count > section, self.sectionArray[section].itemArray.count > row  {
                let item = self.sectionArray[section].itemArray[row]
                
                let que = item.question
                let ans = item.response
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "AssessmentQuestionTableCell", for: indexPath) as! AssessmentQuestionTableCell
                cell.selectionStyle = .none
                cell.accessoryType = .disclosureIndicator
                
                cell.mainLbl.text = "\(que.order ?? "") \(que.question ?? "")"
                
                let status = ans.status ?? .open
                cell.setBadgeData(text: status.rawValue, textColor: status.textColor, bgColor: status.bgColor)
                
                return cell
            }
        }
        return UITableViewCell(style: .default, reuseIdentifier: "cell")
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
        }else {
            let section = indexPath.section-1
            let row = indexPath.row
            if self.sectionArray.count > section, self.sectionArray[section].itemArray.count > row  {
                let item = self.sectionArray[section].itemArray[row]
                let que = item.question
                let ans = item.response
                
                let vc = siteCheckSB.instantiateViewController(withIdentifier: "MonthlyAuditQuestionResponseVC") as! MonthlyAuditQuestionResponseVC
                vc.addSiteCheckVC = self.addSiteCheckVC
                vc.monthlyAuditQuestionsVC = self
                vc.question = que
                vc.response = ans
                vc.assetsItemArray = self.assetsItemArray
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
}

