//
//  SearchChannelReactor.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/30/24.
//

import Foundation
import ReactorKit

final class SearchChannelReactor: Reactor {
    var initialState: State = State(
        channelList: [],
        msg: ""
    )
    
    
    enum Action {
        case requestChannelList(wsId: Int?)
    }
    
    enum Mutation {
        case channelList(data: ChannelsItemResDTO)
        case msg(msg: String)
    }
    
    struct State {
        var channelList: [ChannelSectionModel]
        var msg: String
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .requestChannelList(let wsId):
            if let wsId = wsId {
                return requestAllChannelList(wsId: wsId)
            }
            return .just(.msg(msg: ChannelToastMessage.otherError.message))
            
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .channelList(let data):
            let items = data.map { $0.toDomain() }
            
            newState.channelList = [ChannelSectionModel(section: "", items: items)]
        case .msg(let msg):
            newState.msg = msg
        }
        
        return newState
    }
    
    
}

extension SearchChannelReactor {
    
    private func requestAllChannelList(wsId: Int) -> Observable<Mutation> {
        return ChannelsAPIManager.shared.request(api: .allChannel(wsId: wsId), responseType: ChannelsItemResDTO.self)
            .asObservable()
            .map { result -> Mutation in
                switch result {
                case .success(let response):
                    if let response = response {
                        return .channelList(data: response)
                    }
                    return .msg(msg: ChannelToastMessage.otherError.message)
                    
                    
                case .failure(let error):
                    return self.channelErrorCheck(error: error)
                        
                }
            }
    }
    
    
    private func channelErrorCheck(error: ErrorResponse) -> Mutation {
        if let error = ChannelError(rawValue: error.errorCode) {
            return .msg(msg: error.localizedDescription)
        } else if let error = CommonError(rawValue: error.errorCode) {
            return .msg(msg: error.localizedDescription)
        } else {
            return .msg(msg: CommonError.E99.localizedDescription)
        }
    }
    
}
