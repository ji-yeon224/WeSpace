//
//  InviteReactor.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/20/24.
//

import Foundation
import ReactorKit

final class InviteReactor: Reactor {
    var initialState: State = State(
        msg: "", loginRequest: false, success: false
    )
    
    
    
    enum Action {
        case inviteRequest(id: Int?, email: String)
    }
    
    enum Mutation {
        case msg(msg: String)
        case loginRequest
        case inviteSuccess
    }
    
    struct State {
        var msg: String
        var loginRequest: Bool
        var success: Bool
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .inviteRequest(let id, let email):
            if let id = id {
                return requestInvite(id: id, email: email)
            } else {
                return Observable.of(Mutation.msg(msg: "ARGUMENT ERROR"))
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
        case .inviteSuccess:
            newState.success = true
        }
        
        return newState
    }
    
}

extension InviteReactor {
    private func requestInvite(id: Int, email: String) -> Observable<Mutation> {
        if email.isValidEmail() {
            return WorkspacesAPIManager.shared.request(api: .invite(id: id, email: EmailReqDTO(email: email)), resonseType: UserResDTO.self)
                .asObservable()
                .flatMap { result -> Observable<Mutation> in
                    switch result {
                    case .success(let response):
                        print(response!.nickname)
                        return .concat(
                            .just(Mutation.inviteSuccess),
                            .just(Mutation.msg(msg: WorkspaceToastMessage.successInvite.message))
                        )
                        
                    case .failure(let error):
                        var msg = CommonError.E99.localizedDescription
                        if let error = InviteError(rawValue: error.errorCode) {
                            msg = error.localizedDescription
                        } else if let error = CommonError(rawValue: error.errorCode) {
                            msg = error.localizedDescription
                        } else {
                            return .just(Mutation.loginRequest)
                        }
                        return .just(Mutation.msg(msg: msg))
                        
                    }
                    
                }
            
            
        } else {
            return Observable.concat(
                Observable.of(Mutation.msg(msg: WorkspaceToastMessage.invalidEmail.message)),
                Observable.of(Mutation.msg(msg: ""))
            )
        }
    }
}
