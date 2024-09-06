//
//  SettingsVC.swift
//  cafm
//
//  Created by Savan Lakhani on 21/08/24.
//

import UIKit

struct SettingsSectionData {
    var name: String
    var items: [(index: Int, name: String, image: String)]
}

class SettingsVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var itemArray: [SettingsSectionData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.setItemArray()
    }
    
    func setItemArray() {
        let userRole: UserEnum = UserDefaults.standard.userRole
        
        self.itemArray = []
        
        var generalSection = SettingsSectionData(name: "General", items: [])
        generalSection.items.append((index: 1, name: "Dashboard", image: "house.fill"))
        if userRole == .admin {
            generalSection.items.append((index: 2, name: "Edit Profile", image: "person.circle.fill"))
        }
        generalSection.items.append((index: 3, name: "Portfolio", image: "square.grid.2x2"))
        generalSection.items.append((index: 4, name: "Reports", image: "chart.bar.fill"))
        if userRole == .admin {
            generalSection.items.append((index: 5, name: "Users", image: "person.2.fill"))
        }
        generalSection.items.append((index: 6, name: "Notifications", image: "bell.fill"))
        generalSection.items.append((index: 7, name: "Actions", image: "bolt.fill"))
        self.itemArray.append(generalSection)
        
        var siteActionsSection = SettingsSectionData(name: "Site Actions", items: [])
        if userRole == .admin {
            siteActionsSection.items.append((index: 11, name: "Create Site", image: "plus"))
        }
        siteActionsSection.items.append((index: 12, name: "Site Details", image: "building.2.fill"))
        siteActionsSection.items.append((index: 13, name: "Site Documents", image: "folder.fill"))
        siteActionsSection.items.append((index: 14, name: "Statutory Register", image: "doc.fill"))
        siteActionsSection.items.append((index: 15, name: "Site Assets", image: "wrench.fill"))
        if userRole != .surveyor && userRole != .tradesman {
            siteActionsSection.items.append((index: 16, name: "Site Contracts", image: "pip.fill"))
        }
        if userRole != .contractor && userRole != .surveyor && userRole != .tradesman {
            siteActionsSection.items.append((index: 17, name: "Pre-Action", image: "checkmark.shield.fill"))
        }
        siteActionsSection.items.append((index: 18, name: "Site Checks", image: "checklist.checked"))
        siteActionsSection.items.append((index: 19, name: "Energy Cost", image: "bolt.shield.fill"))
        siteActionsSection.items.append((index: 20, name: "Site Calendar", image: "calendar"))
        self.itemArray.append(siteActionsSection)
        
        if userRole == .admin {
            var adminSection = SettingsSectionData(name: "Admin", items: [])
            adminSection.items.append((index: 21, name: "Categories", image: "person.badge.shield.checkmark.fill"))
            adminSection.items.append((index: 22, name: "Dropdowns", image: "lanyardcard.fill"))
            adminSection.items.append((index: 23, name: "Company", image: "building.columns.fill"))
            self.itemArray.append(adminSection)
        }
        
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.changeNavigationBarAppearance(appDefault: false, backgroundColor: UIColor.black, tintColor: UIColor.white)
        self.configureNavigationBackButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.changeNavigationBarAppearance()
    }
    
}

extension SettingsVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.itemArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < self.itemArray.count {
            return self.itemArray[section].items.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        cell.selectionStyle = .none
        
        if indexPath.section < self.itemArray.count {
            let items = self.itemArray[indexPath.section].items
            if indexPath.row < items.count {
                let item = items[indexPath.row]
                cell.textLabel?.text = item.name
                cell.textLabel?.font = UIFont(name: .MontserratRegular, size: 17)
                cell.textLabel?.textColor = UIColor.white
                
                cell.imageView?.image = UIImage(systemName: item.image)?.withRenderingMode(.alwaysTemplate)
                cell.imageView?.contentMode = .scaleAspectFit
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section < self.itemArray.count {
            let items = self.itemArray[indexPath.section].items
            if indexPath.row < items.count {
                let item = items[indexPath.row]
                switch item.name {
                case "Dashboard":
                    self.navigationController?.popViewController(animated: false)
                    break
                case "Edit Profile":
                    break
                case "Portfolio":
                    break
                case "Reports":
                    break
                case "Users":
                    let vc = userManagemnetSB.instantiateViewController(withIdentifier: "UserManagementVC") as! UserManagementVC
                    self.navigationController?.pushViewController(vc, animated: true)
                    break
                case "Notifications":
                    break
                case "Actions":
                    let vc = generalSB.instantiateViewController(withIdentifier: "ActionsVC") as! ActionsVC
                    self.navigationController?.pushViewController(vc, animated: true)
                    break
                case "Create Site":
                    let vc = siteActionSB.instantiateViewController(withIdentifier: "CreateNewSiteVC") as! CreateNewSiteVC
                    self.navigationController?.pushViewController(vc, animated: true)
                    break
                case "Site Details":
                    let vc = siteActionSB.instantiateViewController(withIdentifier: "PortfolioManagementVC") as! PortfolioManagementVC
                    self.navigationController?.pushViewController(vc, animated: true)
                    break
                case "Site Documents":
                    let vc = documnetSB.instantiateViewController(withIdentifier: "DocumnetsVC") as! DocumnetsVC
                    self.navigationController?.pushViewController(vc, animated: true)
                    break
                case "Statutory Register":
                    break
                case "Site Assets":
                    break
                case "Site Contracts":
                    break
                case "Pre-Action":
                    break
                case "Site Checks":
                    break
                case "Energy Cost":
                    break
                case "Site Calendar":
                    break
                case "Categories":
                    break
                case "Dropdowns":
                    break
                case "Company":
                    break
                default:
                    break
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = UIColor.white.withAlphaComponent(0.5)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section < self.itemArray.count {
            return self.itemArray[section].name
        }
        return nil
    }
    
    
}

