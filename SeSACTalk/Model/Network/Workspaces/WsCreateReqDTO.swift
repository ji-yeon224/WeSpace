//
//  WorkspaceCreateReqDTO.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/10/24.
//

import Foundation
struct WsCreateReqDTO: Encodable {
    let name: String
    let description: String?
    let image: Data
    
    func convertToMap() -> [String: Data] {
        var param: [String: Data] = [:]
        param["name"] = self.name.data(using: .utf8) ?? Data()
        param["description"] = self.description?.data(using: .utf8) ?? Data()
        return param
    }
    
}
