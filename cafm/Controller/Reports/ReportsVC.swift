//
//  ReportsVC.swift
//  cafm
//
//  Created by NS on 26/10/24.
//
//

import UIKit

class ReportsVC: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var containerView: UIView!
    
    var itemArray = [Fields](Fields.allCases)
    var selectedTab: Fields = .portfolioReport
    
    weak var vc1: PortfolioReportVC!
    weak var vc2: AssetReportVC!
    weak var vc3: SiteChecksReportsVC!
    weak var vc4: EnergyReportVC!
    weak var vc5: ContractReportVC!
    weak var vc6: StatutoryRegisterReportVC!
    weak var vc7: ActionsReportVC!
    weak var vc8: BasicReportsVC!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureNavigationBackButton()
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.collectionView.reloadData()
        self.collectionView(self.collectionView, didSelectItemAt: IndexPath(row: 0, section: 0))
    }
    
    func selectTab(_ tab: Fields) {
        switch tab {
        case .portfolioReport:
            self.selectedTab = tab
            if vc1 == nil {
                let vc = reportsSB.instantiateViewController(withIdentifier: "PortfolioReportVC") as! PortfolioReportVC
                vc.homeVC = self
                vc.isViewModeEdit = true
                add(childVC: vc, to: self.containerView)
                vc.view.isHidden = true
                self.vc1 = vc
            }
            showViewController(self.vc1)
            break
        case .assetReport:
            self.selectedTab = tab
            if vc2 == nil {
                let vc = reportsSB.instantiateViewController(withIdentifier: "AssetReportVC") as! AssetReportVC
                vc.homeVC = self
                vc.isViewModeEdit = true
                add(childVC: vc, to: self.containerView)
                vc.view.isHidden = true
                self.vc2 = vc
            }
            showViewController(self.vc2)
            break
        case .contractReport:
            self.selectedTab = tab
            if vc5 == nil {
                let vc = reportsSB.instantiateViewController(withIdentifier: "ContractReportVC") as! ContractReportVC
                vc.homeVC = self
                vc.isViewModeEdit = true
                add(childVC: vc, to: self.containerView)
                vc.view.isHidden = true
                self.vc5 = vc
            }
            showViewController(self.vc5)
            break
        case .energyReport:
            self.selectedTab = tab
            if vc4 == nil {
                let vc = reportsSB.instantiateViewController(withIdentifier: "EnergyReportVC") as! EnergyReportVC
                vc.homeVC = self
                vc.isViewModeEdit = true
                add(childVC: vc, to: self.containerView)
                vc.view.isHidden = true
                self.vc4 = vc
            }
            showViewController(self.vc4)
            break
        case .statutoryRegister:
            self.selectedTab = tab
            if vc6 == nil {
                let vc = reportsSB.instantiateViewController(withIdentifier: "StatutoryRegisterReportVC") as! StatutoryRegisterReportVC
                vc.homeVC = self
                vc.isViewModeEdit = true
                add(childVC: vc, to: self.containerView)
                vc.view.isHidden = true
                self.vc6 = vc
            }
            showViewController(self.vc6)
            break
        case .actions:
            self.selectedTab = tab
            if vc7 == nil {
                let vc = reportsSB.instantiateViewController(withIdentifier: "ActionsReportVC") as! ActionsReportVC
                vc.homeVC = self
                vc.isViewModeEdit = true
                add(childVC: vc, to: self.containerView)
                vc.view.isHidden = true
                self.vc7 = vc
            }
            showViewController(self.vc7)
            break
        case .basicReports:
            self.selectedTab = tab
            if vc8 == nil {
                let vc = reportsSB.instantiateViewController(withIdentifier: "BasicReportsVC") as! BasicReportsVC
                vc.homeVC = self
                vc.isViewModeEdit = true
                add(childVC: vc, to: self.containerView)
                vc.view.isHidden = true
                self.vc8 = vc
            }
            showViewController(self.vc8)
            break
        }
    }
}

//MARK: - Fields enum
extension ReportsVC {
    enum Fields: String, CaseIterable {
        case portfolioReport = "Portfolio Report"
        case assetReport = "Asset Report"
        case contractReport = "Contract Report"
        //case projectReport = "Project Report"
        //case worksheet = "Worksheet"
        case energyReport = "Energy Report"
        //case siteChecks = "Site Checks"
        case statutoryRegister = "Statutory Register"
        case actions = "Actions"
        case basicReports = "Basic Reports"
    }
}

extension ReportsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.itemArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LabelSelectionCell", for: indexPath) as! LabelSelectionCell
        
        if self.itemArray.count > indexPath.row {
            let item = self.itemArray[indexPath.row]
            cell.mainLbl.text = item.rawValue
            
            if self.selectedTab == item {
                cell.selectionView.isHidden = false
                cell.mainLbl.textColor = UIColor(appColor: .AppTint)
            }else {
                cell.selectionView.isHidden = true
                cell.mainLbl.textColor = UIColor(appColor: .GrayText)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.itemArray.count > indexPath.row {
            let item = self.itemArray[indexPath.row]
            self.selectedTab = item
            self.collectionView.reloadData()
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            self.selectTab(item)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.itemArray.count > indexPath.row {
            let item = self.itemArray[indexPath.row]
            
            let refSize = CGSize(width: 12+50+12, height: 20+20+20)
            let widthAddition: CGFloat = 12+12
            let minWidth = refSize.width-widthAddition
            
            let width = getLabelSize(text: item.rawValue, font: UIFont(name: .MontserratMedium, size: 17), minWidth: minWidth, widthAddition: widthAddition).width
            return CGSize(width: width, height: collectionView.frame.height)
        }
        return CGSize.zero
    }
    
}
