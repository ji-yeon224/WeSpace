//
//  String+Extension.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/4/24.
//

import Foundation
extension String {
    
    
    var lastString: String {
        get {
            if self.isEmpty { return self }
            
            let lastIndex = self.index(before: self.endIndex)
            return String(self[lastIndex])
        }
    }
    
    var isNumber: Bool {
       do {
          let regex = try NSRegularExpression(pattern: "^[0-9]+$", options: .caseInsensitive)
          if let _ = regex.firstMatch(in: self, options: .reportCompletion, range: NSMakeRange(0, count)) { return true }
          } catch { return false }
          return false
       }
    
    func isValidPhone() -> Bool {
        let regex = "^01([0-9]?)-?([0-9]{3,4})-?([0-9]{4})$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return phonePredicate.evaluate(with: self)
    }
    
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.com$"
        let pred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return pred.evaluate(with: self)
    }
    func isValidPassword()-> Bool {
        let pwRegex = "^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[!@#$%^&*()_+=-]).{8,50}"
        let pred = NSPredicate(format: "SELF MATCHES %@", pwRegex)
        return pred.evaluate(with: self)
    }
    
    static func convertToDate(format: DateFormatterType, date: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(identifier: TimeZone.current.identifier)
        formatter.dateFormat = format.rawValue
        return formatter.date(from: date)
    }
    
    // 서버에서 받은 데이터 포멧 변경하기
    var convertToDateFormat: String {
        if let dateType = String.convertToDate(format: .fullDate, date: self) {
            return DateFormatter.convertToString(format: .yearByDot, date: dateType)
            
        }
        
        return ""
    }
    
    
    var convertToTimeString: String {
        if let dateType = String.convertToDate(format: .fullDate, date: self) {
            return DateFormatter.convertToString(format: .time1, date: dateType)
        }
        
        return ""
    }
    
    // 이거로 변경하기..
    func convertDateFormat(format: DateFormatterType, to: DateFormatterType, date: String) -> String {
        if let dateType = String.convertToDate(format: format, date: date) {
            return DateFormatter.convertToString(format: to, date: dateType)
        }
        return ""
    }
    
    var splitHashtag: String {
        
        if self.isEmpty { return self }
        
        let startIndex = self.index(self.startIndex, offsetBy: 1)
        let lastIndex = self.index(before: self.endIndex)
        let range = startIndex...
        return String(self[range])
    }
    
}
