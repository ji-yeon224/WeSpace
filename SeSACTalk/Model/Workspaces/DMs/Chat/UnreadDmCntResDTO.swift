//
//  UnreadDmCntResDTO.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/12/24.
//

import Foundation

struct UnreadDmCntResDTO: Decodable {
    let room_id: Int
    let count: Int
}
