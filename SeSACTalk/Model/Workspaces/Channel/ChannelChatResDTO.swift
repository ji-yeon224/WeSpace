//
//  ChannelChatResDTO.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/22/24.
//

import Foundation
struct ChannelMessageDTO: Decodable {
    let channelID: Int
    let channelName: String
    let chatID: Int
    let content: String?
    let createdAt: String
    let files: [String]
    let user: UserResDTO
    
    enum CodingKeys: String, CodingKey {
        case channelID = "channel_id"
        case channelName
        case chatID = "chat_id"
        case content, createdAt, files, user
    }
    func toDomain() -> ChannelMessage {
        return .init(channelID: channelID, channelName: channelName, chatID: chatID, content: content, createdAt: createdAt, files: files, user: user.toDomain())
    }
}
typealias ChannelChatResDTO = [ChannelMessageDTO]
