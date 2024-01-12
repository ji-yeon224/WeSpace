//
//  AuthAPI.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/11/24.
//

import Foundation
import Moya

enum AuthAPI {
    case auth
}

extension AuthAPI: TargetType {
    var baseURL: URL {
        return URL(string: BaseURL.baseURL)!
    }
    
    var path: String {
        return "v1/auth/refresh"
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Moya.Task {
        return .requestPlain
    }
    
    var headers: [String : String]? {
        return ["RefreshToken": UserDefaultsManager.refreshToken, "Authorization": UserDefaultsManager.accessToken, "SesacKey": APIKey.key]
    }
    
    
}
