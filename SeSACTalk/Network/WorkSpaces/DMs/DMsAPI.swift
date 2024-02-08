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
    case fetchDmChat(wsId: Int, userId: Int, date: String?)
}

extension DMsAPI: TargetType {
    var baseURL: URL {
        return URL(string: BaseURL.baseURL)!
    }
    
    var path: String {
        switch self {
        case .fetchDM(id: let id):
            return Endpoint.workspaces.rawValue + "/\(id)/dms"
        case .fetchDmChat(let wsId, let userId, _):
            return Endpoint.workspaces.rawValue + "/\(wsId)/dms/\(userId)/chats"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchDM, .fetchDmChat:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .fetchDM:
            return .requestPlain
        case .fetchDmChat(_, _, let date):
            if let date = date {
                let parameter = ["cursor_date": date]
                return .requestParameters(parameters: parameter, encoding: URLEncoding.queryString)
            } else {
                return .requestPlain
            }
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .fetchDM, .fetchDmChat:
            return ["Authorization": UserDefaultsManager.accessToken, "SesacKey": APIKey.key]
        }
        
    }
    
    
    
    
}
