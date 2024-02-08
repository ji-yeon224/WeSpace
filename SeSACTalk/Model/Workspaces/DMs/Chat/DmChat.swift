//
//  DmChat.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/8/24.
//

import Foundation

struct DmChat: Hashable {
    let dmId: Int
    let roomId: Int
    let content: String?
    let createdAt: String
    let files: [String]
    let imgUrls: [String]? = nil
    let user: User?
    
    func toRecord() -> DmChatDTO {
        return .init(dmId: dmId, roomId: roomId, content: content, files: files, urls: imgUrls ?? [], createdAt: createdAt)
    }
    
}
