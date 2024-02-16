//
//  CoinsAPI.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/15/24.
//

import Foundation
import Moya

enum CoinsAPI {
    case coinItemList
    case validation(data: PortOneValidationReqDTO)
}

extension CoinsAPI: TargetType {
    var baseURL: URL {
        return URL(string: BaseURL.baseURL)!
    }
    
    var path: String {
        switch self {
        case .coinItemList:
            return Endpoint.coin.rawValue + "/item/list"
        case .validation:
            return Endpoint.coin.rawValue + "/pay/validation"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .coinItemList:
            return .get
        case .validation:
            return .post
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .coinItemList:
            return .requestPlain
        case .validation(let data):
            return .requestJSONEncodable(data)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .coinItemList:
            return ["Authorization": UserDefaultsManager.accessToken, "SesacKey": APIKey.key]
        case .validation:
            return ["Content-Type": "application/json", "Authorization": UserDefaultsManager.accessToken, "SesacKey": APIKey.key]
        }
    }
    
    
    
    
}
