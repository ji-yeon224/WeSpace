//
//  DmListReactor.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/8/24.
//

import Foundation
import ReactorKit

final class DmListReactor: Reactor {
    var initialState: State = State(
        msg: "",
        loginRequest: false,
        memberInfo: nil,
        dmList: []
    )
    
    
    enum Action {
        case requestMemberList(wsId: Int?)
        case requestDmList(wsId: Int?)
    }
    
    enum Mutation {
        case msg(msg: String)
        case loginRequest
        case memberInfo(data: [User])
        case dmList(data: [DMsRoom])
        
    }
    
    struct State {
        var msg: String
        var loginRequest: Bool
        var memberInfo: [User]?
        var dmList: [DMsRoom]
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .requestMemberList(let wsId):
            if let wsId = wsId {
                return requestMemberList(wsId: wsId)
            } else {
                return .just(.msg(msg: WorkspaceToastMessage.loadError.message))
            }
        case .requestDmList(let wsId):
            if let wsId = wsId {
                return requestDmList(wsId: wsId)
            } else {
                return .just(.msg(msg: WorkspaceToastMessage.loadError.message))
            }
            
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .msg(let msg):
            newState.msg = msg
        case .loginRequest:
            newState.loginRequest = true
        case .memberInfo(let data):
            newState.memberInfo = data
        case .dmList(let data):
            newState.dmList = data
        }
        
        return newState
    }
    
}

extension DmListReactor {
    
    
    
    private func requestDmList(wsId: Int) -> Observable<Mutation> {
        return DMsAPIManager.shared.request(api: .fetchDM(id: wsId), resonseType: DMsRoomResDTO.self)
            .asObservable()
            .map { result in
                switch result {
                case .success(let response):
                    if let response = response {
                        let error = response.map { $0.toDomain() }
                        return .dmList(data: error)
                    }
                    return .msg(msg: WorkspaceToastMessage.loadError.message)
                case .failure(let error):
                    if let error = DmError(rawValue: error.errorCode) {
                        return .msg(msg: error.localizedDescription)
                    } else if let error = CommonError(rawValue: error.localizedDescription) {
                        return .msg(msg: error.localizedDescription)
                    } else {
                        return .loginRequest
                    }
                }
                
            }
    }
    
//    private func requestLastDmChat(wsId: Int, userId: Int, date: String?) -> Observable<String> {
//        return DMsAPIManager.shared.request(api: .fetchDmChat(wsId: wsId, userId: userId, date: date), resonseType: DmChatListResDTO.self)
//            .asObservable()
//            .map { result -> Mutation in
//                switch result {
//                case .success(let response):
//                    
//                case .failure(let error):
//                    if let error = DmError(rawValue: error.errorCode) {
//                        return .msg(msg: error.localizedDescription)
//                    } else if let error = CommonError(rawValue: error.localizedDescription) {
//                        return .msg(msg: error.localizedDescription)
//                    } else {
//                        return .loginRequest
//                    }
//                }
//            }
//    }
    
    
    private func requestMemberList(wsId: Int) -> Observable<Mutation> {
        return WorkspacesAPIManager.shared.request(api: .member(id: wsId), resonseType: MemberResDTO.self)
            .asObservable()
            .map { result -> Mutation in
                switch result {
                case .success(let response):
                    if let response = response {
                        
                        let data = response.map { $0.toDomain()}.filter { $0.userId != UserDefaultsManager.userId }
                        return .memberInfo(data: data)
                    }
                    return .msg(msg: WorkspaceToastMessage.loadError.message)
                case .failure(let error):
                    print(error.errorCode)
                    if let error = WorkspaceError(rawValue: error.errorCode) {
                        return .msg(msg: error.localizedDescription)
                    } else if let error = CommonError(rawValue: error.errorCode) {
                        return .msg(msg: error.localizedDescription)
                    } else {
                        return .loginRequest
                    }
                    
                }
            }
    }
}
