//
//  DmChatListResDTO.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/8/24.
//

import Foundation
struct DmChatListResDTO: Decodable {
    let workspace_id: Int
    let room_id: Int
    let chats: [DmChatResDTO]
    
    
    func toDomain() -> DmChatList {
        .init(workspaceId: workspace_id, roomId: room_id, chats: chats.map { $0.toDomain() })
    }
    
    
}
