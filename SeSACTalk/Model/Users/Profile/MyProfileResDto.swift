//
//  MyProfileDto.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/7/24.
//

import Foundation

struct MyProfileResDto: Decodable {
    
    let user_id: Int
    let email: String
    let nickname: String
    let profileImage: String?
    let phone: String?
    let vendor: String?
    let sesacCoin: Int?
    let createdAt: String
    
    func toDomain() -> MyProfile {
        .init(id: user_id, email: email, nickname: nickname, profileImage: profileImage, phone: phone, vendor: vendor, sesacCoin: sesacCoin ?? 0, createdAt: createdAt)
    }
    
}
