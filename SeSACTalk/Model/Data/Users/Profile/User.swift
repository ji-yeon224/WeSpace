//
//  User.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/12/24.
//

import Foundation

struct User: Hashable {
    let userId: Int
    let email: String
    let nickname: String
    let profileImage: String?
}
