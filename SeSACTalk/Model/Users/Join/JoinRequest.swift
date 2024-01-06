//
//  JoinResponse.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/5/24.
//

import Foundation

struct JoinRequest: Encodable {
    
    let email: String
    let password: String
    let nickname: String
    let phone: String?
    let deviceToken: String
    
}
