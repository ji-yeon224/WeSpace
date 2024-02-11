//
//  ImageFileNameManager.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/25/24.
//

import UIKit


final class ImageFileManager {
    static let shared = ImageFileManager()
    private init() { }
    static func getFileName(type: DBImageFileName, fileURL: String) -> String {
        let fileName = fileURL.components(separatedBy: "/").last ?? ""
        return type.fileName + fileName
    }
    
    func saveImageToDocument(type: CategoryType ,fileName: String, image: SelectImage) {
        // 1. 도큐먼트 경로 찾기
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        var directoryPath = documentDirectory.appendingPathComponent(type.rawValue)
        
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
    
    func loadImageFromDocuments(type: CategoryType, fileName: [String]) -> [UIImage] {
        
        var imgData: [UIImage] = []
        
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return [] }
        
        var directoryPath = documentDirectory.appendingPathComponent(type.rawValue)
        
        if !FileManager.default.fileExists(atPath: directoryPath.path) {
            do {
                try FileManager.default.createDirectory(atPath: directoryPath.path, withIntermediateDirectories: false)
            } catch {
                directoryPath = documentDirectory
            }
            
        }
        
        fileName.forEach {
            let fileURL = directoryPath.appendingPathComponent($0)
            print(fileURL)
            if FileManager.default.fileExists(atPath: fileURL.path) {
                if let img = UIImage(contentsOfFile: fileURL.path) {
                    imgData.append(img)
                }
                
            }
        }
        
        return imgData
        
    }
    
    private func removeImageFromDocuments(type: CategoryType, fileName: [String]) {
        print("REMOVE IMG..")
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        var directoryPath = documentDirectory.appendingPathComponent(type.rawValue)
        
        
        if !FileManager.default.fileExists(atPath: directoryPath.path) {
            directoryPath = documentDirectory
        }
        
        fileName.forEach {
            let fileURL = directoryPath.appendingPathComponent($0)
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

typealias ImageFileService = ImageFileManager
