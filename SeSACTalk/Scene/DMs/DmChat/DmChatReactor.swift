//
//  DmChatReactor.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/8/24.
//

import Foundation
import ReactorKit

final class DmChatReactor: Reactor {
    
    var initialState: State = State(
        msg: "", 
        loginReqeust: false,
        sendSuccess: nil
    )
    
    
    enum Action {
        case sendReqeust(wsId: Int?, roomId: Int?, content: String?, files: [SelectImage])
    }
    
    enum Mutation {
        case msg(msg: String)
        case loginRequest
        case sendSuccess(data: DmChat)
    }
    
    struct State {
        var msg: String
        var loginReqeust: Bool
        var sendSuccess: DmChat?
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .sendReqeust(let wsId, let roomId, let content, let files):
            if let wsId = wsId, let roomId = roomId {
                let imgs = files.map {
                    return $0.img?.imageToData()
                }
                let data = ChatReqDTO(content: content, files: imgs)
                return requestSendMsg(wsId: wsId, roomId: roomId, data: data)
            } else {
                debugPrint("[DATA BINDING ERROR]")
                return .just(.msg(msg: DmToastMessage.otherError.message))
            }
            
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .msg(let msg):
            newState.msg = msg
        case .loginRequest:
            newState.loginReqeust = true
        case .sendSuccess(let data):
            newState.sendSuccess = data
        }
        
        return newState
    }
    
    
}

extension DmChatReactor {
    private func requestSendMsg(wsId: Int, roomId: Int, data: ChatReqDTO) -> Observable<Mutation> {
        return DMsAPIManager.shared.request(api: .sendMsg(wsId: wsId, roomId: roomId, data: data), resonseType: DmChatResDTO.self)
            .asObservable()
            .withUnretained(self)
            .flatMap { (owner, result) -> Observable<Mutation> in
                switch result {
                case .success(let response):
                    if let response = response {
                        debugPrint("SUCCESS SEND DM")
                        let data = response.toDomain()
                        return .just(.sendSuccess(data: data))
                    }
                    return .just(.msg(msg: DmToastMessage.otherError.message))
                case .failure(let error):
                    var msg = CommonError.E99.localizedDescription
                    if let error = DmError(rawValue: error.errorCode) {
                        msg = error.localizedDescription
                    } else if let error = CommonError(rawValue: error.errorCode) {
                        msg = error.localizedDescription
                    } else {
                        return .just(.loginRequest)
                    }
                    return .just(.msg(msg: msg))
                    
                }
                
            }
    }
}
