//
//  ChannelMsgRepository.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/24/24.
//

import Foundation
import RealmSwift

final class ChannelMsgRepository {
    
    private let realm = RealmManager.shared
    
    
    func fetchAll() -> Results<ChannelChatDTO>{
        return realm.read(object: ChannelChatDTO.self)
    }
    
    func fetchLastData() -> ChannelChatDTO? {
        return realm.realm.objects(ChannelChatDTO.self).max {
            $0._id < $1._id
        }
    }
    
    func createData(data: [ChannelChatDTO]) throws {
        do {
            try realm.write(object: data)
        } catch {
            throw error
        }
    }
    
    func getLocation() {
        realm.getRealmLocation()
    }
    
}
