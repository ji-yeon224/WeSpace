//
//  UserResDTO.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/12/24.
//

import Foundation

struct UserResDTO: Decodable {
    let user_id: Int
    let email: String
    let nickname: String
    let profileImage: String?
    
    func toDomain() -> User {
        return .init(userId: user_id, email: email, nickname: nickname, profileImage: profileImage)
    }
}
