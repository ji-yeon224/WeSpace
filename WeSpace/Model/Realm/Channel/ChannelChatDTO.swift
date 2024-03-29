//
//  ChannelMsgTable.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/24/24.
//

import Foundation
import RealmSwift

final class ChannelChatDTO: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var channelId: Int
    @Persisted var chatId: Int
    @Persisted var content: String?
    @Persisted var createdAt: String
    @Persisted var files: List<String>
    
    
    @Persisted var userId: Int
    @Persisted var userName: String
    @Persisted var userEmail: String
    @Persisted var urls: List<String>
    @Persisted(originProperty: "chatItem") var channelInfo: LinkingObjects<ChannelDTO>
    
    convenience init(channelId: Int, chatId: Int, content: String? = nil, createdAt: String, files: [String], urls: [String], userId: Int, userName: String, userEmail: String) {
        self.init()
        self._id = _id
        self.channelId = channelId
        self.chatId = chatId
        self.content = content
        self.createdAt = createdAt
        self.files.append(objectsIn: files.map{$0})
        self.urls.append(objectsIn: urls.map{$0})
        
        self.userId = userId
        self.userName = userName
        self.userEmail = userEmail
    }
    
    func setImgUrls(urls: [String]) {
        self.urls.append(objectsIn: urls.map{$0})
    }
    
    func toDomain(name: String) -> ChannelMessage {
        return .init(
            channelID: channelId,
            channelName: name,
            chatID: chatId,
            content: content,
            createdAt: createdAt,
            files: files.map{$0},
            imgUrls: urls.map{$0},
            user: User(userId: userId, email: userEmail, nickname: userName, profileImage: "")
        )
    }
    
    
}



