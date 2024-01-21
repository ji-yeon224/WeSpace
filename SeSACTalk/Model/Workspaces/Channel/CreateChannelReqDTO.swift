//
//  CreateChannelReqDTO.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/21/24.
//

import Foundation

struct CreateChannelReqDTO: Encodable {
    let name: String
    let description: String?
}
