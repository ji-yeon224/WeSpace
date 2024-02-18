//
//  PushDTO.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/16/24.
//

import Foundation

struct PushDTO: Decodable {
    let aps: Aps
    let type, workspaceID: String
    let roomID, channelID, oppendID: String?
    
    enum CodingKeys: String, CodingKey {
        case aps, type
        case workspaceID = "workspace_id"
        case channelID = "channel_id"
        case roomID = "room_id"
        case oppendID = "opponent_id"
    }

}
struct Aps: Decodable {
    let alert: Alert
}

struct Alert: Decodable {
    let body, title: String
}
