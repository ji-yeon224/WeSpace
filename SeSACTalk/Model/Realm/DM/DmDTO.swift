//
//  DmDTO.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/9/24.
//

import Foundation
import RealmSwift

final class DmDTO: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var workspaceId: Int
    @Persisted var roomId: Int
    @Persisted var createdAt: String
    @Persisted var lastDate: String?
    @Persisted var dmImg: List<ImageDTO>
    @Persisted var dmItem: List<DmChatDTO>
    
    convenience init(workspaceId: Int, roomId: Int, createdAt: String) {
        self.init()
        self.workspaceId = workspaceId
        self.roomId = roomId
        self.createdAt = createdAt
    }
    
}
