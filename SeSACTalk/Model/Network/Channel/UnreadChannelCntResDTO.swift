//
//  UnreadChannelCntResDTO.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/6/24.
//

import Foundation

struct UnreadChannelCntResDTO: Decodable {
    let channel_id: Int
    let name: String
    let count: Int
}
