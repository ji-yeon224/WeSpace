//
//  KakaoLoginRequestDTO.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/6/24.
//

import Foundation

struct KakaoLoginRequestDTO: Decodable {
    
    let oauthToken: String
    let deviceToken: String?
    
    
}
