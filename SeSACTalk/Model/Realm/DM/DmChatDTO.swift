//
//  DmChatDTO.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/9/24.
//

import Foundation
import RealmSwift

final class DmChatDTO: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var dmId: Int
    @Persisted var roomId: Int
    @Persisted var content: String?
    @Persisted var files: List<String>
    @Persisted var urls: List<String>
    @Persisted var createdAt: String
    
    @Persisted(originProperty: "dmItem") var dmInfo: LinkingObjects<DmDTO>
    
    convenience init(dmId: Int, roomId: Int, content: String? = nil, files: [String], urls: [String], createdAt: String) {
        self.init()
        self.dmId = dmId
        self.roomId = roomId
        self.content = content
        self.files.append(objectsIn: files.map { $0 })
        self.urls.append(objectsIn: urls.map { $0 })
        self.createdAt = createdAt
        self.dmInfo = dmInfo
    }
    
    func setImgUrls(urls: [String]) {
        self.urls.append(objectsIn: urls.map{$0})
    }
    
    func toDomain() -> DmChat {
        return .init(dmId: dmId, roomId: roomId, content: content, createdAt: createdAt, files: files.map { $0 }, imgUrls: urls.map { $0 } ,user: nil)
//        return .init(dmId: dmId, roomId: roomId, content: content, createdAt: createdAt, files: files.map { $0 }, imgUrls: urls.map {$0}, user: nil)
    }
    
}
