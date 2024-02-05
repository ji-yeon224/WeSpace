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
        successLeave: nil,
        successDelete: nil
    )
    
    
    enum Action {
        case requestAllWorkspace
        case requestExit(id: Int?)
        case requestDelete(id: Int?)
    }
    enum Mutation {
        case msg(msg: String)
        case loginRequest
        case fetchAllWorkspace(data: [WorkspaceDto])
        case completLeave(data: [WorkspaceDto])
        case successDelete(data: [WorkspaceDto])
    }
    struct State {
        var allWorkspace: [WorkSpace]
        var loginRequest: Bool
        var message: String
        var successLeave: [WorkSpace]?
        var successDelete: [WorkSpace]?
        
    }
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .requestAllWorkspace:
            return requestAllWS(type: .fetchAll).asObservable()
        case .requestExit(let id):
            if let id = id {
                return requestExitWorkspace(id: id)
            } else {
                return Observable.of(Mutation.msg(msg: "ARGUMENT ERROR"))
            }
        case .requestDelete(let id):
            if let id = id {
                return requestDeleteWorkspace(id: id)
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
        case .successDelete(let data):
            if data.count > 0 {
                newState.successDelete = [data[0].toDomain()]
            } else {
                newState.successDelete = []
            }
            
            
        }
        return newState
    }
    
    
    private func requestDeleteWorkspace(id: Int) -> Observable<Mutation> {
        return WorkspacesAPIManager.shared.request(api: .delete(id: id), resonseType: EmptyResponse.self)
            .asObservable()
            .flatMap { result -> Observable<Mutation> in
                switch result {
                case .success(_):
                    return self.requestAllWS(type: .delete).asObservable()

                case .failure(let error):
                    var msg = CommonError.E99.localizedDescription
                    if let error = WorkspaceError(rawValue: error.errorCode) {
                        msg = error.localizedDescription
                    } else if let error = CommonError(rawValue: error.errorCode) {
                        msg = error.localizedDescription
                    }
                    return .just(Mutation.msg(msg: msg))
                }
            }
    }
    
    private func requestAllWS(type: requestType) -> Single<Mutation> {
        return WorkspacesAPIManager.shared.request(api: .fetchAll, resonseType: AllWorkspaceReDTO.self)
            .asObservable()
            .flatMap { result -> Observable<Mutation> in
                switch result {
                case .success(let value):
                    switch type {
                    case .delete:
                        return .just(Mutation.completLeave(data: value ?? []))
                    case .fetchAll:
                        return .just(Mutation.fetchAllWorkspace(data: value ?? []))
                    }
                    
                case .failure(let error):
                    return .just(Mutation.msg(msg: error.localizedDescription))
                }
            }
            .asSingle()
    }

    
    private func requestExitWorkspace(id: Int) -> Observable<Mutation> {
        return WorkspacesAPIManager.shared.request(api: .leave(id: id), resonseType: AllWorkspaceReDTO.self)
            .asObservable()
            .flatMap { result -> Observable<Mutation> in
                switch result {
                case .success(let response):
                    return .just(.completLeave(data: response ?? []))
                case .failure(let error):
                    if let error = WorkspaceError(rawValue: error.errorCode) {
                        return .concat(
                            .just(.msg(msg: error.localizedDescription)),
                            .empty()
                        )
                    } else if let error = CommonError(rawValue: error.errorCode) {
                        return .concat(
                            .just(.msg(msg: error.localizedDescription)),
                            .just(.msg(msg: ""))
                        )
                    } else {
                        return .concat(
                            .just(.msg(msg: error.localizedDescription)),
                            .empty()
                        )
                    }
                }
                
            }
    }
    
    
    
    enum requestType {
        case delete, fetchAll
    }
    
    
}
