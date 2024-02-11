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
    
    func getLocation() {
        print("=====Realm 경로: ", realm.configuration.fileURL!)
    }
    
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
        if let dm = searchDm(wsId: wsId, roomId: roomId).first {
            return dm.lastDate
        }
        return nil
    }
    
    func searchDm(wsId: Int, roomId: Int) -> Results<DmDTO> {
        let data = realm.objects(DmDTO.self).where {
            $0.workspaceId == wsId && $0.roomId == roomId
        }
        return data
    }
    
    func updateDmChatItems(object: DmDTO, chat: [DmChatDTO]) throws {
        do {
            try realm.write {
                object.dmItem.append(objectsIn: chat)
                realm.add(object)
            }
        } catch {
            throw DBError.updateError
        }
    }
    
}
