//
//  DMsAPI.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/12/24.
//

import Foundation
import Moya

enum DMsAPI {
    case fetchDM(id: Int)
}

extension DMsAPI: TargetType {
    var baseURL: URL {
        return URL(string: BaseURL.baseURL)!
    }
    
    var path: String {
        switch self {
        case .fetchDM(id: let id):
            return Endpoint.workspaces.rawValue + "/\(id)/dms"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchDM:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .fetchDM: return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        return ["Authorization": UserDefaultsManager.accessToken, "SesacKey": APIKey.key]
    }
    
    
    
    
}
