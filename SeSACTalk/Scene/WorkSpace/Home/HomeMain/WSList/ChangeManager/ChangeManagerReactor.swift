//
//  ChangeManagerReactor.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/18/24.
//

import Foundation
import ReactorKit

final class ChangeManagerReactor: Reactor {
    var initialState: State = State(
        memberInfo: nil,
        msg: "",
        loginRequest: false,
        successChange: nil
    )
    
    
    enum Action {
        case requestMember(id: Int?)
        case requestChange(wsId: Int?, userId: Int?)
    }
    
    enum Mutation {
        case responseMember(data: [User])
        case msg(msg: String)
        case loginRequest
        case successChange(data: WorkSpace?)
    }
    
    struct State {
        var memberInfo: [User]?
        var msg: String
        var loginRequest: Bool
        var successChange: WorkSpace?
    }
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .requestMember(let id):
            if let id = id {
                return requestMember(id: id)
            } else { return Observable.of(Mutation.msg(msg: "Error"))}
        case .requestChange(let wsId, let userId):
            if let wsId = wsId, let userId = userId {
                return requestChangeManager(wsId: wsId, userId: userId)
            } else {
                return Observable.of(Mutation.msg(msg: "Error"))
            }
           
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .responseMember(let data):
            newState.memberInfo = data
            
        case .msg(let msg):
            newState.msg = msg
        case .loginRequest:
            newState.loginRequest = true
        case .successChange(let data):
            if let data = data {
                newState.successChange = data
            }
        }
        return newState
    }
    
}

extension ChangeManagerReactor {
    
    private func requestChangeManager(wsId: Int, userId: Int) -> Observable<Mutation> {
        
        return WorkspacesAPIManager.shared.request(api: .changeManager(wsId: wsId, userId: userId), resonseType: WorkspaceDto.self)
            .asObservable()
            .map { result -> Mutation in
                
                switch result {
                case .success(let response):
                    return Mutation.successChange(data: response?.toDomain())
                    
                case .failure(let error):
                    var msg = CommonError.E99.localizedDescription
                    if let error = WSCreateError(rawValue: error.errorCode) {
                        msg = error.localizedDescription
                    } else if let error = CommonError(rawValue: error.errorCode) {
                        msg = error.localizedDescription
                    } else {
                        return Mutation.loginRequest
                    }
                    
                    return Mutation.msg(msg: msg)
                }
                
            }
        
    }
    
    private func requestMember(id: Int) -> Observable<Mutation> {
        
        return WorkspacesAPIManager.shared.request(api: .member(id: id), resonseType: MemberResDTO.self)
            .asObservable()
            .map { result -> Mutation in
                
                switch result {
                case .success(let response):
                    if let response = response {
                        var items: [User] = []
                        response.forEach {
                            if $0.user_id != UserDefaultsManager.userId {
                                items.append($0.toDomain())
                            }
                            
                        }
                        return Mutation.responseMember(data: items)
                    } else {
                        return Mutation.responseMember(data: [])
                    }
                    
                case .failure(let error):
                    var msg = CommonError.E99.localizedDescription
                    if let error = WorkspaceError(rawValue: error.errorCode) {
                        msg = error.localizedDescription
                    } else if let error = CommonError(rawValue: error.errorCode) {
                        msg = error.localizedDescription
                    } else {
                        return Mutation.loginRequest
                    }
                    
                    return Mutation.msg(msg: msg)
                }
                
            }
        
    }
    
    
}
