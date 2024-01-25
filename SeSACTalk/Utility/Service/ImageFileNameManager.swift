//
//  ImageFileNameManager.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/25/24.
//

import Foundation


final class ImageFileNameManager {
    static let shared = ImageFileNameManager()
    private init() { }
    static func getFileName(type: DBImageFileName, fileURL: String) -> String {
        let fileName = fileURL.components(separatedBy: "/").last ?? ""
        return type.fileName + fileName
    }
}

typealias ImageFileService = ImageFileNameManager
