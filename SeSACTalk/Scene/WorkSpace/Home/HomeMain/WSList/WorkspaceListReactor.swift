//
//  WorkspaceListReactor.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/16/24.
//

import Foundation
import ReactorKit

final class WorkspaceListReactor: Reactor {
    var initialState: State = State(
        allWorkspace: [],
        loginRequest: false,
        message: "",
        successLeave: nil
    )
    
    
    enum Action {
        case requestAllWorkspace
        case requestExit(id: Int?)
    }
    enum Mutation {
        case msg(msg: String)
        case loginRequest
        case fetchAllWorkspace(data: [WorkspaceDto])
        case completLeave(data: [WorkspaceDto])
    }
    struct State {
        var allWorkspace: [WorkSpace]
        var loginRequest: Bool
        var message: String
        var successLeave: [WorkSpace]?
    }
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .requestAllWorkspace:
            return requestAllWorkspace()
        case .requestExit(let id):
            if let id = id {
                return requestExitWorkspace(id: id)
            } else {
                return Observable.of(Mutation.msg(msg: "ARGUMENT ERROR"))
            }
            
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
            newState.allWorkspace = data.map{ $0.toDomain() }
        case .completLeave(let data):
            newState.successLeave = data.map { $0.toDomain() }
        }
        return newState
    }
    
    private func requestExitWorkspace(id: Int) -> Observable<Mutation> {
        return WorkspacesAPIManager.shared.request(api: .leave(id: id), resonseType: AllWorkspaceReDTO.self)
            .asObservable()
            .map { result -> Mutation in
                switch result {
                case .success(let response):
                    return Mutation.completLeave(data: response ?? [])
                case .failure(let error):
                    if let error = WorkspaceError(rawValue: error.errorCode) {
                        return Mutation.msg(msg: error.localizedDescription)
                    } else if let error = CommonError(rawValue: error.errorCode) {
                        return Mutation.msg(msg: error.localizedDescription)
                    } else {
                        return Mutation.msg(msg: CommonError.E99.localizedDescription)
                    }
                }
                
            }
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