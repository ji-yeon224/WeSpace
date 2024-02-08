//
//  DmChatList.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/8/24.
//

import Foundation

struct DmChatList: Hashable {
    let workspaceId: Int
    let roomId: Int
    let chats: [DmChat]
}
