//
//  DmPushDTO.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/16/24.
//

import Foundation
struct DmPushDTO: Decodable {
    let aps: Aps
    let type, workspaceID, roomID, oppendID: String

    enum CodingKeys: String, CodingKey {
        case aps, type
        case workspaceID = "workspace_id"
        case roomID = "room_id"
        case oppendID = "opponent_id"
    }
}


