//
//  ProfileImageReqDTO.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/14/24.
//

import Foundation
import Moya

struct ProfileImageReqDTO: Encodable {
    let image: Data
    
    func multipartData() -> [MultipartFormData] {
        var multipart: [MultipartFormData] = []
        
        multipart.append(MultipartFormData(provider: .data(image), name: "image", fileName: "profile.jpeg", mimeType: "image/jpg"))
        
        return multipart
    }
    
    
}
