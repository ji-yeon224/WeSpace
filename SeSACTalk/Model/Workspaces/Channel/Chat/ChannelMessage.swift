//
//  ChannelMessage.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/22/24.
//

import Foundation
import RealmSwift
struct ChannelMessage: Hashable {
    let id = UUID()
    let channelID: Int
    let channelName: String
    let chatID: Int
    let content: String?
    let createdAt: String
    let files: [String]
    let user: User
    
    func toRecord() -> ChannelChatDTO {
        return ChannelChatDTO(channelId: channelID, channelName: channelName, chatId: chatID, content: content, createdAt: createdAt, files: files, userId: user.userId, userName: user.nickname, userEmail: user.email)
    }
    
}
