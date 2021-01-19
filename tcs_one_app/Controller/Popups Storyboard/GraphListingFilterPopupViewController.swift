//
//  GraphListingFilterPopupViewController.swift
//  tcs_one_app
//
//  Created by TCS on 06/11/2020.
//  Copyright © 2020 Personal. All rights reserved.
//

import UIKit

class GraphListingFilterPopupViewController: BaseViewController {

    var master_query_filtered_list: [tbl_MasterQuery]?
    var selected_item: String?
    var selected_id: Int?
    var delegate: GraphListingDelegate?
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.1, alpha: 0.7)
        
        setupJSON()
    }
    
    
    func setupJSON() {
        let master_query = AppDelegate.sharedInstance.db?.read_tbl_masterQuery(module_id: CONSTANT_MODULE_ID)
        
        if let data = master_query {
            master_query_filtered_list = [tbl_MasterQuery]()
            for (i, d) in data.enumerated() {
                if d.MQ_DESC == self.selected_item {
                    self.master_query_filtered_list?.append(d)
                    self.master_query_filtered_list?[i].IsSelected = true
                    self.selected_id =  self.master_query_filtered_list?[i].SERVER_ID_PK
                } else {
                    self.master_query_filtered_list?.append(d)
                    self.master_query_filtered_list?[i].IsSelected = false
                }
            }
            self.tableView.reloadData()
        }
        
    }
    
    
    @IBAction func okBtnTapped(_ sender: Any) {
        if selected_id != nil {
            self.dismiss(animated: true) {
                self.delegate?.updateGraphListingFilter(id: "\(self.selected_id!)", title: self.selected_item!)
            }
        }
    }
    @IBAction func cancelBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}


extension GraphListingFilterPopupViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = self.master_query_filtered_list?.count{
            return count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterListingDataCell") as! FilterListingDataTableCell
        
        let data = self.master_query_filtered_list![indexPath.row]
        cell.title_Label.text = data.MQ_DESC
        
        if data.IsSelected {
            cell.selected_Image.image = UIImage(named: "radioMark")
        } else {
            cell.selected_Image.image = UIImage(named: "radioUnmark")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        for i in 0..<self.master_query_filtered_list!.count {
            self.master_query_filtered_list![i].IsSelected = false
        }
        
        self.master_query_filtered_list![indexPath.row].IsSelected = true
        self.selected_id = self.master_query_filtered_list![indexPath.row].SERVER_ID_PK
        self.selected_item = self.master_query_filtered_list![indexPath.row].MQ_DESC
        
        
        self.tableView.reloadData()
    }
}
