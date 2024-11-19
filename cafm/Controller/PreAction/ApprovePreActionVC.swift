//
//  ApprovePreActionVC.swift
//  cafm
//
//  Created by Savan Lakhani on 19/10/24.
//

import UIKit
import SCLAlertView
import ImageScrollView

enum Consequence: String {
    case select = "Select"
    case one = "1"
    case two = "2"
    case three = "3"
    case four = "4"
    case five = "5"
}

enum Likelihood: String {
    case select = "Select"
    case one = "1"
    case two = "2"
    case three = "3"
    case four = "4"
    case five = "5"
}

class ApprovePreActionVC: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var likelihoodXIB: OptionBtnWithTitleXIB!
    @IBOutlet weak var consequenceXIB: OptionBtnWithTitleXIB!
    
    @IBOutlet weak var tv1: UITextView!
    @IBOutlet weak var tv2: UITextView!
    
    @IBOutlet weak var guideImageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var guideView: UIView!
    @IBOutlet weak var riskScoreImageSV: ImageScrollView!
    
    @IBOutlet weak var actionBtnViewXIB: ActionBtnViewXIB!
    
    @IBOutlet weak var requiredActionLbl: DefaultFontLabel!
    @IBOutlet weak var observationLbl: DefaultFontLabel!
        
    var consequence: Consequence = .select
    var likelihood: Likelihood = .select
    
    var preActionResponse: PreAction?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Actions"
        self.initailizeUI()
    }
    
    func initailizeUI() {
        self.consequenceXIB.title = "Consequence"
        self.likelihoodXIB.title = "Likelihood"
        
        self.consequenceXIB.optionXIB.lblText.text = ""
        self.likelihoodXIB.optionXIB.lblText.text = ""

        self.consequenceXIB.optionXIB.dummyTF.text = Consequence.select.rawValue
        self.likelihoodXIB.optionXIB.dummyTF.text = Likelihood.select.rawValue

        self.observationLbl.font = self.consequenceXIB.titleLbl.font
        self.requiredActionLbl.font = self.consequenceXIB.titleLbl.font
        
        self.tv1.addBorder(color: .gray.withAlphaComponent(0.6))
        self.tv1.addCorner()
        
        self.tv2.addBorder(color: .gray.withAlphaComponent(0.6))
        self.tv2.addCorner()
                
        self.actionBtnViewXIB.saveBtn.addTarget(self, action: #selector(saveBtnTapped), for: .touchUpInside)
        self.actionBtnViewXIB.cancelBtn.addTarget(self, action: #selector(cancelBtnTapped), for: .touchUpInside)
        
        self.riskScoreImageSV.setup()
        if let image = UIImage(named: "img_risk_scorecard_assessment") {
            self.riskScoreImageSV.imageContentMode = .heightFill
            self.riskScoreImageSV.display(image: image)
        }
        
        self.setConsequenceXIB()
        self.setLikelihoodXIB()
    }
    
    func setConsequenceXIB() {
        var actions = [UIAction]()
        actions.append(UIAction(title: Consequence.select.rawValue, state: consequence == .select ? .on : .off, handler: { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.consequence = .select
                self.consequenceXIB.optionXIB.dummyTF.text = Consequence.select.rawValue
                self.setConsequenceXIB()
            }
        }))
        
        actions.append(UIAction(title: Consequence.one.rawValue, state: consequence == .one ? .on : .off, handler: { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.consequence = .select
                self.consequenceXIB.optionXIB.dummyTF.text = Consequence.one.rawValue
                self.setConsequenceXIB()
            }
        }))
        
        actions.append(UIAction(title: Consequence.two.rawValue, state: consequence == .two ? .on : .off, handler: { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.consequence = .select
                self.consequenceXIB.optionXIB.dummyTF.text = Consequence.two.rawValue
                self.setConsequenceXIB()
            }
        }))
        
        actions.append(UIAction(title: Consequence.three.rawValue, state: consequence == .three ? .on : .off, handler: { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.consequence = .three
                self.consequenceXIB.optionXIB.dummyTF.text = Consequence.three.rawValue
                self.setConsequenceXIB()
            }
        }))
        
        actions.append(UIAction(title: Consequence.four.rawValue, state: consequence == .four ? .on : .off, handler: { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.consequence = .select
                self.consequenceXIB.optionXIB.dummyTF.text = Consequence.four.rawValue
                self.setConsequenceXIB()
            }
        }))
        
        actions.append(UIAction(title: Consequence.five.rawValue, state: consequence == .five ? .on : .off, handler: { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.consequence = .select
                self.consequenceXIB.optionXIB.dummyTF.text = Consequence.five.rawValue
                self.setConsequenceXIB()
            }
        }))
        
        self.consequenceXIB.optionXIB.btnDownClick.menu = UIMenu(title: "", children: actions)
        self.consequenceXIB.optionXIB.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    func setLikelihoodXIB() {
        var actions = [UIAction]()
        actions.append(UIAction(title: Likelihood.select.rawValue, state: likelihood == .select ? .on : .off, handler: { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.likelihood = .select
                self.likelihoodXIB.optionXIB.dummyTF.text = Likelihood.select.rawValue
                self.setLikelihoodXIB()
            }
        }))
        
        actions.append(UIAction(title: Likelihood.one.rawValue, state: likelihood == .one ? .on : .off, handler: { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.likelihood = .select
                self.likelihoodXIB.optionXIB.dummyTF.text = Likelihood.one.rawValue
                self.setLikelihoodXIB()
            }
        }))
        
        actions.append(UIAction(title: Likelihood.two.rawValue, state: likelihood == .two ? .on : .off, handler: { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.likelihood = .select
                self.likelihoodXIB.optionXIB.dummyTF.text = Likelihood.two.rawValue
                self.setLikelihoodXIB()
            }
        }))
        
        actions.append(UIAction(title: Likelihood.three.rawValue, state: likelihood == .three ? .on : .off, handler: { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.likelihood = .select
                self.likelihoodXIB.optionXIB.dummyTF.text = Likelihood.three.rawValue
                self.setLikelihoodXIB()
            }
        }))
        
        actions.append(UIAction(title: Likelihood.four.rawValue, state: likelihood == .four ? .on : .off, handler: { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.likelihood = .select
                self.likelihoodXIB.optionXIB.dummyTF.text = Likelihood.four.rawValue
                self.setLikelihoodXIB()
            }
        }))
        
        actions.append(UIAction(title: Likelihood.five.rawValue, state: likelihood == .five ? .on : .off, handler: { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                self.likelihood = .select
                self.likelihoodXIB.optionXIB.dummyTF.text = Likelihood.five.rawValue
                self.setLikelihoodXIB()
            }
        }))
        
        self.likelihoodXIB.optionXIB.btnDownClick.menu = UIMenu(title: "", children: actions)
        self.likelihoodXIB.optionXIB.btnDownClick.showsMenuAsPrimaryAction = true
    }
    
    @objc func saveBtnTapped() {
        guard self.consequenceXIB.optionXIB.dummyTF.text != Consequence.select.rawValue else {
            SCLAlertView().showError("Error", subTitle: "Please select an Item in the list.")
            return
        }
        
        guard self.likelihoodXIB.optionXIB.dummyTF.text != Likelihood.select.rawValue else {
            SCLAlertView().showError("Error", subTitle: "Please select an Item in the list.")
            return
        }
        
        guard self.tv1.text != "" else {
            SCLAlertView().showError("Error", subTitle: "Please fill in Observation field.")
            return
        }
        
        guard self.tv2.text != "" else {
            SCLAlertView().showError("Error", subTitle: "Please fill in Aequired Action field.")
            return
        }
        
        guard let selectedSiteID = UserConstants.shared.selectedSiteID else { return }
        guard let currentUserID = UserConstants.shared.currentUserID else { return }
        
        
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        
        let sclAlert = SCLAlertView(appearance: appearance)
        sclAlert.showWait("", subTitle: "please wait...", closeButtonTitle: "")
        
        let clientAction = ClientAction()
        clientAction.type = "ClientAction"
        clientAction.status = "Reported"
        clientAction.observation = self.tv1.text
        clientAction.requiredAction = self.tv2.text
        clientAction.dueDate = getCurrentTimeInISO8601Format()
        clientAction.siteId = selectedSiteID
        clientAction.userId = currentUserID
        if let consequence = Int(self.consequenceXIB.optionXIB.dummyTF.text ?? "0") , let likelihoodXIB =  Int(self.likelihoodXIB.optionXIB.dummyTF.text ?? "0") {
            clientAction.riskScore = consequence * likelihoodXIB
        }
        clientAction.desc = "Client Action - \(Date().transformToString(dateFormat: "dd/MM/yyyy"))"
        
        let apiRequest = ApiService.approvePreAction(model: clientAction)
        APIClient.request(apiRequest) { [weak self] (result: Result<APIClient.MappableResult<ClientActionResponse>, Error>) in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .array:
                    sclAlert.hideView()
                    break
                case .single(let single):
                    print(single)
                    self?.actionApprovedAPICalling(scl: sclAlert)
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }

    }
    
    func actionApprovedAPICalling(scl: SCLAlertView) {
        let req = StatusModel()
        req.status = "Pending Action"
        req.approverNotes = ""
        
        guard let actionId = self.preActionResponse?.actionId else { return }
        
        let apiService = ApiService.pendingPreAction(actionId: actionId, model: req)
        
        APIClient.requestWithCode(apiService) { [weak self] isSuccess, code in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                scl.hideView()
                if code == 200 {
                    SCLAlertView.showSuccessAlert(title: "", message: "Successfully approved the pre action.", doneButtonTitle: "Done") { [weak self] in
                        guard let self else { return }
                        if let navigationController = self.navigationController {
                            for viewController in navigationController.viewControllers {
                                if let preActionVC = viewController as? PreActionVC {
                                    self.navigationController?.popToViewController(preActionVC, animated: true)
                                      break
                                }else {
                                    self.navigationController?.popViewController(animated: true)
                                }
                            }
                        } else {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }else {
                    SCLAlertView().showError("Error", subTitle: "Oops! please try again")
                }
            }
        }
    }
    
    @objc func cancelBtnTapped() {
        
    }

}
