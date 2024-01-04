//
//  UsersAPI.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/4/24.
//

import Foundation
import Moya

enum UsersAPI {
    case validation(email: EmailValidationRequest)
    
    
}
extension UsersAPI: TargetType {
    var baseURL: URL {
        return URL(string: BaseURL.baseURL)!
    }
    
    var path: String {
        switch self {
        case .validation:
            return "v1/users/validation/email"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .validation:
            return .post
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .validation(let email):
            return .requestJSONEncodable(email)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .validation:
            return ["Content-Type": "application/json", "SesacKey": APIKey.key]
        }
    }
    
}
