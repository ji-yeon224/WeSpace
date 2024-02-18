//
//  ImageLoadManager.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/12/24.
//

import Foundation
import Kingfisher

final class ImageLoadManager {
    
    static let shared = ImageLoadManager()
    private init() { }
    
    func getModifier() -> AnyModifier {
        return AnyModifier { request in
            var r = request
            r.setValue(UserDefaultsManager.accessToken, forHTTPHeaderField: "Authorization")
            r.setValue(APIKey.key, forHTTPHeaderField: "SesacKey")
            return r
        }
    }
}
