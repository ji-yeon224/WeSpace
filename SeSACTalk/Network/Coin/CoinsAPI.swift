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
    
}

extension CoinsAPI: TargetType {
    var baseURL: URL {
        return URL(string: BaseURL.baseURL)!
    }
    
    var path: String {
        switch self {
        case .coinItemList:
            return Endpoint.coin.rawValue + "/item/list"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .coinItemList:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .coinItemList:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .coinItemList:
            return ["Authorization": UserDefaultsManager.accessToken, "SesacKey": APIKey.key]
        }
    }
    
    
    
    
}
