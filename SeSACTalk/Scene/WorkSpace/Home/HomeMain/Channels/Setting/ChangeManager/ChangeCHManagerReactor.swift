//
//  ChangeCHManagerReactor.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/5/24.
//

import Foundation
import ReactorKit

final class ChangeCHManagerReactor: Reactor {
    var initialState: State = State(
        memberList: nil,
        msg: "",
        changeInfo: nil
    )
    
    
    
    enum Action {
        case requestMemberList(wsId: Int?, name: String?)
        case requestChangeManager(wsId: Int?, name: String?, userId: Int)
    }
    
    enum Mutation {
        case memberList(data: [User])
        case msg(msg: String)
        case change(data: Channel)
    }
    
    struct State {
        var memberList: [User]?
        var msg: String
        var changeInfo: Channel?
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .requestMemberList(let wsId, let name):
            if let wsId = wsId, let name = name {
                return requestMemberList(wsId: wsId, name: name)
            } else {
                return .just(.msg(msg: ChannelToastMessage.otherError.message))
            }
        case .requestChangeManager(let wsId, let name, let userId):
            if let wsId = wsId, let name = name {
                return requestChangeManager(wsId: wsId, name: name, userId: userId)
            } else {
                return .just(.msg(msg: ChannelToastMessage.otherError.message))
            }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .memberList(let data):
            newState.memberList = data
        case .msg(let msg):
            newState.msg = msg
        case .change(let data):
            newState.changeInfo = data
        }
        return newState
    }

    
}

extension ChangeCHManagerReactor {
    
    private func requestChangeManager(wsId: Int, name: String, userId: Int) -> Observable<Mutation> {
        return ChannelsAPIManager.shared.request(api: .change(wsId: wsId, userId: userId, name: name), responseType: ChannelResDTO.self)
            .asObservable()
            .map { result -> Mutation in
                switch result {
                case .success(let response):
                    if let response = response {
                        return .change(data: response.toDomain())
                    } else {
                        return .msg(msg: ChannelToastMessage.otherError.message)
                    }
                case .failure(let error):
                    var msg = CommonError.E99.localizedDescription
                    if let error = ChannelError(rawValue: error.errorCode) {
                        msg = error.localizedDescription
                    } else if let error = CommonError(rawValue: error.errorCode) {
                        msg = error.localizedDescription
                    }
                    return .msg(msg: msg)
                }
            }
    }
    
    
    private func requestMemberList(wsId: Int, name: String) -> Observable<Mutation> {
        return ChannelsAPIManager.shared.request(api: .member(name: name, wsId: wsId), responseType: MemberResDTO.self)
            .asObservable()
            .map { result -> Mutation in
                switch result {
                case .success(let response):
                    if let response = response {
                        let data = response.map{ $0.toDomain() }.filter { $0.userId != UserDefaultsManager.userId }
                        return .memberList(data: data)
                    }
                    return .msg(msg: ChannelToastMessage.otherError.message)
                case .failure(let error):
                    var msg = CommonError.E99.localizedDescription
                    if let error = ChannelError(rawValue: error.errorCode) {
                        msg = error.exitErrorDescription ?? ""
                    } else if let error = CommonError(rawValue: error.errorCode) {
                        msg = error.localizedDescription
                    }
                    return .msg(msg: msg)
                }
            }
    }
    
    
}
