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
    case my
    
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
        case .my:
            return Endpoint.user.rawValue + "/my"
        
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .validation, .join, .kakaoLogin, .emailLogin:
            return .post
        case .my:
            return .get
            
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
        case .my:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .validation, .join, .kakaoLogin, .emailLogin:
            return ["Content-Type": "application/json", "SesacKey": APIKey.key]
        case .my:
            return ["Authorization": UserDefaultsManager.accessToken, "SesacKey": APIKey.key]
        }
    }
    
}
