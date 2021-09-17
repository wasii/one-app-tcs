//
//  XAxisFormatter.swift
//  tcs_one_app
//
//  Created by TCS on 17/09/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import Foundation
import Charts

public class XAxisFormatter: NSObject, IAxisValueFormatter {
    
    public var appendix: String?
    public func stringForValue(_ value: Double,
                        axis: AxisBase?) -> String {
        return format(value: value)
    }
    public init(appendix: String? = nil) {
        self.appendix = appendix
    }
    
    fileprivate func format(value: Double) -> String {
        
        let final = Date(timeIntervalSince1970: value)
        let df = DateFormatter()
        df.dateFormat = "dd/MM"
        let date = df.string(from: final)
        return date
    }
}
