//
//  DmRepository.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/9/24.
//

import Foundation
import RealmSwift

final class DmRepository {
    let realm = try! Realm()
    
    func create(object: DmDTO) throws {
        do {
            try realm.write {
                realm.add(object)
            }
        } catch {
            throw DBError.createError
        }
    }
    
    func fetchDmCursorDate(wsId: Int, roomId: Int) -> String? {
        if let dm = searchDm(wsId: wsId, roomId: roomId) {
            return dm.lastDate
        }
        return nil
    }
    
    func searchDm(wsId: Int, roomId: Int) -> DmDTO? {
        let data = realm.objects(DmDTO.self).where {
            $0.workspaceId == wsId && $0.roomId == roomId
        }
        return data.first
    }
    
    func updateDmChatItems(object: DmDTO, chat: [DmChatDTO]) throws {
        do {
            try realm.write {
                object.chatItem.append(objectsIn: chat)
                realm.add(object)
            }
        } catch {
            throw DBError.updateError
        }
    }
    
}
