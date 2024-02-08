//
//  DmChatResDTO.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/8/24.
//

import Foundation
struct DmChatResDTO: Decodable {
    let dm_id: Int
    let room_id: Int
    let content: String?
    let createdAt: String
    let files: [String]
    let user: UserResDTO
    
    func toDomain() -> DmChat {
        return .init(dmId: dm_id, roomId: room_id, content: content, cratedAt: createdAt, files: files, user: user.toDomain())
    }
}

