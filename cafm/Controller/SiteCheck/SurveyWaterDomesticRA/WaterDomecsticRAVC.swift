//
//  WaterDomecsticRAVC.swift
//  cafm
//
//  Created by NS on 09/10/24.
//
//

import UIKit
import SCLAlertView

class WaterDomecsticRAVC: UIViewController {
    
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
    var raSurveyRiskFactorsItemArray: [SiteCheckRASurveyRiskFactors] = []
    var domesticRASurveyItemArray: [SiteCheckAssessmentResponse] = []
    var SITE_CHECK_DOMESTIC_RA_SCORES_ItemArray: [LOV_Model] = []
    var assetsItemArray: [AssetDetailsResponse] = []
    
    private var itemArray: [(question: SiteCheckRASurveyRiskFactors, response: SiteCheckAssessmentResponse)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isModalInPresentation = true
        self.configureNavigationBar()
        self.emptyView.delegate = self
        self.setupViews()
        self.loadData()
    }
    
    func configureNavigationBar() {
        self.title = "Risk Factors"
        let closeBtn = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(self.navCloseBtnClicked(_:)))
        self.navigationItem.leftBarButtonItem = closeBtn
        self.configureNavigationBackButton()
    }
    
    @objc func navCloseBtnClicked(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
}

//MARK: - EmptyViewDelegate
extension WaterDomecsticRAVC: EmptyViewDelegate {
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
extension WaterDomecsticRAVC {
    
    func loadData() {
        
    }
    
    func reloadAfterGetSiteCheckDomesticRASurveyByCheckId(raSurveyRiskFactorsItemArray: [SiteCheckRASurveyRiskFactors], domesticRASurveyItemArray: [SiteCheckAssessmentResponse]) {
        self.raSurveyRiskFactorsItemArray = raSurveyRiskFactorsItemArray
        self.domesticRASurveyItemArray = domesticRASurveyItemArray
        self.reloadViews()
    }
    
}

extension WaterDomecsticRAVC {
    
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
        for question in self.raSurveyRiskFactorsItemArray {
            let respoonse = self.domesticRASurveyItemArray.first { $0.riskFactorId == question.riskFactorID } ?? SiteCheckAssessmentResponse()
            self.itemArray.append((question: question, response: respoonse))
        }
        self.tableView.reloadData()
    }
    
    func getChipColor(score: Int) -> (textColor: UIColor, bgColor: UIColor) {
        if (score > 17) {
            return (textColor: UIColor(hexString: "EF0505"), bgColor: UIColor(hexString: "F6E4E4"))
        } else if (score > 10) {
            return (textColor: UIColor(hexString: "ff6700"), bgColor: UIColor(hexString: "ffd7b5"))
        } else if (score > 5) {
            return (textColor: UIColor(hexString: "B39200"), bgColor: UIColor(hexString: "FDF8E1"))
        } else {
            return (textColor: UIColor(hexString: "0b903f"), bgColor: UIColor(hexString: "e2f0e6"))
        }
    }
    
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension WaterDomecsticRAVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2+self.itemArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EventCalendarTableCell", for: indexPath) as! EventCalendarTableCell
            cell.selectionStyle = .none
            cell.accessoryType = .none
            cell.bgView.addCorner(value: 8)
            
            let bgColor = UIColor(appColor: .AmberStatus)
            let textColor = UIColor.white
            cell.bgView.backgroundColor = bgColor
            cell.mainLbl.textColor = textColor
            
            let imageAttachment = NSTextAttachment()
            imageAttachment.image = UIImage(systemName: "info.circle")?.withTintColor(cell.mainLbl.textColor ?? textColor, renderingMode: .alwaysOriginal)
            imageAttachment.bounds = CGRect(x: 0, y: -4, width: 20, height: 20)
            let imageString = NSAttributedString(attachment: imageAttachment)
            
            let totalScore = self.domesticRASurveyItemArray.compactMap({ $0.weightedScore }).reduce(0, +)
            let textString = NSAttributedString(string: "  Overall Risk Score: \(totalScore)")
            
            let combinedString = NSMutableAttributedString()
            combinedString.append(imageString)
            combinedString.append(textString)
            
            cell.mainLbl.attributedText = combinedString
            return cell
        }else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RiskScoreTableCell", for: indexPath) as! RiskScoreTableCell
            cell.selectionStyle = .none
            cell.accessoryType = .none
            
            let itemArray = self.domesticRASurveyItemArray.compactMap({ $0.weightedScore })
            if let xib = cell.xib {
                
                let greenResponse = itemArray.filter { $0 < 6 }.count
                let yellowResponse = itemArray.filter { [Int](6...10).contains($0) }.count
                let amberResponse = itemArray.filter { [Int](11...16).contains($0) }.count
                let redResponse = itemArray.filter { $0 > 17 }.count
                
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
                
                if let question = que.riskFactor {
                    cell.mainLbl.text = question
                }
                
                let score = ans.weightedScore ?? 0
                let status = getChipColor(score: score)
                cell.setBadgeData(text: "Weighted Score: \(score)", font: UIFont(name: .MontserratMedium, size: dashboardPrimaryTextSize), textColor: status.textColor, bgColor: status.bgColor, maxWidth: cell.frame.width)
                cell.badgeXIB.badgeView.addBorder(width: 1, color: status.textColor)
                
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
                
                let vc = siteCheckSB.instantiateViewController(withIdentifier: "WaterDomecsticRAResponseVC") as! WaterDomecsticRAResponseVC
                vc.addSiteCheckVC = self.addSiteCheckVC
                vc.siteCheckModel = self.siteCheckModel
                vc.waterDomecsticRAVC = self
                vc.question = que
                vc.response = ans
                vc.SITE_CHECK_DOMESTIC_RA_SCORES_ItemArray = self.SITE_CHECK_DOMESTIC_RA_SCORES_ItemArray
                vc.assetsItemArray = self.assetsItemArray
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
}
