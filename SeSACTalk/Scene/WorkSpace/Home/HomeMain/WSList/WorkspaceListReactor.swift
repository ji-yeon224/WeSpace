//
//  WorkspaceListReactor.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/16/24.
//

import Foundation
import ReactorKit

final class WorkspaceListReactor: Reactor {
    var initialState: State = State(allWorkspace: [], loginRequest: false, message: "")
    
    
    enum Action {
        case requestAllWorkspace
    }
    enum Mutation {
        case msg(msg: String)
        case loginRequest
        case fetchAllWorkspace(data: [WorkspaceDto])
    }
    struct State {
        var allWorkspace: [WorkSpace]
        var loginRequest: Bool
        var message: String
    }
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .requestAllWorkspace:
            return requestAllWorkspace()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .msg(let msg):
            newState.message = msg
        case .loginRequest:
            newState.loginRequest = true
        case .fetchAllWorkspace(let data):
            newState.allWorkspace = data.map{
                $0.toDomain()
            }
        }
        return newState
    }
    
    private func requestAllWorkspace() -> Observable<Mutation> {
        return WorkspacesAPIManager.shared.request(api: .fetchAll, resonseType: AllWorkspaceReDTO.self)
            .asObservable()
            .map { result -> Mutation in
                switch result {
                case .success(let value):
                    return Mutation.fetchAllWorkspace(data: value ?? [])
                case .failure(let error):
                    return Mutation.msg(msg: error.localizedDescription)
                }
                
            }
    }
    
}
