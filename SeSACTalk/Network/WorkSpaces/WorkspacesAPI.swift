//
//  WorkspacesAPI.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/10/24.
//

import Foundation
import Moya

enum WorkspacesAPI {
    case create(data: WsCreateReqDTO)
    case fetchAll
    
}

extension WorkspacesAPI: TargetType {
    var baseURL: URL {
        return URL(string: BaseURL.baseURL)!
    }
    
    var path: String {
        switch self {
        case .create, .fetchAll:
            return Endpoint.workspaces.rawValue
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .create:
            return .post
        case .fetchAll:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .create(let data):
            let multipart = MultipartFormDataManager.shared.convertToMultipart(data: data.convertToMap(), files: [data.image])
            return .uploadMultipart(multipart)
        case .fetchAll:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .create:
            return ["Content-Type": "application/json", "Authorization": UserDefaultsManager.accessToken, "SesacKey": APIKey.key]
        case .fetchAll:
            return ["Authorization": UserDefaultsManager.accessToken, "SesacKey": APIKey.key]
        }
    }
    
    
}
