//
//  EmailLoginRequestDTO.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/7/24.
//

import Foundation

struct EmailLoginRequestDTO: Encodable {
    let email: String
    let password: String
    let deviceToken: String?
}
