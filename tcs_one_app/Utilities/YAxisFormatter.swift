//
//  YAxisFormatter.swift
//  tcs_one_app
//
//  Created by TCS on 20/08/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import Foundation
import Charts

public class YAxisFormatter: NSObject, IAxisValueFormatter {
    
    public var suffix = ["", "k", "m", "b", "t"]
    public var appendix: String?
    public func stringForValue(_ value: Double,
                        axis: AxisBase?) -> String {
        return format(value: value)
    }
    public init(appendix: String? = nil) {
        self.appendix = appendix
    }
    fileprivate func format(value: Double) -> String {
        var sig = value
        var length = 0
        let maxLength = suffix.count - 1
        
        while sig >= 1000.0 && length < maxLength {
            sig /= 1000.0
            length += 1
        }
        
        var r = String(format: "%2.f", sig) + suffix[length]
        
        if let appendix = appendix {
            r += appendix
        }
        
        return r
    }
    
}
