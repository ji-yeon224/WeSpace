//
//  CreateChannelReactor.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/21/24.
//

import Foundation
import ReactorKit

final class CreateChannelReactor: Reactor {
    var initialState: State = State(successCreate: false, msg: "", loginRequest: false, showIndicator: false)
    
    
    enum Action {
        case requestCreate(id: Int?, name: String, desc: String?)
    }
    
    enum Mutation {
        case successCreate
        case msg(msg: String)
        case loginRequest
        case showIndicator(isShow: Bool)
    }
    
    struct State {
        var successCreate: Bool
        var msg: String
        var loginRequest: Bool
        var showIndicator: Bool
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .requestCreate(let id, let name, let desc):
            if let id = id {
                return .concat(
                    requestCreate(id: id, data: CreateChannelReqDTO(name: name, description: desc)),
                    Observable.of(Mutation.showIndicator(isShow: true))
                
                )
            }
            return Observable.just(Mutation.msg(msg: "ERROR"))
            
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .successCreate:
            newState.successCreate = true
        case .msg(let msg):
            newState.msg = msg
            newState.showIndicator = false
        case .loginRequest:
            newState.loginRequest = true
        case .showIndicator(let isShow):
            newState.showIndicator = isShow
        }
        return newState
    }
    
}

extension CreateChannelReactor {
    func requestCreate(id: Int, data: CreateChannelReqDTO) -> Observable<Mutation> {
        
        return ChannelsAPIManager.shared.request(api: .create(id: id, data: data), responseType: ChannelResDTO.self)
            .asObservable()
            .flatMap { result -> Observable<Mutation> in
                
                switch result {
                case .success(_):
                    return .concat(
                        .of(Mutation.successCreate),
                        .of(Mutation.showIndicator(isShow: false))
                    
                    )
                    
                    
                case .failure(let error):
                    var msg = CommonError.E99.localizedDescription
                    if let error = ChannelCreateError(rawValue: error.errorCode) {
                        msg = error.localizedDescription
                    } else if let error = CommonError(rawValue: error.errorCode) {
                        msg = error.localizedDescription
                    } else {
                        return .of(Mutation.loginRequest)
                    }
                    return .of(Mutation.msg(msg: msg))
                }
                
            }
        
    }
}
