//
//  ChannelResponseDTO.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/12/24.
//

import Foundation

struct ChannelResDTO: Codable {
    let workspaceID, channelID: Int
    let name: String
    let description: String?
    let ownerID: Int
    let channelPrivate: Int?
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case workspaceID = "workspace_id"
        case channelID = "channel_id"
        case name, description
        case ownerID = "owner_id"
        case channelPrivate = "private"
        case createdAt
    }
    
    func toDomain() -> Channel {
        return .init(workspaceID: workspaceID, channelID: channelID, name: name, description: description, ownerID: ownerID, channelPrivate: channelPrivate, createdAt: createdAt)
    }
    
}

typealias ChannelsItemResDTO = [ChannelResDTO]
