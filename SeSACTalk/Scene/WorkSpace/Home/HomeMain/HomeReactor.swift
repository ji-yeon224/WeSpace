//
//  HomeReactor.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/12/24.
//

import Foundation
import ReactorKit

final class HomeReactor: Reactor {
    var initialState: State = State(
        channelItems: [],
        loginRequest: false,
        message: ""
    )
    
    
    
    enum Action {
        case requestInfo(id: Int)
    }
    
    enum Mutation {
        case wsInfo(channels: [ChannelResDTO])
        case msg(msg: String)
        case loginRequest
    }
    
    struct State {
        var channelItems: [WorkspaceItem]
        var loginRequest: Bool
        var message: String
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .requestInfo(let id):
            return requestOneChannelInfo(id: id)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .wsInfo(let channels):
            newState.channelItems = channels.map {
                return WorkspaceItem(title: "", subItems: [], item: $0.toDomain())
            }
        case .msg(let msg):
            newState.message = msg
        case .loginRequest:
            newState.loginRequest = true
        }
        
        return newState
    }
    
}

extension HomeReactor {
    private func requestOneChannelInfo(id: Int) -> Observable<Mutation> {
        return WorkspacesAPIManager.shared.request(api: .fetchOne(id: id), resonseType: OneWorkspaceResDTO.self)
            .asObservable()
            .map { result -> Mutation in
                switch result {
                case .success(let response):
                    if let response = response {
                        return Mutation.wsInfo(channels: response.channels)
                    } else {
                        return Mutation.msg(msg: "오류가 발생하였습니다.")
                    }
                    
                case .failure(let error):
                    if let error = WorkspaceFetchError(rawValue: error.errorCode) {
                        return Mutation.msg(msg: error.localizedDescription)
                    } else if let error = CommonError(rawValue: error.errorCode) {
                        return Mutation.msg(msg: error.localizedDescription)
                    } else {
                        return Mutation.loginRequest
                    }
                    
                }
            }
        
    }
}
