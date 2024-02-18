//
//  Date+Extension.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/7/24.
//

import Foundation

extension Date {
    public func dateCompare(fromDate: Date) -> String {
            var strDateMessage:String = ""
            let result:ComparisonResult = self.compare(fromDate)
            switch result {
            case .orderedAscending:
                strDateMessage = "Future"
                break
            case .orderedDescending:
                strDateMessage = "Past"
                break
            case .orderedSame:
                strDateMessage = "Same"
                break
            default:
                strDateMessage = "Error"
                break
            }
            return strDateMessage
        }
    
    
    static func isTodayDate(compareDate: String) -> Bool {
        if let date = String.convertToDate(format: .fullDate, date: compareDate) {
            if Calendar.current.compare(Date(), to: date, toGranularity: .day) == .orderedSame {
                return true
            } else {
                return false
            }
        }
        
        return false
        
    }
    
    
}
