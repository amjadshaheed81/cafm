//
//  MonthlyAuditQuestionsVC.swift
//  cafm
//
//  Created by NS on 12/11/24.
//
//

import UIKit
import SCLAlertView
import Alamofire
import ObjectMapper

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
    var monthlyV2: MonthlyAuditV2Client?
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
        self.updateMonthlyNavigationActions()
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
        guard questionCat == "monthly-inspection" else {
            // Annual Winter Audit intentionally retains its existing workflow.
            self.reloadViews()
            return
        }
        guard let monthlyV2 else {
            self.loadingStatus = .failed
            self.hideLoadingAndShowError(message: "The current Monthly Audit could not be loaded. Please reopen the Site Check.")
            return
        }
        self.loadingStatus = .loading
        monthlyV2.load { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let answers):
                self.responseItemArray = answers
                self.addSiteCheckVC?.monthlyAuditV2DidRefresh()
                self.loadingStatus = .default
                self.reloadViews()
                self.updateMonthlyNavigationActions()
            case .failure(let error):
                self.loadingStatus = .failed
                self.hideLoadingAndShowError(message: error.localizedDescription)
            }
        }
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
            let questions = self.questionItemArray.filter { question in
                guard !(question.question?.contains("DELETE") ?? false),
                      (question.order?.starts(with: (lov.lovDesc ?? "") + ".") ?? false) else { return false }
                guard questionCat == "monthly-inspection" else { return true }
                // The backend excludes questions with no applicable site assets.
                // Keep a stale saved question visible so the engineer can see it requires review.
                if responseItemArray.contains(where: { $0.qid == question.qid }) { return true }
                return assetsItemArray.contains { asset in
                    asset.assetId != nil && MonthlyAuditMobileCategoryMatcher.matches(
                        order: question.order, rule: question.assetCategory,
                        path: [asset.category, asset.subCategory, asset.subCategory2, asset.subCategory3])
                }
            }
            let itemArray = questions.compactMap { question in
                if let response = self.responseItemArray.first(where: { $0.qid == question.qid }) {
                    print("LogLog if", "question.qid:", question.qid ?? "NULL")
                    question.status = response.status?.rawValue ?? "Open"
                    question.completed = response.status == .closed
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

// MARK: - Monthly Audit V2 lifecycle actions
extension MonthlyAuditQuestionsVC {
    private func updateMonthlyNavigationActions() {
        guard questionCat == "monthly-inspection", let context = monthlyV2?.context else { return }
        var items: [UIBarButtonItem] = [UIBarButtonItem(title: "Options", style: .plain,
                                                        target: self, action: #selector(showMonthlyOptions))]
        if context.canSubmit && context.canEdit {
            items.insert(UIBarButtonItem(title: "Submit", style: .plain,
                                          target: self, action: #selector(submitMonthlyAudit)), at: 0)
        }
        navigationItem.rightBarButtonItems = items
    }

    @objc private func showMonthlyOptions() {
        guard let context = monthlyV2?.context else { return }
        let sheet = UIAlertController(title: "Monthly Audit", message: "Inspection Date: \(monthlyV2?.inspectionDate ?? "Not selected")",
                                      preferredStyle: .actionSheet)
        if context.canEdit {
            sheet.addAction(UIAlertAction(title: "Change Inspection Date", style: .default) { [weak self] _ in
                self?.editMonthlyInspectionDate()
            })
        }
        sheet.addAction(UIAlertAction(title: "View Previous Audit History", style: .default) { [weak self] _ in
            self?.showMonthlyHistory()
        })
        if context.canOpenEarly || context.canRenewOverdue {
            sheet.addAction(UIAlertAction(title: context.canRenewOverdue ? "Renew Overdue Audit" : "Open Next Audit Early",
                                          style: .default) { [weak self] _ in self?.openMonthlyPeriod() })
        }
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        if let popover = sheet.popoverPresentationController {
            popover.sourceView = tableView
            popover.sourceRect = CGRect(x: tableView.bounds.midX, y: 0, width: 1, height: 1)
        }
        present(sheet, animated: true)
    }

    @objc private func editMonthlyInspectionDate() {
        guard let client = monthlyV2, client.context?.canEdit == true else { return }
        let alert = UIAlertController(title: "Inspection Date", message: "Use YYYY-MM-DD. This is the date saved with this audit.",
                                      preferredStyle: .alert)
        alert.addTextField { field in
            field.text = client.inspectionDate
            field.placeholder = "YYYY-MM-DD"
            field.keyboardType = .numbersAndPunctuation
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Use Date", style: .default) { [weak self] _ in
            guard let self else { return }
            if client.setInspectionDate(alert.textFields?.first?.text ?? "") {
                self.title = "Questions · " + (client.inspectionDate ?? "")
            } else {
                self.hideLoadingAndShowError(message: "Enter a real date in YYYY-MM-DD format.")
            }
        })
        present(alert, animated: true)
    }

    @objc private func submitMonthlyAudit() {
        guard let client = monthlyV2, client.context?.canSubmit == true,
              client.context?.canEdit == true else { return }
        let alert = UIAlertController(title: "Submit Monthly Audit?",
                                      message: "The server will validate all questions, generate the PDF, store History and disable editing for this period. Inspection Date: \(client.inspectionDate ?? "Not selected")",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Submit Audit", style: .default) { [weak self] _ in
            self?.runMonthlyTransition("/submission/complete")
        })
        present(alert, animated: true)
    }

    @objc private func openMonthlyPeriod() {
        guard let context = monthlyV2?.context else { return }
        let renewing = context.canRenewOverdue
        let endpoint = renewing ? "/renew-overdue" : "/open-early"
        guard renewing || context.canOpenEarly else { return }
        let alert = UIAlertController(title: renewing ? "Renew Overdue Audit?" : "Open Next Monthly Audit?",
                                      message: "The server will preserve the previous period and its PDF/History. A new period will begin with blank answers.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Continue", style: .default) { [weak self] _ in
            self?.runMonthlyTransition(endpoint)
        })
        present(alert, animated: true)
    }

    // Verified immutable/legacy history endpoint in SiteCheckController.
    private func showMonthlyHistory() {
        guard let client = monthlyV2,
              let url = URL(string: ApiService.baseApi + "/api/site-check/\(client.checkId)/history"),
              ServerConfiguration.shared.canSendSessionCookie(to: url) else { return }
        var headers: HTTPHeaders = ["Accept": "application/json"]
        if let token = jwtToken, !token.isEmpty { headers.add(name: "Cookie", value: token) }
        let redirector = Redirector(behavior: .modify { task, newRequest, _ in
            guard let original = task.originalRequest?.url, let next = newRequest.url,
                  next.scheme?.lowercased() == "https",
                  next.host?.lowercased() == original.host?.lowercased(),
                  next.port == original.port else { return nil }
            return newRequest
        })
        loadingSCLAlertView.showLoading()
        AF.request(url, headers: headers).redirect(using: redirector)
            .validate(statusCode: 200..<300).responseData { [weak self] response in
                guard let self else { return }
                self.loadingSCLAlertView.hideView()
                APIClient.noteUnauthorized(response.response?.statusCode, request: response.request)
                guard case .success(let bytes) = response.result,
                      let items = try? JSONSerialization.jsonObject(with: bytes) as? [[String: Any]] else {
                    self.hideLoadingAndShowError(message: "Unable to load Monthly Audit History.")
                    return
                }
                let sorted = items.sorted { ($0["historyId"] as? Int ?? 0) > ($1["historyId"] as? Int ?? 0) }
                let sheet = UIAlertController(title: "Monthly Audit History",
                                              message: sorted.isEmpty ? "No saved audit history is available." : "Select a saved report to open its PDF.",
                                              preferredStyle: .actionSheet)
                for item in sorted.prefix(25) {
                    let stamp = String((item["inspectionDate"] as? String ?? item["submittedAt"] as? String ?? "Unknown date").prefix(10))
                    let label = "\(stamp) · \(item["completionStatus"] as? String ?? "Audit")"
                    sheet.addAction(UIAlertAction(title: label, style: .default) { [weak self] _ in
                        guard let self else { return }
                        guard var file = item["pdfUrl"] as? String, !file.isEmpty else {
                            self.hideLoadingAndShowError(message: "This record has no downloadable PDF URL. Please use Site Documents.")
                            return
                        }
                        if !file.contains("?"), let sas = UserConstants.shared.sasToken, !sas.isEmpty {
                            file += "?" + sas.trimmingCharacters(in: CharacterSet(charactersIn: "?"))
                        }
                        CAFMFileUtils.shared.downloadAndShareFile(file, from: self, sender: self.view,
                                                                 shouldDeleteAfterSharing: true)
                    })
                }
                if sorted.count > 25 {
                    sheet.message = "Showing the newest 25 records. Older reports remain in Site Documents/History."
                }
                sheet.addAction(UIAlertAction(title: "Close", style: .cancel))
                if let popover = sheet.popoverPresentationController {
                    popover.sourceView = self.tableView
                    popover.sourceRect = CGRect(x: self.tableView.bounds.midX, y: 0, width: 1, height: 1)
                }
                self.present(sheet, animated: true)
            }
    }

    private func runMonthlyTransition(_ endpoint: String) {
        guard let client = monthlyV2 else { return }
        loadingSCLAlertView.showLoading()
        client.performTransition(endpoint) { [weak self] result in
            guard let self else { return }
            self.loadingSCLAlertView.hideView()
            switch result {
            case .failure(let error): self.hideLoadingAndShowError(message: error.localizedDescription)
            case .success(let context):
                let message = context.message ?? (endpoint == "/submission/complete"
                    ? "Monthly Audit completed. Its PDF and History were saved on the server."
                    : "The new Monthly Audit period has opened.")
                let alert = UIAlertController(title: "Monthly Audit", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                    self?.loadData()
                })
                self.present(alert, animated: true)
            }
        }
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


// MARK: - Monthly Audit V2 contract (Site Service 2026-10-21)
// Deliberately scoped to Monthly Audit only. Other inspections use their legacy API.
// The current period token, answer revision and Action choice are always server-owned.
private struct MonthlyAuditV2Error: LocalizedError {
    let message: String
    var errorDescription: String? { message }
}

struct MonthlyAuditV2ActionChoice {
    let assetId: Int
    let mode: String
    let actionId: Int?

    var payload: [String: Any] {
        var data: [String: Any] = ["assetId": assetId, "mode": mode]
        if let actionId { data["actionId"] = actionId }
        return data
    }
}

struct MonthlyAuditV2ActionCandidate {
    let actionId: Int
    let assetIds: [Int]
    let observation: String?
    let requiredAction: String?
    let status: String?
}

struct MonthlyAuditV2Image {
    let imageId: Int
    let imageUrl: String
}

struct MonthlyAuditV2AnswerState {
    let response: SiteCheckAssessmentResponse
    let revision: Int
    let actionChoices: [MonthlyAuditV2ActionChoice]
    let images: [MonthlyAuditV2Image]
}

struct MonthlyAuditV2Context {
    let periodToken: String
    let status: String
    let inspectionDate: String?
    let nextDueDate: String?
    let canEdit: Bool
    let canSubmit: Bool
    let canOpenEarly: Bool
    let canRenewOverdue: Bool
    let message: String?

    init?(_ json: [String: Any]) {
        guard let token = json["periodToken"] as? String, !token.isEmpty,
              let status = json["status"] as? String,
              let canEdit = json["canEdit"] as? Bool,
              let canSubmit = json["canSubmit"] as? Bool,
              let canOpenEarly = json["canOpenEarly"] as? Bool,
              let canRenewOverdue = json["canRenewOverdue"] as? Bool else { return nil }
        periodToken = token
        self.status = status
        inspectionDate = json["inspectionDate"] as? String
        nextDueDate = json["nextDueDate"] as? String
        self.canEdit = canEdit
        self.canSubmit = canSubmit
        self.canOpenEarly = canOpenEarly
        self.canRenewOverdue = canRenewOverdue
        message = json["message"] as? String
    }
}

final class MonthlyAuditV2Client {
    let checkId: Int
    private(set) var context: MonthlyAuditV2Context?
    private(set) var states: [Int: MonthlyAuditV2AnswerState] = [:]
    private(set) var actionCandidates: [MonthlyAuditV2ActionCandidate] = []
    private(set) var inspectionDate: String?
    private var dateEditedByUser = false
    private var pendingRequests: [Int: (payload: Data, requestId: String)] = [:]

    init(checkId: Int) { self.checkId = checkId }

    var answers: [SiteCheckAssessmentResponse] {
        states.values.map(\.response).sorted { ($0.qid ?? 0) < ($1.qid ?? 0) }
    }

    func state(for qid: Int) -> MonthlyAuditV2AnswerState? { states[qid] }

    func setInspectionDate(_ text: String) -> Bool {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.isLenient = false
        guard let parsed = formatter.date(from: text), formatter.string(from: parsed) == text else { return false }
        inspectionDate = text
        dateEditedByUser = true
        return true
    }

    func load(_ completion: @escaping (Result<[SiteCheckAssessmentResponse], Error>) -> Void) {
        Self.request(checkId: checkId, path: "/context") { [weak self] contextResult in
            guard let self else { return }
            switch contextResult {
            case .failure(let error): completion(.failure(error))
            case .success(let data):
                guard let freshContext = MonthlyAuditV2Context(data) else {
                    completion(.failure(MonthlyAuditV2Error(message: "The server returned an invalid Monthly Audit context.")))
                    return
                }
                Self.request(checkId: self.checkId, path: "/responses") { [weak self] answerResult in
                    guard let self else { return }
                    switch answerResult {
                    case .failure(let error): completion(.failure(error))
                    case .success(let answersJSON):
                        guard let token = answersJSON["periodToken"] as? String,
                              token == freshContext.periodToken,
                              let rows = answersJSON["responses"] as? [[String: Any]] else {
                            completion(.failure(MonthlyAuditV2Error(message: "The audit period changed while loading. Please reopen the audit.")))
                            return
                        }
                        var loaded: [Int: MonthlyAuditV2AnswerState] = [:]
                        for row in rows {
                            guard let json = row["response"] as? [String: Any],
                                  let mapped = SiteCheckAssessmentResponse(JSON: json),
                                  let qid = mapped.qid,
                                  let revision = row["revision"] as? Int, revision >= 0,
                                  let rowToken = row["periodToken"] as? String,
                                  rowToken == token, loaded[qid] == nil else {
                                completion(.failure(MonthlyAuditV2Error(message: "An audit answer could not be read safely. No changes were made.")))
                                return
                            }
                            // The backend stores the observation as 'position'.
                            mapped.observation = mapped.position
                            // V2 image URLs live on response.images (not the legacy 'file' field).
                            let images = (json["images"] as? [[String: Any]] ?? []).compactMap { value -> MonthlyAuditV2Image? in
                                guard let imageId = value["imageId"] as? Int,
                                      let url = value["imageUrl"] as? String else { return nil }
                                return MonthlyAuditV2Image(imageId: imageId, imageUrl: url)
                            }
                            if (mapped.file == nil || mapped.file?.isEmpty == true) {
                                mapped.file = images.first?.imageUrl
                            }
                            let choices = (row["actionChoices"] as? [[String: Any]] ?? []).compactMap { value -> MonthlyAuditV2ActionChoice? in
                                guard let asset = value["assetId"] as? Int,
                                      let mode = value["mode"] as? String else { return nil }
                                return MonthlyAuditV2ActionChoice(assetId: asset, mode: mode, actionId: value["actionId"] as? Int)
                            }
                            loaded[qid] = MonthlyAuditV2AnswerState(response: mapped, revision: revision,
                                                                      actionChoices: choices, images: images)
                        }
                        // Action candidates are fetched from the authenticated server, never guessed.
                        Self.request(checkId: self.checkId, path: "/actions") { [weak self] actionsResult in
                            guard let self else { return }
                            switch actionsResult {
                            case .failure(let error): completion(.failure(error))
                            case .success(let actionJSON):
                                guard let list = actionJSON["actions"] as? [[String: Any]] else {
                                    completion(.failure(MonthlyAuditV2Error(message: "Unable to load the outstanding fault Actions.")))
                                    return
                                }
                                let candidates = list.compactMap { item -> MonthlyAuditV2ActionCandidate? in
                                    guard let id = item["actionId"] as? Int,
                                          let assetIds = item["assetIds"] as? [Int] else { return nil }
                                    return MonthlyAuditV2ActionCandidate(actionId: id, assetIds: assetIds,
                                        observation: item["observation"] as? String,
                                        requiredAction: item["requiredAction"] as? String,
                                        status: item["status"] as? String)
                                }
                                guard candidates.count == list.count else {
                                    completion(.failure(MonthlyAuditV2Error(message: "The outstanding fault Action list is invalid.")))
                                    return
                                }
                                if self.context?.periodToken != freshContext.periodToken {
                                    self.dateEditedByUser = false
                                    self.pendingRequests.removeAll()
                                }
                                self.context = freshContext
                                self.states = loaded
                                self.actionCandidates = candidates
                                if !self.dateEditedByUser {
                                    self.inspectionDate = freshContext.inspectionDate.map { String($0.prefix(10)) }
                                }
                                completion(.success(self.answers))
                            }
                        }
                    }
                }
            }
        }
    }

    func save(response: SiteCheckAssessmentResponse,
              uploadedFiles: [String], actionChoices: [MonthlyAuditV2ActionChoice],
              completion: @escaping (Result<SiteCheckAssessmentResponse, Error>) -> Void) {
        guard let context, context.canEdit, let qid = response.qid,
              let inspectionDate, !inspectionDate.isEmpty else {
            completion(.failure(MonthlyAuditV2Error(message: "The current audit period and Inspection Date are required. Reload the audit.")))
            return
        }
        // Only fields supported by SiteCheckAssessmentResponse are sent.
        var answer: [String: Any] = ["checkId": checkId, "qid": qid,
                                     "assets": response.assets ?? "", "faultassets": response.faultassets ?? "",
                                     "position": response.position ?? "", "action": response.action ?? ""]
        if let responseId = response.responseId { answer["responseId"] = responseId }
        if let value = response.consequence { answer["consequence"] = value }
        if let value = response.likelihood { answer["likelihood"] = value }
        if let value = response.file, !value.isEmpty { answer["file"] = value }
        if !uploadedFiles.isEmpty { answer["files"] = uploadedFiles }
        let revision = states[qid]?.revision ?? 0
        let choices = actionChoices.map(\.payload)
        let identity: [String: Any] = ["periodToken": context.periodToken,
                                      "responseRevision": revision, "inspectionDate": inspectionDate,
                                      "response": answer, "actionChoices": choices]
        guard let bytes = try? JSONSerialization.data(withJSONObject: identity, options: [.sortedKeys]) else {
            completion(.failure(MonthlyAuditV2Error(message: "The audit answer could not be prepared for saving.")))
            return
        }
        // Reuse the same UUID for a retry of the same payload. Do not accidentally create duplicate Actions.
        let requestId: String
        if let pending = pendingRequests[qid], pending.payload == bytes {
            requestId = pending.requestId
        } else {
            requestId = UUID().uuidString
            pendingRequests[qid] = (bytes, requestId)
        }
        var body = identity
        body["requestId"] = requestId
        Self.request(checkId: checkId, path: "/responses", method: .post, payload: body) { [weak self] result in
            guard let self else { return }
            switch result {
            case .failure(let error): completion(.failure(error))
            case .success(let saved):
                guard let rowToken = saved["periodToken"] as? String, rowToken == context.periodToken,
                      let resultJSON = saved["response"] as? [String: Any],
                      let mapped = SiteCheckAssessmentResponse(JSON: resultJSON),
                      let returnedRevision = saved["revision"] as? Int, returnedRevision > revision else {
                    completion(.failure(MonthlyAuditV2Error(message: "The server did not confirm the saved answer revision. Reload before saving again.")))
                    return
                }
                mapped.observation = mapped.position
                let choices = (saved["actionChoices"] as? [[String: Any]] ?? []).compactMap { choice -> MonthlyAuditV2ActionChoice? in
                    guard let id = choice["assetId"] as? Int, let mode = choice["mode"] as? String else { return nil }
                    return MonthlyAuditV2ActionChoice(assetId: id, mode: mode, actionId: choice["actionId"] as? Int)
                }
                let images = (resultJSON["images"] as? [[String: Any]] ?? []).compactMap { value -> MonthlyAuditV2Image? in
                    guard let id = value["imageId"] as? Int,
                          let url = value["imageUrl"] as? String else { return nil }
                    return MonthlyAuditV2Image(imageId: id, imageUrl: url)
                }
                if mapped.file == nil { mapped.file = images.first?.imageUrl }
                self.states[qid] = MonthlyAuditV2AnswerState(response: mapped,
                                                            revision: returnedRevision, actionChoices: choices, images: images)
                self.pendingRequests.removeValue(forKey: qid)
                completion(.success(mapped))
            }
        }
    }

    func performTransition(_ endpoint: String, completion: @escaping (Result<MonthlyAuditV2Context, Error>) -> Void) {
        guard let context, let inspectionDate else {
            completion(.failure(MonthlyAuditV2Error(message: "Reload the current period before changing the audit.")))
            return
        }
        let payload: [String: Any] = ["periodToken": context.periodToken, "inspectionDate": inspectionDate]
        Self.request(checkId: checkId, path: endpoint, method: .post, payload: payload) { [weak self] result in
            guard let self else { return }
            switch result {
            case .failure(let error): completion(.failure(error))
            case .success(let json):
                guard let next = MonthlyAuditV2Context(json) else {
                    completion(.failure(MonthlyAuditV2Error(message: "The server did not return an audit confirmation.")))
                    return
                }
                self.context = next
                self.pendingRequests.removeAll()
                self.dateEditedByUser = false
                self.inspectionDate = next.inspectionDate.map { String($0.prefix(10)) }
                completion(.success(next))
            }
        }
    }

    // This is the actual Java controller contract. /submission/prepare and /pdf
    // deliberately reject calls; the backend generates the PDF during /submission/complete.
    private static func request(checkId: Int, path: String, method: HTTPMethod = .get,
                                payload: [String: Any]? = nil,
                                completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard let url = URL(string: ApiService.baseApi + "/api/site-check/\(checkId)/monthly-audit-v2" + path),
              url.scheme?.lowercased() == "https",
              ServerConfiguration.shared.canSendSessionCookie(to: url) else {
            completion(.failure(MonthlyAuditV2Error(message: "The selected CAFM API server address is invalid.")))
            return
        }
        var headers: HTTPHeaders = ["Accept": "application/json"]
        if let token = jwtToken, !token.isEmpty { headers.add(name: "Cookie", value: token) }
        let redirector = Redirector(behavior: .modify { task, request, _ in
            guard let original = task.originalRequest?.url, let next = request.url,
                  next.scheme?.lowercased() == "https",
                  next.host?.lowercased() == original.host?.lowercased(),
                  next.port == original.port else { return nil }
            return request
        })
        AF.request(url, method: method, parameters: payload, encoding: JSONEncoding.default, headers: headers)
            .redirect(using: redirector).validate(statusCode: 200..<300).responseData { response in
                APIClient.noteUnauthorized(response.response?.statusCode, request: response.request)
                switch response.result {
                case .success(let data):
                    guard let value = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                        completion(.failure(MonthlyAuditV2Error(message: "The server returned an unreadable Monthly Audit response.")))
                        return
                    }
                    completion(.success(value))
                case .failure(let error):
                    let message: String
                    if let data = response.data,
                       let body = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let detail = body["message"] as? String, !detail.isEmpty {
                        message = detail
                    } else if response.response?.statusCode == 401 {
                        message = "Your session has expired. Please sign in again."
                    } else if response.response?.statusCode == 409 {
                        message = "The Monthly Audit changed on the server. Reload before saving."
                    } else {
                        message = error.localizedDescription
                    }
                    completion(.failure(MonthlyAuditV2Error(message: message)))
                }
            }
    }
}
