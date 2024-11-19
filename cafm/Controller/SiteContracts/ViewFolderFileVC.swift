//
//  ViewFolderFileVC.swift
//  cafm
//
//  Created by Savan Lakhani on 28/09/24.
//

import UIKit

class ViewFolderFileVC: UIViewController {

    @IBOutlet weak var noDataAvailableLbl: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var projectContractFolderItemArray: [ProjectContractFolderModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "File Version Uploaded"
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.noDataAvailableLbl.font = UIFont(name: .MontserratMedium, size: 16)
        if self.projectContractFolderItemArray.first?.files == nil {
            self.collectionView.isHidden = true
        }
    }
    
}

//MARK:- CollectionView Delegate
extension ViewFolderFileVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let files = self.projectContractFolderItemArray.first?.files, !files.isEmpty {
            return files.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SiteTagCell", for: indexPath) as! SiteTagCell
        cell.lblSiteName.text = self.projectContractFolderItemArray.first?.files?[indexPath.row].name
        let width = CGFloat.zero
        cell.closeImageViewWidth.constant = width
        cell.closeImageView.frame.size.width = width
        cell.addCorner(value: 20)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = generalSB.instantiateViewController(withIdentifier: "FileViewVC") as! FileViewVC
        if let urlString = self.projectContractFolderItemArray.first?.files?[indexPath.row].url {
            vc.fileURL = URL(string: urlString)
        }
        let nav = UINavigationController(rootViewController: vc)
        self.present(nav, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let text = self.projectContractFolderItemArray.first?.files?[indexPath.row].name {
            let width = getLabelSize(text: text, font: UIFont.systemFont(ofSize: 16, weight: .medium), widthAddition: 10+5+5, maxWidth: collectionView.frame.width - 10).width
            return CGSize(width: width, height: 40)
        }else {
            return .zero
        }
    }
    
}
