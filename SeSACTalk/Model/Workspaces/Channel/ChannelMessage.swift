//
//  ChannelMessage.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/22/24.
//

import Foundation

struct ChannelMessage: Hashable {
    let id = UUID()
    let channelID: Int
    let channelName: String
    let chatID: Int
    let content: String?
    let createdAt: String
    let files: [String]
    let user: User
}
