//
//  ProfileUpdateReqDTO.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/14/24.
//

import Foundation

struct ProfileUpdateReqDTO: Encodable {
    var nickname: String
    var phone: String?
}
