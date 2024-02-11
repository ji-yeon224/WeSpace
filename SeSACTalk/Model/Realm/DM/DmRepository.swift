//
//  DmRepository.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/9/24.
//

import UIKit
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
    func updateImgItems(data: DmDTO, img: [ImageDTO]) throws {
        do {
            try realm.write {
                data.dmImg.append(objectsIn: img)
                realm.add(data)
            }
        } catch {
            print("error")
            throw DBError.updateError
        }
    }
    
    func updateDmLastDate(object: DmDTO, date: String) throws {
        do {
            try realm.write {
                object.lastDate = date
            }
        } catch {
            throw DBError.updateError
            
        }
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
