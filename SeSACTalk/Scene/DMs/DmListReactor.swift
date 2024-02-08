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
        memberInfo: nil
    )
    
    
    enum Action {
        case requestMemberList(wsId: Int)
    }
    
    enum Mutation {
        case msg(msg: String)
        case loginRequest
        case memberInfo(data: [User])
        
        
    }
    
    struct State {
        var msg: String
        var loginRequest: Bool
        var memberInfo: [User]?
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .requestMemberList(let wsId):
            return requestMemberList(wsId: wsId)
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
        }
        
        return newState
    }
    
}

extension DmListReactor {
    private func requestMemberList(wsId: Int) -> Observable<Mutation> {
        return WorkspacesAPIManager.shared.request(api: .member(id: wsId), resonseType: MemberResDTO.self)
            .asObservable()
            .map { result -> Mutation in
                switch result {
                case .success(let response):
                    if let response = response {
                        print("[SUCCESS FETCH MEMBER]")
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
