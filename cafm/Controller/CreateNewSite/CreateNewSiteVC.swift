//
//  CreateNewSiteVC.swift
//  cafm
//
//  Created by Savan Lakhani on 24/08/24.
//

import UIKit

class CreateNewSiteVC: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var containerView: UIView!
    
    weak var vc1: SiteBasicDetailVC!
    weak var vc2: FloorLayoutPlanVC!
    weak var vc3: SiteInformationVC!
    
    var selectedTabIndex: Int = 0
    let itemArray = ["Basic Details", "Floor Layout & Plan", "Site Information"]
    
    var isForViewOnly: Bool = false
    
    var siteResponseDetail: CreateSiteRequestModel?
    var selectedSiteID: Int? {
        return self.siteResponseDetail?.siteId ?? vc1?.siteResponseModel?.siteId
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Create New Site"
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.collectionView.reloadData()
        self.collectionView(self.collectionView, didSelectItemAt: IndexPath(row: 0, section: 0))
    }
    
    func selectTabItem(index: Int) {
        switch index {
        case 0:
            self.selectedTabIndex = index
            if vc1 == nil {
                let vc = siteActionSB.instantiateViewController(withIdentifier: "SiteBasicDetailVC") as! SiteBasicDetailVC
                vc.homeVC = self
                addChild(vc)
                if self.siteResponseDetail != nil {
                    vc.isNeedToShowSiteDetails = true
                    vc.isForViewOnly = self.isForViewOnly
                }
                self.setSiteBasicDetailVC(vc: vc)
                vc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                vc.view.frame = self.containerView.bounds
                self.containerView.addSubview(vc.view)
                vc.didMove(toParent: self)
                vc.view.isHidden = true
                self.vc1 = vc
            }
            showViewController(self.vc1)
            break
        case 1:
            if let siteID = self.selectedSiteID {
                self.selectedTabIndex = index
                if vc2 == nil {
                    let vc = generalSB.instantiateViewController(withIdentifier: "FloorLayoutPlanVC") as! FloorLayoutPlanVC
                    vc.homeVC = self
                    vc.selectedSiteID = siteID
                    vc.isViewModeEdit = !self.isForViewOnly
                    add(childVC: vc, to: self.containerView)
                    vc.view.isHidden = true
                    self.vc2 = vc
                }
                showViewController(self.vc2)
            }
            break
        case 2:
            if let siteID = self.selectedSiteID {
                self.selectedTabIndex = index
                if vc3 == nil {
                    let vc = generalSB.instantiateViewController(withIdentifier: "SiteInformationVC") as! SiteInformationVC
                    vc.homeVC = self
                    vc.selectedSiteID = siteID
                    vc.isViewModeEdit = !self.isForViewOnly
                    add(childVC: vc, to: self.containerView)
                    vc.view.isHidden = true
                    self.vc3 = vc
                }
                showViewController(self.vc3)
            }
            break
        default:
            break
        }
    }
    
}

extension CreateNewSiteVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.itemArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LabelSelectionCell", for: indexPath) as! LabelSelectionCell
        
        if self.itemArray.count > indexPath.row {
            let item = self.itemArray[indexPath.row]
            cell.mainLbl.text = item
        }
        
        if self.selectedTabIndex == indexPath.row {
            cell.selectionView.isHidden = false
            cell.mainLbl.textColor = UIColor(appColor: .AppTint)
        }else if indexPath.row != 0 && self.selectedSiteID == nil {
            cell.selectionView.isHidden = true
            cell.mainLbl.textColor = UIColor(appColor: .GrayText).withAlphaComponent(0.5)
        }else {
            cell.selectionView.isHidden = true
            cell.mainLbl.textColor = UIColor(appColor: .GrayText)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row != 0 && self.selectedSiteID == nil {
            return
        }
        self.selectedTabIndex = indexPath.row
        self.collectionView.reloadData()
        self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        self.selectTabItem(index: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.itemArray.count > indexPath.row {
            let item = self.itemArray[indexPath.row]
            
            let refSize = CGSize(width: 12+50+12, height: 20+20+20)
            let widthAddition: CGFloat = 12+12
            let minWidth = refSize.width-widthAddition
            
            let width = getLabelSize(text: item, font: UIFont(name: .MontserratMedium, size: 17), minWidth: minWidth, widthAddition: widthAddition).width
            return CGSize(width: width, height: collectionView.frame.height)
        }
        return CGSize.zero
    }
    
}

extension CreateNewSiteVC {
    
    private func addChildViewController() {
        guard let vc = siteActionSB.instantiateViewController(withIdentifier: "SiteBasicDetailVC") as? SiteBasicDetailVC else { return }
        addChild(vc)
        if self.siteResponseDetail != nil {
            vc.isNeedToShowSiteDetails = true
        }
        vc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.setSiteBasicDetailVC(vc: vc)
        vc.view.frame = self.containerView.bounds
        self.containerView.addSubview(vc.view)
        vc.didMove(toParent: self)
    }
    
    func setSiteBasicDetailVC(vc: SiteBasicDetailVC) {
        vc.siteResponseModel = self.siteResponseDetail
    }
    
}
