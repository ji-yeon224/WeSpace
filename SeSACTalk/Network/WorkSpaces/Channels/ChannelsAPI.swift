//
//  ChannelsAPI.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/19/24.
//

import Foundation
import Moya

enum ChannelsAPI {
    case myChannel(id: Int)
    case create(id: Int, data: CreateChannelReqDTO)
    case edit(id: Int, name: String, data: CreateChannelReqDTO)
    case sendMsg(name: String, id: Int, data: ChannelChatReqDTO)
    case fetchMsg(date: String?, name: String, wsId: Int)
    case member(name: String, wsId: Int)
    case allChannel(wsId: Int)
    case oneChannel(wsId: Int, name: String)
    case exit(wsId: Int, name: String)
}

extension ChannelsAPI: TargetType {
    var baseURL: URL {
        return URL(string: BaseURL.baseURL)!
    }
    
    var path: String {
        switch self {
        case .myChannel(let id):
            return Endpoint.workspaces.rawValue + "/\(id)/channels/my"
        case .create(let id, _), .allChannel(let id):
            return Endpoint.workspaces.rawValue + "/\(id)/channels"
        case .edit(let id, let name, _):
            return Endpoint.workspaces.rawValue + "/\(id)/channels/\(name)"
        case .sendMsg(let name, let id, _):
            return Endpoint.workspaces.rawValue + "/\(id)/channels/\(name)/chats"
        case .fetchMsg(_, let name, let wsId):
            return Endpoint.workspaces.rawValue + "/\(wsId)/channels/\(name)/chats"
        case .member(let name, let wsId):
            return Endpoint.workspaces.rawValue + "/\(wsId)/channels/\(name)/members"
        case .oneChannel(let wsId, let name):
            return Endpoint.workspaces.rawValue + "/\(wsId)/channels/\(name)"
        case .exit(let wsId, let name):
            return Endpoint.workspaces.rawValue + "/\(wsId)/channels/\(name)/leave"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .myChannel, .fetchMsg, .member, .allChannel, .oneChannel, .exit:
            return .get
        case .create, .sendMsg:
            return .post
        case .edit:
            return .put
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .myChannel, .member, .allChannel, .oneChannel, .exit:
            return .requestPlain
        case .create(_, data: let data), .edit(_, _, let data):
            return .requestJSONEncodable(data)
        case .sendMsg(_, _, let data):
            return .uploadMultipart(data.multipartData())
        case .fetchMsg(let date, _, _):
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
        case .myChannel, .fetchMsg, .member, .allChannel, .oneChannel, .exit :
            return ["Authorization": UserDefaultsManager.accessToken, "SesacKey": APIKey.key]
        case .create, .edit:
            return ["Content-Type": "application/json", "Authorization": UserDefaultsManager.accessToken, "SesacKey": APIKey.key]
        case .sendMsg:
            return ["Content-Type": "multipart/form-data", "Authorization": UserDefaultsManager.accessToken, "SesacKey": APIKey.key]
        }
    }
    
    
}

extension ChannelsAPI {
    var validationType: ValidationType {
        return .successCodes
    }
}
