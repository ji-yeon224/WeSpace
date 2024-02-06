//
//  Channel.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/12/24.
//

import Foundation


struct Channel: Hashable {
    var id = UUID()
    let workspaceID, channelID: Int
    let name: String
    let description: String?
    let ownerID: Int
    let channelPrivate: Int?
    let createdAt: String
    var unread: Int = 0
    
    func setRecord() -> ChannelDTO {
        return .init(workspaceId: workspaceID, channelId: channelID, name: name)
    }
    
}


