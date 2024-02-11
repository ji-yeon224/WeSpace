//
//  ChannelMsgRepository.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/24/24.
//

import Foundation
import UIKit
import RealmSwift

final class ChannelMsgRepository {
    
    private let realm = try! Realm()
    
    
    func fetchAll() -> Results<ChannelChatDTO>{
        return realm.objects(ChannelChatDTO.self)//read(object: ChannelChatDTO.self)
    }
    
    
    func createData(data: [ChannelChatDTO]) throws {
        do {
            try realm.write {
                realm.add(data)
            }
        } catch {
            throw DBError.createError
        }
    }
    
    func getLocation() {
        print("=====Realm 경로: ", realm.configuration.fileURL!)
    }
    
//    func updateImage(data: ChannelChatDTO, imgs: [ChatImageDTO]) throws {
//        do {
//            try realm.write {
//                data.imgUrls.append(objectsIn: imgs)
//                realm.add(data)
//            }
//        } catch {
//            throw DBError.updateError
//        }
//    }
    
    func isExistItem(channelId: Int, chatId: Int) -> Bool {
        return realm.objects(ChannelChatDTO.self).where {
            $0.channelId == channelId && $0.chatId == chatId
        }.count > 0 ? true : false
        
    }
    
    func saveImageToDocument(fileName: String, image: SelectImage) {
        // 1. 도큐먼트 경로 찾기
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        var directoryPath = documentDirectory.appendingPathComponent("Channel")
        
        if !FileManager.default.fileExists(atPath: directoryPath.path) {
            do {
                try FileManager.default.createDirectory(atPath: directoryPath.path, withIntermediateDirectories: false)
            } catch {
                directoryPath = documentDirectory
            }
            
        }
        // 2. 저장할 경로 설정(세부 경로, 이미지를 저장할 위치)
        let fileURL = directoryPath.appendingPathComponent("\(fileName)")
        
//        print(fileURL)
        // 3. 이미지 변환
        guard let data = image.img?.jpegData(compressionQuality: 0.5) else { return }
        
        
        
        // 4. 이미지 저장
        do {
            try data.write(to: fileURL)
        } catch let error {
            print("file save error", error)
            // 사용자에게 보여줄 액션을 구현해야 한다.
        }
    }
    func delete(data: ChannelChatDTO) throws {
        do {
            try realm.write {
                realm.delete(data)
            }
        } catch {
            throw DBError.deleteError
        }
    }
    
    func delete(object: ChannelChatDTO) throws {
        removeImageFromDocuments(fileName: object.urls.map{$0})
        do {
            try realm.write {
                realm.delete(object)
            }
        } catch {
            throw DBError.deleteError
        }
    }
    
    private func removeImageFromDocuments(fileName: [String]) {
        
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
