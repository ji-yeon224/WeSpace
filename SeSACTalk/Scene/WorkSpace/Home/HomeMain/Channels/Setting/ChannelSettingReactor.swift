//
//  ChannelSettingReactor.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/4/24.
//

import Foundation
import ReactorKit

final class ChannelSettingReactor: Reactor {
    var initialState: State = State(
        memberInfo: [],
        channelInfo: nil,
        msg: ""
    )
    
    
    
    enum Action {
        case requestChannelInfo(wsId: Int?, name: String?)
    }
    
    enum Mutation {
        case memberInfo(data: [User])
        case channelInfo(data: Channel)
        case msg(msg: String)
    }
    
    struct State {
        var memberInfo: [User]
        var channelInfo: Channel?
        var msg: String
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .requestChannelInfo(let wsId, let name):
            if let wsId = wsId, let name = name {
                return requestChannelInfo(wsId: wsId, name: name)
            } else {
                return .just(.msg(msg: ChannelToastMessage.otherError.message))
            }
            
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .memberInfo(let data):
            newState.memberInfo = data
        case .channelInfo(let data):
            newState.channelInfo = data
        case .msg(let msg):
            newState.msg = msg
        }
        return newState
    }
    
    
    
}

extension ChannelSettingReactor {
    
    private func requestExitChannel(wsId: Int, name: String) {
        
    }
    
    private func requestChannelInfo(wsId: Int, name: String) -> Observable<Mutation> {
        return ChannelsAPIManager.shared.request(api: .oneChannel(wsId: wsId, name: name), responseType: ChannelResDTO.self)
            .asObservable()
            .flatMap { result -> Observable<Mutation> in
                switch result {
                case .success(let response):
                    
                    if let response = response {
                        let channelInfo = response.toDomain()
                        let memberInfo = response.toUserDomain()
                        return .concat(
                            .just(.channelInfo(data: channelInfo)),
                            .just(.memberInfo(data: memberInfo))
                        )
                    } else {
                        return .just(.msg(msg: ChannelToastMessage.otherError.message))
                    }
                    
                    
                case .failure(let error):
                    var msg = CommonError.E99.localizedDescription
                    if let error = ChannelError(rawValue: error.errorCode) {
                        msg = error.localizedDescription
                    } else if let error = CommonError(rawValue: error.errorCode) {
                        msg = error.localizedDescription
                    }
                    return .just(.msg(msg: msg))
                }
                
            }
    }
}
