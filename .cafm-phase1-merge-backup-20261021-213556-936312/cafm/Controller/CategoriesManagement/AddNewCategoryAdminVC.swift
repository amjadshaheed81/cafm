//
//  AddNewCategoryAdminVC.swift
//  cafm
//
//  Created by ShitaRam on 27/10/24.
//

import UIKit
import SCLAlertView

class AddNewCategoryAdminVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var tfMainType: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var data = CategoryTypeModel()
    var editData: APiCategoryTypeModel?
    
    var scl: SCLAlertView?
    
    weak var homeVC: CategoriesManagementVC?

    override func viewDidLoad() {
        super.viewDidLoad()
        if let editData = self.editData {
            self.title = "Categories Management - Edit"
            data.type = editData.type?.lovValue ?? ""
            data.id = editData.type?.id
            self.tfMainType.text = data.type
            for subType in editData.subTypeArray {
                let subData = SubTypeModel()
                subData.subType = subType.subType?.lovValue ?? ""
                subData.id = subType.subType?.id
                for category in subType.subTypeCategoryArray {
                    let catData = SubTypeCategoryModel()
                    catData.subTypeCategory = category.lovValue ?? ""
                    catData.id = category.id
                    subData.subTypeCategoryArray.append(catData)
                }
                data.subTypeArray.append(subData)
            }
        }else {
            self.title = "Categories Management - Add"
        }
        tableView.delegate = self
        tableView.dataSource = self
    }
        
    
    @IBAction func btnAddSubTypeClick(_ sender: Any) {
        data.subTypeArray.append(SubTypeModel())
        self.tableView.reloadData()
    }
    
    @IBAction func btnSaveClick(_ sender: Any) {
        self.data.type = tfMainType.text?.trimmingCharacters(in: .whitespaces) ?? ""
        if self.data.type.isEmpty {
            showAlert(message: "Please enter Type")
            return
        }else {
            DispatchQueue.main.async {
                let appearance = SCLAlertView.SCLAppearance(
                    showCloseButton: false // if you dont want the close button use false
                )
                self.scl = SCLAlertView(appearance: appearance)
                self.scl?.showWait("", subTitle: "please wait...", closeButtonTitle: "")
                Task {
                    await self.handleSubmit(with: self.data, viewController: self)
                }
            }
        }
    }
    
    // Function to send POST requests with error handling
    func post(_ url: String, _ body: [String: Any]) async throws {
        guard let url = URL(string: url) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let cookieValue = jwtToken ?? ""
        request.setValue(cookieValue, forHTTPHeaderField: "Cookie")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "", code: (response as? HTTPURLResponse)?.statusCode ?? 0, userInfo: [NSLocalizedDescriptionKey: "Request failed with status: \((response as? HTTPURLResponse)?.statusCode)"])
        }
        print("Request succeeded with response code: \(httpResponse.statusCode)")
    }
    
    func put(_ url: String, _ body: [String: Any]) async throws {
        guard let url = URL(string: url) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        let cookieValue = jwtToken ?? ""
        request.setValue(cookieValue, forHTTPHeaderField: "Cookie")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "", code: (response as? HTTPURLResponse)?.statusCode ?? 0, userInfo: [NSLocalizedDescriptionKey: "Request failed with status: \((response as? HTTPURLResponse)?.statusCode)"])
        }
        print("PUT request succeeded with response code: \(httpResponse.statusCode)")
    }


    // Main function equivalent to `handleSubmit` with error handling
    // Main function with conditional PUT and POST requests based on model ID presence
    func handleSubmit(with data: CategoryTypeModel, viewController: UIViewController) async {
        do {
            // Create typeBody with optional id included
            var typeBody: [String: Any] = [
                "lovType": "SITE_CHECK_TYPE",
                "lovValue": data.type
            ]
            if let typeId = data.id {
                typeBody["id"] = "\(typeId)"
                try await put("\(ApiService.baseApi)/api/lov/id/\(typeId)", typeBody)
            } else {
                try await post("\(ApiService.baseApi)/api/lov/", typeBody)
            }
            
            // Iterate through subtypes
            for subtype in data.subTypeArray {
                var subtypeBody: [String: Any] = [
                    "lovType": "SITE_CHECK_SUB_TYPE",
                    "lovValue": subtype.subType,
                    "attribite1": data.type
                ]
                if let subtypeId = subtype.id {
                    subtypeBody["id"] = "\(subtypeId)"
                    try await put("\(ApiService.baseApi)/api/lov/id/\(subtypeId)", subtypeBody)
                } else {
                    try await post("\(ApiService.baseApi)/api/lov/", subtypeBody)
                }
                
                // Iterate through subcategories
                for category in subtype.subTypeCategoryArray {
                    var categoryBody: [String: Any] = [
                        "lovType": "SITE_CHECK_CATEGORY",
                        "lovValue": category.subTypeCategory,
                        "attribite1": subtype.subType
                    ]
                    if let categoryId = category.id {
                        categoryBody["id"] = "\(categoryId)"
                        try await put("\(ApiService.baseApi)/api/lov/id/\(categoryId)", categoryBody)
                    } else {
                        try await post("\(ApiService.baseApi)/api/lov/", categoryBody)
                    }
                }
            }
            
            // Navigation, replace with your own logic
            DispatchQueue.main.async {
                self.scl?.hideView()
                self.homeVC?.fetchData()
                self.navigationController?.popViewController(animated: true)
            }
            
        } catch {
            // Handle any errors by displaying an alert
            DispatchQueue.main.async {
                self.scl?.hideView()
                self.displayAlert(message: "API request failed: \(error.localizedDescription)", viewController: viewController)
            }
        }
    }

    // Helper function to display an alert in case of error
    func displayAlert(message: String, viewController: UIViewController) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        viewController.present(alert, animated: true)
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.subTypeArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubTypeTableCell", for: indexPath) as! SubTypeTableCell
        let item = data.subTypeArray[indexPath.row]
        cell.selectionStyle = .none
        cell.item = item
        cell.itemInd = indexPath.row
        cell.homeVC = self
        cell.tfSubCateGory.placeholder = "Enter Subtype \(indexPath.row+1)"
        cell.tfSubCateGory.text = item.subType
        cell.tfSubCateGory.delegate = self
        cell.tfSubCateGory.tag = indexPath.row
        cell.setUPCollectionView()
        cell.btnAddCategory.addAction { [weak self] in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                let ind = indexPath.row
                data.subTypeArray[indexPath.row].subTypeCategoryArray.append(SubTypeCategoryModel())
                self.tableView.reloadData()
            }
        }
        cell.btnDeleteSubType.addAction { [weak self] in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                let ind = indexPath.row
                data.subTypeArray.remove(at: indexPath.row)
                self.tableView.reloadData()
            }
        }
        return cell
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Get the updated text after the change
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string).trimmingCharacters(in: .whitespacesAndNewlines)

        // Call your search functionality with the updated text
        print("rk : \(updatedText)")
        self.data.subTypeArray[textField.tag].subType = updatedText
        return true
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = data.subTypeArray[indexPath.row]
        return 10.0+110.0+(CGFloat(item.subTypeCategoryArray.count)*50)+10.0+5.0
    }
    
}


class SubTypeTableCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate {
    
    
    @IBOutlet weak var tfSubCateGory: UITextField!
    
    @IBOutlet weak var btnAddCategory: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var heightOfCollection: NSLayoutConstraint!
    
    
    @IBOutlet weak var btnDeleteSubType: UIButton!
    
    weak var homeVC :AddNewCategoryAdminVC?
    
    var item = SubTypeModel()
    var itemInd = 0
    
    func setUPCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isScrollEnabled = false
        collectionView.bounces = false
        heightOfCollection.constant = item.subTypeCategoryArray.count == 0 ? 0 : CGFloat((50*item.subTypeCategoryArray.count)-5 )
        collectionView.reloadData()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return item.subTypeCategoryArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCvCell", for: indexPath) as! CategoryCvCell
        cell.tfSubCategory.placeholder = "Enter Category \(indexPath.row+1)"
        cell.tfSubCategory.text = item.subTypeCategoryArray[indexPath.row].subTypeCategory
        cell.tfSubCategory.tag = indexPath.row
        cell.tfSubCategory.delegate = self
        cell.btnDeleteSubCategory.addAction { [weak self] in
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                let ind = indexPath.row
                self.homeVC?.data.subTypeArray[itemInd].subTypeCategoryArray.remove(at: ind)
                self.homeVC?.tableView.reloadData()
            }
        }
        return cell
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Get the updated text after the change
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string).trimmingCharacters(in: .whitespacesAndNewlines)

        // Call your search functionality with the updated text
        print("rk : \(updatedText)")
        self.homeVC?.data.subTypeArray[itemInd].subTypeCategoryArray[textField.tag].subTypeCategory = updatedText
        return true
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: screenWidth-40, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}


class CategoryCvCell: UICollectionViewCell {
    
    @IBOutlet weak var tfSubCategory: UITextField!
    @IBOutlet weak var btnDeleteSubCategory: UIButton!
    
}

class CategoryTypeModel {
    var id: Int?
    var type: String = ""
    var subTypeArray: [SubTypeModel] = []
}

class SubTypeModel {
    var id: Int?
    var subType: String = ""
    var subTypeCategoryArray: [SubTypeCategoryModel] = []
}

class SubTypeCategoryModel {
    var id: Int?
    var subTypeCategory: String = ""
}
