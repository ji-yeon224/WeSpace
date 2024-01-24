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
    
    
    func fetchAll() -> Results<ChannelMsgTable>{
        return realm.read(object: ChannelMsgTable.self)
    }
    
    func fetchLastData() -> ChannelMsgTable? {
        return realm.realm.objects(ChannelMsgTable.self).max {
            $0._id < $1._id
        }
    }
    
    func createData(data: [ChannelMsgTable]) {
        realm.write(object: data)
    }
    
    func getLocation() {
        realm.getRealmLocation()
    }
    
}
