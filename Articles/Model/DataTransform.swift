//
//  DataTransform.swift
//  Articles
//
//  Created by HoangVanDuc on 11/27/19.
//  Copyright © 2019 HoangVanDuc. All rights reserved.
//

import UIKit
import Foundation
import ObjectMapper

class DataTransform: TransformType {
   public typealias Object = Date
    public typealias JSON = Double

    public enum Unit: TimeInterval {
        case seconds = 1
        case milliseconds = 1_000
        
        func addScale(to interval: TimeInterval) -> TimeInterval {
            return interval * rawValue
        }
        
        func removeScale(from interval: TimeInterval) -> TimeInterval {
            return interval / rawValue
        }
    }
    
    private let unit: Unit
    
    public init(unit: Unit = .seconds) {
        self.unit = unit
    }

    open func transformFromJSON(_ value: Any?) -> Date? {
        var timeInterval: TimeInterval?
        if let timeInt = value as? Double {
            timeInterval = TimeInterval(timeInt)
        }
        
        if let timeStr = value as? String {
            timeInterval = TimeInterval(atof(timeStr))
        }
        
        return timeInterval.flatMap {
            return Date(timeIntervalSince1970: unit.removeScale(from: $0))
        }
    }

    open func transformToJSON(_ value: Date?) -> Double? {
        if let date = value {
            return Double(unit.addScale(to: date.timeIntervalSince1970))
        }
        return nil
    }
}
