//
//  ChatReactor.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/24/24.
//

import Foundation
import ReactorKit

final class ChatReactor: Reactor {
    var initialState: State = State(msg: "", loginRequest: false)
    
    
    enum Action {
        case sendRequest(name: String, id: Int, data: ChannelChatReqDTO)
    }
    
    enum Mutation {
        case msg(msg: String)
        case loginRequest(login: Bool)
    }
    
    struct State {
        var msg: String
        var loginRequest: Bool
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .sendRequest(let name, let id, let data):
            return requestSendMsg(name: name, id: id, data: data)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        switch mutation {
        case .msg(let msg):
            <#code#>
        case .loginRequest(let login):
            <#code#>
        }
    }
    
    
}

extension ChatReactor {
    func requestSendMsg(name: String, id: Int, data: ChannelChatReqDTO) -> Observable<Mutation> {
        if data.content == nil && data.files == nil {
            return .just(Mutation.msg(msg: "No Data"))
        }
        
        return ChannelsAPIManager.shared.request(api: .sendMsg(name: name, id: id, data: data), responseType: ChannelChatResDTO.self)
            .asObservable()
            .flatMap { result -> Observable<Mutation> in
                switch result {
                case .success(let response):
                    return .just(.msg(msg: ""))
                    
                    
                case .failure(let error):
                    var msg = CommonError.E99.localizedDescription
                    if let error = ChannelChatError(rawValue: error.errorCode) {
                        msg = error.localizedDescription
                    } else if let error = CommonError(rawValue: error.errorCode) {
                        msg = error.localizedDescription
                    } else {
                        return .just(.loginRequest(login: true))
                    }
                    return .just(.msg(msg: msg))
                    
                }
                
            }
        
        
    }
    
    
//    private func saveToDB(data: Channelms)
}
