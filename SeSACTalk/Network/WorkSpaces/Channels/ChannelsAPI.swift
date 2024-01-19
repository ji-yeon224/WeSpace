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
}

extension ChannelsAPI: TargetType {
    var baseURL: URL {
        return URL(string: BaseURL.baseURL)!
    }
    
    var path: String {
        switch self {
        case .myChannel(let id):
            return Endpoint.workspaces.rawValue + "/\(id)/channels/my"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .myChannel(let id):
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .myChannel(let id):
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .myChannel(let id):
            return ["Authorization": UserDefaultsManager.accessToken, "SesacKey": APIKey.key]
        }
    }
    
    
}

extension ChannelsAPI {
    var validationType: ValidationType {
        return .successCodes
    }
}
