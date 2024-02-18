//
//  Data+Extension.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/11/24.
//

import Foundation
extension Data {
    var convertToMb: String {
        
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useMB] // optional: restricts the units to MB only
        bcf.countStyle = .file
        return bcf.string(fromByteCount: Int64(self.count))
        
    }
    
    
    var convertToPushDto: PushDTO? {
        do {
            let jsonData = try JSONDecoder().decode(PushDTO.self, from: self)
            return jsonData
        } catch {
            print("error", error)
        }
        return nil
    }
}
