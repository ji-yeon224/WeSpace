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
    case fetchOne(id: Int)
    case editWS(data: WsCreateReqDTO, id: Int)
}

extension WorkspacesAPI: TargetType {
    var baseURL: URL {
        return URL(string: BaseURL.baseURL)!
    }
    
    var path: String {
        switch self {
        case .create, .fetchAll:
            return Endpoint.workspaces.rawValue
        case .fetchOne(id: let id), .editWS(data: _, id: let id):
            return Endpoint.workspaces.rawValue + "/\(id)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .create:
            return .post
        case .fetchAll, .fetchOne:
            return .get
        case .editWS:
            return .put
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .create(let data), .editWS(let data, id: _):
            let multipart = MultipartFormDataManager.shared.convertToMultipart(data: data.convertToMap(), files: [data.image])
            return .uploadMultipart(multipart)
        case .fetchAll, .fetchOne:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .create, .editWS:
            return ["Content-Type": "application/json", "Authorization": UserDefaultsManager.accessToken, "SesacKey": APIKey.key]
        case .fetchAll, .fetchOne:
            return ["Authorization": UserDefaultsManager.accessToken, "SesacKey": APIKey.key]
        }
    }
    
    
}
extension WorkspacesAPI {
    var validationType: ValidationType {
        return .successCodes
    }
}
