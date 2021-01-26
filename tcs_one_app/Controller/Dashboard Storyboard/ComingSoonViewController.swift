//
//  ComingSoonViewController.swift
//  tcs_one_app
//
//  Created by TCS on 03/12/2020.
//  Copyright © 2020 Personal. All rights reserved.
//

import UIKit

class ComingSoonViewController: UIViewController {

    @IBOutlet weak var comingSoonLabel: UILabel!
    
    @IBOutlet weak var id: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var grade: UILabel!
    @IBOutlet weak var designation: UILabel!
    @IBOutlet weak var department: UILabel!
    @IBOutlet weak var reportedby: UILabel!
    var emp_id: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.1, alpha: 0.7)
        if let i = emp_id {
            id.text = "ID: \(i)"
        }
        if let n = UserDefaults.standard.string(forKey: "name") {
            name.text = "Name: \(n)"
        }
        if let g = UserDefaults.standard.string(forKey: "grade") {
            grade.text = "Grade: \(g)"
        }
        if let d = UserDefaults.standard.string(forKey: "designation") {
            designation.text = "Designation: \(d)"
        }
        if let de = UserDefaults.standard.string(forKey: "department") {
            department.text = "Department: \(de)"
        }
        if let rb = UserDefaults.standard.string(forKey: "reported_by") {
            reportedby.text = "Reported To: \(rb)"
        }
        
    }
    @IBAction func closeBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
