//
//  EmailLoginResponseDTO.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/7/24.
//

import Foundation

struct EmailLoginResponseDTO: Decodable {
    let user_id: Int
    let nickname: String
    let accessToken: String
    let refreshToken: String
}
 
