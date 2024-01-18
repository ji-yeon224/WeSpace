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
        loginRequest: false
    )
    
    
    enum Action {
        case requestMember(id: Int?)
    }
    
    enum Mutation {
        case responseMember(data: [User])
        case msg(msg: String)
        case loginRequest
    }
    
    struct State {
        var memberInfo: [User]?
        var msg: String
        var loginRequest: Bool
    }
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .requestMember(let id):
            if let id = id {
                return requestMember(id: id)
            } else { return Observable.of(Mutation.msg(msg: "Error"))}
            
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
        }
        return newState
    }
    
}

extension ChangeManagerReactor {
    
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
