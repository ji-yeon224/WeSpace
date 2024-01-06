//
//  JoinResponseDto.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/6/24.
//

import Foundation

struct JoinResponseDTO: Decodable {
    
    var user_id: Int
    var email : String
    var nickname: String
    var phone: String?
    var vendor: String?
    var token: Token
}
struct Token: Decodable {
    var accessToken: String
    var refreshToken: String
}

extension JoinResponseDTO {
    func toDomain() -> JoinSuccess {
        return .init(id: user_id, email: email, nickname: nickname, accessToken: token.accessToken, refreshToken: token.refreshToken)
    }
}

