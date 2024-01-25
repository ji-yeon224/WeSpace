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
    
    func saveImageToDocument(fileName: String, image: SelectImage) {
        // 1. 도큐먼트 경로 찾기
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        
        // 2. 저장할 경로 설정(세부 경로, 이미지를 저장할 위치)
        let fileURL = documentDirectory.appendingPathComponent("\(fileName)")
        print(fileURL)
        // 3. 이미지 변환
        guard let data = image.img?.jpegData(compressionQuality: 0.8) else { return }
        
        
        
        // 4. 이미지 저장
        do {
            try data.write(to: fileURL)
        } catch let error {
            print("file save error", error)
            // 사용자에게 보여줄 액션을 구현해야 한다.
        }
    }
    
    
    
}
