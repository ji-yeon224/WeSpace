//
//  ChannelDTO.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/25/24.
//

import Foundation
import RealmSwift

final class ChannelDTO: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var workspaceId: Int
    @Persisted var channelId: Int
    @Persisted var name: String
    @Persisted var chatItem: List<ChannelChatDTO>
    @Persisted var imgItem: List<ImageDTO>
    @Persisted var lastDate: String?
    
    convenience init(workspaceId: Int, channelId: Int, name: String) {
        self.init()
        self.workspaceId = workspaceId
        self.channelId = channelId
        self.name = name
    }
    
}
