//
//  MultipartFormDataManager.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/11/24.
//

import Foundation
import Moya

final class MultipartFormDataManager {
    static let shared = MultipartFormDataManager()
    private init() { }
    func convertToMultipart(data: [String: Data], files: [Data]) -> [MultipartFormData] {
        
        var multipart: [MultipartFormData] = []
        
        
        for param in data {
            multipart.append(MultipartFormData(provider: .data(param.value), name: param.key))

        }
        files.forEach {
            print($0.convertToMb)
            multipart.append(MultipartFormData(provider: .data($0), name: "image", fileName: "image.jpeg", mimeType: "image/jpg"))
            
        }
        
        return multipart
    }
}
