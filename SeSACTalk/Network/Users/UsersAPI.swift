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
    case join(data: JoinRequest)
    case kakaoLogin(data: KakaoLoginRequestDTO)
    case emailLogin(data: EmailLoginRequestDTO)
    
}
extension UsersAPI: TargetType {
    
    var baseURL: URL {
        return URL(string: BaseURL.baseURL)!
    }
    
    var path: String {
        switch self {
        case .validation:
            return Endpoint.user.rawValue + "/validation/email"
        case .join:
            return Endpoint.user.rawValue + "/join"
        case .kakaoLogin:
            return Endpoint.user.rawValue + "/login/kakao"
        case .emailLogin:
            return Endpoint.user.rawValue + "/login"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .validation, .join, .kakaoLogin, .emailLogin:
            return .post
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .validation(let email):
            return .requestJSONEncodable(email)
        case .join(let data):
            return .requestJSONEncodable(data)
        case .kakaoLogin(let data):
            return .requestJSONEncodable(data)
        case .emailLogin(let data):
            return .requestJSONEncodable(data)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .validation, .join, .kakaoLogin, .emailLogin:
            return ["Content-Type": "application/json", "SesacKey": APIKey.key]
        }
    }
    
}
