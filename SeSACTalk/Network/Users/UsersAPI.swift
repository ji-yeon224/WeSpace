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
    case deviceToken(data: DeviceTokenReq)
    case otherUser(userId: Int)
    case profile(data: ProfileImageReqDTO)
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
        case .deviceToken:
            return Endpoint.user.rawValue + "/deviceToken"
        case .otherUser(let userId):
            return Endpoint.user.rawValue + "/\(userId)"
        case .profile:
            return Endpoint.user.rawValue + "/my/image"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .validation, .join, .kakaoLogin, .emailLogin, .deviceToken:
            return .post
        case .my, .otherUser:
            return .get
        case .profile:
            return .put
            
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
        case .my, .otherUser:
            return .requestPlain
        case .deviceToken(let data):
            return .requestJSONEncodable(data)
        case .profile(let data):
            return .uploadMultipart(data.multipartData())
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .validation, .join, .kakaoLogin, .emailLogin:
            return ["Content-Type": "application/json", "SesacKey": APIKey.key]
        case .my, .otherUser:
            return ["Authorization": UserDefaultsManager.accessToken, "SesacKey": APIKey.key]
        case .deviceToken:
            return ["Content-Type": "application/json", "SesacKey": APIKey.key, "Authorization": UserDefaultsManager.accessToken]
        case .profile:
            return ["Content-Type": "multipart/form-data", "Authorization": UserDefaultsManager.accessToken, "SesacKey": APIKey.key]
        }
    }
    
}

extension UsersAPI {
    var validationType: ValidationType {
        return .successCodes
    }
}
