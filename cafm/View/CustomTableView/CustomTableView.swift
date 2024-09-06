//
//  CustomTableView.swift
//  cafm
//
//  Created by Savan Lakhani on 25/08/24.
//

import UIKit

class CustomTableView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    private var tableView: UITableView!
    var filteredArray: [String] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    var didSelectItem: ((String) -> Void)?

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
        return filteredArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = filteredArray[indexPath.row]
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = filteredArray[indexPath.row]
        didSelectItem?(selectedItem)
        tableView.isHidden = true
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    func showTableView(with items: [String]) {
        filteredArray = items
        tableView.isHidden = false
    }
    
    func hideTableView() {
        tableView.isHidden = true
    }
}
