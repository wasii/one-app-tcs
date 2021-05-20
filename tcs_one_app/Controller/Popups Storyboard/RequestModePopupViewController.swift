//
//  RequestModePopupViewController.swift
//  tcs_one_app
//
//  Created by ibs on 02/11/2020.
//  Copyright © 2020 Personal. All rights reserved.
//

import UIKit

class RequestModePopupViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var isFulfillment = false
    var selected_option: String?
    var options: [FilterData]?
    var delegate: DateSelectionDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.1, alpha: 0.7)
        // Do any additional setup after loading the view.
        setupJSON()
    }
    
    func setupJSON() {
        self.options = [FilterData]()
        if isFulfillment {
            for option in FULFILLMENTFILTERDATA {
                if option == self.selected_option! {
                    options?.append(FilterData(title: option, isSelected: true))
                } else {
                    options?.append(FilterData(title: option, isSelected: false))
                }
            }
        } else {
            for option in REQUESTFILTERDATA {
                if option == self.selected_option! {
                    options?.append(FilterData(title: option, isSelected: true))
                } else {
                    options?.append(FilterData(title: option, isSelected: false))
                }
            }
        }
        self.tableView.reloadData()
    }

    @IBAction func applyBtnTapped(_ sender: Any) {
        if selected_option != nil {
            self.dismiss(animated: true) {
                self.delegate?.requestModeSelected(selected_query: self.selected_option!)
            }
        }
    }
    @IBAction func cancelBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}


extension RequestModePopupViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = self.options?.count {
            return count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterListingDataCell") as! FilterListingDataTableCell
        let data = self.options![indexPath.row]
        
        if data.isSelected {
            cell.selected_Image.image = UIImage(named: "radioMark")
        } else {
            cell.selected_Image.image = UIImage(named: "radioUnmark")
        }
        
        cell.title_Label.text = data.title
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        for d in 0..<self.options!.count {
            self.options![d].isSelected = false
        }
        
        self.options![indexPath.row].isSelected = true
        self.tableView.reloadData()
        
        self.selected_option = self.options![indexPath.row].title
    }
}
