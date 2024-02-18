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
    case sendMsg(wsId: Int, roomId: Int, data: ChatReqDTO)
    case unreads(wsId: Int, roomId: Int, after: String?)
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
        case .sendMsg(let wsId, let roomId, _):
            return Endpoint.workspaces.rawValue + "/\(wsId)/dms/\(roomId)/chats"
        case .unreads(let wsId, let roomId, let after):
            return Endpoint.workspaces.rawValue + "/\(wsId)/dms/\(roomId)/unreads"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchDM, .fetchDmChat, .unreads:
            return .get
        case .sendMsg:
            return .post
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
        case .sendMsg(_, _, let data):
            return .uploadMultipart(data.multipartData())
        case .unreads(_, _, let after):
            if let after = after {
                let parameter = ["after": after]
                return .requestParameters(parameters: parameter, encoding: URLEncoding.queryString)
            } else {
                return .requestPlain
            }
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .fetchDM, .fetchDmChat, .unreads:
            return ["Authorization": UserDefaultsManager.accessToken, "SesacKey": APIKey.key]
        case .sendMsg:
            return ["Content-Type": "multipart/form-data", "Authorization": UserDefaultsManager.accessToken, "SesacKey": APIKey.key]
        }
        
    }
    
    
    
    
}

extension DMsAPI {
    var validationType: ValidationType {
        return .successCodes
    }
}
