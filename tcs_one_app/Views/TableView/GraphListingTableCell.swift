//
//  GraphListingTableCell.swift
//  tcs_one_app
//
//  Created by ibs on 20/10/2020.
//  Copyright © 2020 Personal. All rights reserved.
//

import UIKit

class GraphListingTableCell: UITableViewCell {

    @IBOutlet weak var mainHeading_Label: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var filterBtn: UIButton!
    @IBOutlet weak var crossBtn: UIButton!
    
    var multipleCharts = [MultipleCharts]()
    var lastCell = false
    
    var circularGraph: [CircularGraphListing]?
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.collectionView.register(UINib(nibName: "MultiplePieCharCollectionCell", bundle: nil), forCellWithReuseIdentifier: "MultiplePieChartCell")
        self.collectionView.register(UINib(nibName: "CicrularProgressBarCollectionCell", bundle: nil), forCellWithReuseIdentifier: "CicrularProgressBarCell")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setup() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.reloadData()
    }
    
    func setupCircular () {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        setupCircularWithoutCondition()
    }
    
    @IBAction func filterBtn_tapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Popups", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "GraphListingFilterPopupViewController") as! GraphListingFilterPopupViewController
        
        if #available(iOS 13.0, *) {
            controller.modalPresentationStyle = .overFullScreen
        }
        controller.modalTransitionStyle = .crossDissolve
        
        controller.delegate = self
        Helper.topMostController().present(controller, animated: true, completion: nil)
    }
    
    @IBAction func crossBtnTapped(_ sender: Any) {
        setupCircularWithoutCondition()
    }
    
    func setupCircularWithConditions(id: String) {
        let query = "SELECT M.SERVER_ID_PK, M.DQ_DESC as title, count(R.ID) as totalCount, M.COLOR_CODE as colorCode FROM \(db_detail_query) M LEFT OUTER JOIN \(db_hr_request) R ON M.SERVER_ID_PK = R.DQ_ID WHERE M.MQ_ID = '\(id)' AND R.CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)' GROUP by M.SERVER_ID_PK"
        
        circularGraph = AppDelegate.sharedInstance.db?.read_graphlisting(query: query)
        
        self.collectionView.reloadData()
    }
    
    @objc func setupCircularWithoutCondition() {
        let module_id = AppDelegate.sharedInstance.db?.read_tbl_UserModule(query: "SELECT * FROM \(db_user_module) WHERE TAGNAME = '\(MODULE_TAG_HR)';").first
        let query = "SELECT M.SERVER_ID_PK , M.MQ_DESC as title, count(R.ID) as totalCount , M.COLOR_CODE as colorCode FROM \(db_master_query) M LEFT OUTER JOIN \(db_hr_request) R ON M.SERVER_ID_PK = R.MQ_ID AND R.CURRENT_USER = '\(CURRENT_USER_LOGGED_IN_ID)' WHERE M.MODULE_ID = '\(module_id!.SERVER_ID_PK)' GROUP by M.SERVER_ID_PK"
        
        circularGraph = AppDelegate.sharedInstance.db?.read_graphlisting(query: query)
        self.collectionView.reloadData()
    }
}

extension GraphListingTableCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let count = multipleCharts.first?.count {
            return count
        }
        if let count = circularGraph?.count {
            lastCell = true
            return count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if self.lastCell{
            let circularGraphCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CicrularProgressBarCell", for: indexPath) as! CicrularProgressBarCollectionCell
            
            let data = self.circularGraph![indexPath.row]
            
            circularGraphCell.titleLabel.text = data.Title
            circularGraphCell.circularView.progressColor = UIColor.init(hexString: data.ColorCode)
            circularGraphCell.circularView.maxValue = CGFloat(Int(data.TotalCount)! + 30)
            circularGraphCell.circularView.value = CGFloat(Int(data.TotalCount)!)
            
            return circularGraphCell
        }
        
        let multiplePieChartCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MultiplePieChartCell", for: indexPath) as! MultiplePieCharCollectionCell
        
        let chartListing = self.multipleCharts[indexPath.section].chartListing[indexPath.row]
        multiplePieChartCell.setup(chartListing: chartListing)
        return multiplePieChartCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let data = self.circularGraph {
            print(data[indexPath.row].Title)
            
            
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let yourWidth = self.collectionView.frame.size.width / 3.0
        let yourHeight = self.collectionView.frame.size.height

        return CGSize(width: yourWidth, height: yourHeight)
        
        
        
    }
}


extension GraphListingTableCell: GraphListingDelegate {
    func updateGraphListingFilter(id: String, title: String) {
        self.setupCircularWithConditions(id: id)
    }
}
