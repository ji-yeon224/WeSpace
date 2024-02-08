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
    let cratedAt: String
    let files: [String]
    let user: User
}
