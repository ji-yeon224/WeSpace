//
//  ChannelChatReqDTO.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/24/24.
//

import Foundation
import Moya

struct ChannelChatReqDTO: Encodable {
    let content: String?
    let files: [Data]?
    
    private func convertToMap() -> [String: Data] {
        var param: [String: Data] = [:]
        if let content = content {
            param["content"] = content.data(using: .utf8) ?? Data()
        }
        
        
        return param
    }
    
    func multipartData() -> [MultipartFormData] {
        var multipart: [MultipartFormData] = []
        
        let params = convertToMap()
        
        
        for param in params {
            multipart.append(MultipartFormData(provider: .data(param.value), name: param.key))

        }
        
        if let img = files {
            img.forEach {
                multipart.append(MultipartFormData(provider: .data($0), name: "files", fileName: "image.jpeg", mimeType: "image/jpg"))
            }
            
        }
        
        return multipart
    }
    
}
