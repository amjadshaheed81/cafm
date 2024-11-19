//
//  CustomTableView.swift
//  cafm
//
//  Created by Savan Lakhani on 25/08/24.
//

import UIKit

enum CustomTableType {
    case sitePinCode
    case documnetGuide
    case tagAsset
    case createContracts
    case leadUser
    case assistantUser
    case faultsIdentifiedTag
    case certificateReview
    case searchAsset
}

class CustomTableView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    var type: CustomTableType = .sitePinCode
    
    private var tableView: UITableView!
    var filteredArray: [String] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var documentFilter: [File] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var tagAssetItemArray: [AssetDetailsResponse] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var leadUserItemArray: [User] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var assistantUserItemArray: [User] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var itemArray: [Any] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var didSelectItem: ((Any) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTableView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTableView()
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: self.bounds)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.borderColor = UIColor.lightGray.cgColor
        tableView.layer.borderWidth = 1.0
        tableView.layer.cornerRadius = 5.0
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.showsVerticalScrollIndicator = true
        tableView?.layer.borderColor = UIColor.lightGray.cgColor
        tableView?.layer.borderWidth = 1.0
        tableView?.layer.cornerRadius = 5.0
        self.addSubview(tableView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tableView.frame = self.bounds
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch type {
        case .sitePinCode:
            filteredArray.count
        case .documnetGuide:
            documentFilter.count
        case .tagAsset:
            tagAssetItemArray.count
        case .createContracts:
            filteredArray.count
        case .leadUser:
            leadUserItemArray.count
        case .assistantUser:
            assistantUserItemArray.count
        case .faultsIdentifiedTag:
            tagAssetItemArray.count
        case .certificateReview:
            itemArray.count
        case .searchAsset:
            itemArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        switch type {
        case .sitePinCode:
            cell.textLabel?.text = filteredArray[indexPath.row]
        case .documnetGuide:
            cell.textLabel?.text = (documentFilter[indexPath.row].name ?? "")
            cell.textLabel?.textColor = UIColor(appColor: .AppTint)
            cell.textLabel?.font = UIFont(name: .MontserratSemiBold, size: 16)
            cell.textLabel?.lineBreakMode = .byTruncatingMiddle
        case .tagAsset:
            if tagAssetItemArray.count > indexPath.row {
                let item = tagAssetItemArray[indexPath.row]
                cell.textLabel?.text = item.assetName
            }
        case .createContracts:
            cell.textLabel?.text = filteredArray[indexPath.row]
        case .leadUser:
            if leadUserItemArray.count > indexPath.row {
                let item = leadUserItemArray[indexPath.row]
                cell.textLabel?.text = getUserDisplayStr(item)
                cell.textLabel?.numberOfLines = 0
            }
        case .assistantUser:
            if assistantUserItemArray.count > indexPath.row {
                let item = assistantUserItemArray[indexPath.row]
                cell.textLabel?.text = getUserDisplayStr(item)
                cell.textLabel?.numberOfLines = 0
            }
        case .faultsIdentifiedTag:
            if tagAssetItemArray.count > indexPath.row {
                let item = tagAssetItemArray[indexPath.row]
                cell.textLabel?.text = getAssetDisplayStrForSiteCheck(item)
                cell.textLabel?.numberOfLines = 0
            }
        case .certificateReview:
            if let itemArray = self.itemArray as? [User], itemArray.count > indexPath.row {
                let item = itemArray[indexPath.row]
                cell.textLabel?.text = getUserDisplayStr(item)
                cell.textLabel?.numberOfLines = 0
            }
        case .searchAsset:
            if let itemArray = self.itemArray as? [AssetDetailsResponse], itemArray.count > indexPath.row {
                let item = itemArray[indexPath.row]
                cell.textLabel?.text = getAssetDisplayStrForSiteCheck(item)
                cell.textLabel?.numberOfLines = 0
            }
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch type {
        case .sitePinCode:
            let selectedItem = filteredArray[indexPath.row]
            didSelectItem?(selectedItem)
        case .documnetGuide:
            let selectedItem = documentFilter[indexPath.row]
            didSelectItem?(selectedItem)
        case .tagAsset:
            if tagAssetItemArray.count > indexPath.row {
                let item = tagAssetItemArray[indexPath.row]
                didSelectItem?(item)
            }
        case .createContracts:
            let selectedItem = (filteredArray[indexPath.row], indexPath.row)
            didSelectItem?(selectedItem)
        case .leadUser:
            if leadUserItemArray.count > indexPath.row {
                let item = leadUserItemArray[indexPath.row]
                didSelectItem?(item)
            }
        case .assistantUser:
            if assistantUserItemArray.count > indexPath.row {
                let item = assistantUserItemArray[indexPath.row]
                didSelectItem?(item)
            }
        case .faultsIdentifiedTag:
            if tagAssetItemArray.count > indexPath.row {
                let item = tagAssetItemArray[indexPath.row]
                didSelectItem?(item)
            }
        case .certificateReview:
            if itemArray.count > indexPath.row {
                let item = itemArray[indexPath.row]
                didSelectItem?(item)
            }
        case .searchAsset:
            if itemArray.count > indexPath.row {
                let item = itemArray[indexPath.row]
                didSelectItem?(item)
            }
        }
        tableView.isHidden = true
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch type {
        case .sitePinCode, .documnetGuide, .tagAsset, .createContracts:
            return 45
        case .leadUser, .assistantUser, .faultsIdentifiedTag, .certificateReview, .searchAsset:
            return UITableView.automaticDimension
        }
        
    }
    
    func showTableView(with items: Any) {
        switch type {
        case .sitePinCode:
            if let items = items as? [String] {
                filteredArray = items
            }
        case .documnetGuide:
            if let items = items as? [File] {
                documentFilter = items
            }
        case .tagAsset:
            if let items = items as? [AssetDetailsResponse] {
                tagAssetItemArray = items
            }
        case .createContracts:
            if let items = items as? [String] {
                filteredArray = items
            }
        case .leadUser:
            if let items = items as? [User] {
                leadUserItemArray = items
            }
        case .assistantUser:
            if let items = items as? [User] {
                assistantUserItemArray = items
            }
        case .faultsIdentifiedTag:
            if let items = items as? [AssetDetailsResponse] {
                tagAssetItemArray = items
            }
        case .certificateReview:
            if let items = items as? [User] {
                self.itemArray = items
            }
        case .searchAsset:
            if let items = items as? [AssetDetailsResponse] {
                self.itemArray = items
            }
        }
        tableView.isHidden = false
    }
    
    func hideTableView() {
        tableView.isHidden = true
    }
}
