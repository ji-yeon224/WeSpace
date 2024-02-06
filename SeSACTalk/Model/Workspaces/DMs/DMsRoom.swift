//
//  DMsRoom.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/12/24.
//

import Foundation
struct DMsRoom: Hashable {
    let id = UUID()
    let workspaceID, roomID: Int
    let createdAt: String
    let user: User
    var unread: Int = 0
}
