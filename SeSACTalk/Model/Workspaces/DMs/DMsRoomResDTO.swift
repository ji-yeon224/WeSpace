//
//  DMsResDTO.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/12/24.
//

import Foundation
struct DMsRoomDTO: Decodable {
    let workspaceID, roomID: Int
    let createdAt: String
    let user: UserResDTO
    
    enum CodingKeys: String, CodingKey {
        case workspaceID = "workspace_id"
        case roomID = "room_id"
        case createdAt, user
    }
    
    func toDomain() -> DMsRoom {
        return .init(workspaceID: workspaceID, roomID: roomID, createdAt: createdAt, user: user.toDomain())
    }
}

typealias DMsRoomResDTO = [DMsRoomDTO]
