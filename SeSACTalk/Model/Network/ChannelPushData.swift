//
//  ChannelPushData.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/16/24.
//

import Foundation
struct ChannelPushDTO: Codable {
    let aps: Aps
    let type, workspaceID, channelID: String

    enum CodingKeys: String, CodingKey {
        case aps, type
        case workspaceID = "workspace_id"
        case channelID = "channel_id"
    }
}

struct Aps: Codable {
    let alert: Alert
}

struct Alert: Codable {
    let body, title: String
}
