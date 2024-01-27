//
//  ChannelRepository.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/25/24.
//

import Foundation
import RealmSwift

final class ChannelRepository {
    
//    private let realm = RealmManager.shared
    
    let realm = try! Realm()
    
//    func read(data: ChannelDTO) -> Results<ChannelDTO> {
//        return realm.objects(data)
//    }
    func create(object: ChannelDTO) throws {
        do {
            try realm.write {
                realm.add(object)
            }
        } catch {
            throw DBError.createError
        }
    }
    
    
    func updateChatItems(data: ChannelDTO, chat: ChannelChatDTO) throws {
        print("ㅁㅁ", chat, data)
        do {
            try realm.write {
                data.chatItem.append(chat)
                realm.add(data)
            }
        } catch {
            print("error")
            throw DBError.updateError
        }
    }
    func delete(object: ChannelDTO) throws {
        do {
            try realm.write {
                realm.delete(object)
            }
        } catch {
            throw DBError.deleteError
        }
    }
    
    func searchChannel(wsId: Int, chId: Int) -> Results<ChannelDTO> {
        let data = realm.objects(ChannelDTO.self).where {
            $0.workspaceId == wsId && $0.channelId == chId
        }
        
        return data
    }
}
