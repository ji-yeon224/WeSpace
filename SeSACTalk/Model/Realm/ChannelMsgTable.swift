//
//  ChannelMsgTable.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/24/24.
//

import Foundation
import RealmSwift

final class ChannelMsgTable: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var channelId: Int
    @Persisted var channelName: String
    @Persisted var chatId: Int
    @Persisted var content: String?
    @Persisted var createdAt: String
    @Persisted var files: List<String>
    
    @Persisted var userId: Int
    @Persisted var email: String
    @Persisted var nickname: String
    @Persisted var profileImage: String?
    
    convenience init(channelId: Int, channelName: String, chatId: Int, content: String? = nil, createdAt: String, files: List<String>, userId: Int, email: String, nickname: String, profileImage: String? = nil) {
        self.init()
        self._id = _id
        self.channelId = channelId
        self.channelName = channelName
        self.chatId = chatId
        self.content = content
        self.createdAt = createdAt
        self.files = files
        self.userId = userId
        self.email = email
        self.nickname = nickname
        self.profileImage = profileImage
    }
}
