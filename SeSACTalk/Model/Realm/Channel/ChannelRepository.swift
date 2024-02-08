//
//  ChannelRepository.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/25/24.
//

import Foundation
import RealmSwift
import UIKit

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
    
    func fetchChannelCursorDate(wsId: Int, chId: Int) -> String? {
        if let channel = searchChannel(wsId: wsId, chId: chId).first {
            return channel.lastDate
        }
        return nil
    }
    
    func updateChannelInfo(data: ChannelDTO, name: String) throws{
        
        do {
            try realm.write {
                data.name = name
            }
        } catch {
            throw DBError.updateError
        }
        
    }
    func updateChannelDate(data: ChannelDTO, date: String) throws {
        
        do {
            try realm.write {
                data.lastDate = date
            }
        } catch {
            throw DBError.updateError
        }
        
    }
    
    func updateChatItems(data: ChannelDTO, chat: [ChannelChatDTO]) throws {
//        print("ㅁㅁ", chat, data)
        do {
            try realm.write {
                data.chatItem.append(objectsIn: chat)
                realm.add(data)
            }
        } catch {
            print("error")
            throw DBError.updateError
        }
    }
    
    func updateImgItems(data: ChannelDTO, img: [ImageDTO]) throws {
        do {
            try realm.write {
                data.imgItem.append(objectsIn: img)
                realm.add(data)
            }
        } catch {
            print("error")
            throw DBError.updateError
        }
    }
    
    func delete(object: ChannelDTO) throws {
        removeImageFromDocuments(fileName: object.imgItem.map { $0.url })
        do {
            try realm.write {
                realm.delete(object.imgItem)
                realm.delete(object.chatItem)
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
    
    func loadImageFromDocuments(fileName: [String]) -> [UIImage] {
        
        var imgData: [UIImage] = []
        
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return [] }
        
        fileName.forEach {
            let fileURL = documentDirectory.appendingPathComponent($0)
            
            if FileManager.default.fileExists(atPath: fileURL.path) {
                if let img = UIImage(contentsOfFile: fileURL.path) {
                    imgData.append(img)
                }
                
            } 
        }
        
        return imgData
        
    }
    
    private func removeImageFromDocuments(fileName: [String]) {
        print("REMOVE IMG..")
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        fileName.forEach {
            let fileURL = documentDirectory.appendingPathComponent($0)
            do {
                if !FileManager.default.fileExists(atPath: fileURL.path) {
                    try FileManager.default.removeItem(at: fileURL)
                }
            } catch {
                print("REMOVE ERROR")
            }
            
        }
    }
    
}
